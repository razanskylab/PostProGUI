function Update_Depth_Map(PPA, ~)
  % doForceUpdate == 1  forces update of depth map, even if mip and depth info
  % has not changed. We need this so that changes to depth map settings in the
  % GUI are not ignored when this function is called

  % persistent oldMip;
  % persistent oldDepth;

  % check if we actually have data to work with
  if (isempty(PPA.procVolProj) || isempty(PPA.depthInfo))
    return;
  end

  % if nargin == 1
  %   doForceUpdate = 0;
  % end
  % check if we have new data or if we don't have to update after all...
  mip = PPA.procProj;
  depth = PPA.depthInfo;

  % if isempty(oldMip) || isempty(oldDepth) || doForceUpdate
  %   oldMip = mip;
  %   oldDepth = depth;
  % elseif isequal(oldMip, mip) && isequal(oldDepth, depth)
  %   short_warn('same old data...')
  %   return;
  % end

  PPA.Start_Wait_Bar(PPA.MapGUI, 'Updating depth map...');

  %% Convert GUI inputs to usable Values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % get all the variables we need here at the top, so we don't affect the
  % Values stored in PPA and displayed in the GUI
  minAmp = PPA.MapGUI.MinAmpEditField.Value ./ 100;
  transparency = PPA.MapGUI.TranspEditField.Value; % 0-500
  maskFrontCMap = PPA.MapGUI.depthColor.Value; % 'jet''parula' or 'hot', ...
  shiftType = PPA.MapGUI.CropDepthDropDown.Value; % 'Relative (above)' or 'Absolute (below)'
  relSurfaceOffset = PPA.MapGUI.surfaceoffsetSlider.Value; % 0 <-> 0.5
  relDepthOffset = -PPA.MapGUI.depthoffsetSlider.Value; % -0.5 <-> 0 
  absSurfaceCut = PPA.MapGUI.topcutEditField.Value; % 0 <-> 0.5
  absDepthCut = PPA.MapGUI.depthcutEditField.Value; % -0.5 <-> 0 
  % NOTE minus sign for depthoffsetSlider is correct as range is -100<->0
  globalOffset = PPA.MapGUI.OffsetmmEditField.Value; 
  shiftFinalDepthMap = PPA.MapGUI.shiftEditField.Value; 
    % absolute, global offset, addded in the end, shifts cmap up/down
  depthMapSmooth = PPA.MapGUI.SmoothEditField.Value;
  maskBackCMap = 'gray';
  num_colors = 256;
  transparency = transparency ./ 100; % 100% -> 1

  % get background and foreground colormaps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  eval(['maskBackCMap = ' maskBackCMap '(num_colors);']); % turn string to actual colormap matrix
  %
  C = Colors();

  switch maskFrontCMap
    case {'jet', 'hot', 'gray', 'parula'}
      eval(['maskFrontCMap = ' maskFrontCMap '(num_colors);']); % turn string to actual colormap matrix
    case {'BOG'}% blueOrangeGreenFUI
      maskFrontCMap = make_linear_triple_colormap(C.pictonBlue, C.ecstasy, C.malachite, num_colors);
    case {'BGO'}% blueGreenOrangeFUI
      maskFrontCMap = make_linear_triple_colormap(C.pictonBlue, C.malachite, C.ecstasy, num_colors);
    case {'GOB'}% greenOrangeBlueFUI
      maskFrontCMap = make_linear_triple_colormap(C.malachite, C.ecstasy, C.pictonBlue, num_colors);
    case {'GBO'}% greenBlueOrangeFUI
      maskFrontCMap = make_linear_triple_colormap(C.malachite, C.pictonBlue, C.ecstasy, num_colors);
    case {'OGB'}% orangeGreenBlueFUI
      maskFrontCMap = make_linear_triple_colormap(C.ecstasy, C.malachite, C.pictonBlue, num_colors);
    case {'OBG'}% orangeBlueGreenFUI
      maskFrontCMap = make_linear_triple_colormap(C.ecstasy, C.pictonBlue, C.malachite, num_colors);
    case {'GR'}% greenToRedFUI
      maskFrontCMap = make_linear_colormap(C.malachite, C.monza, num_colors);
    case {'GO'}% greenToOrangeFUI
      maskFrontCMap = make_linear_colormap(C.malachite, C.ecstasy, num_colors);
    case {'ROG'}% redOrangeGreenFUI
      maskFrontCMap = make_linear_triple_colormap(C.pomegranate, C.ecstasy, C.malachite, num_colors);
  end

  % process fore and background %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % process mip, just normalize and adjust contrast if required ----------------
  % mip = processed mip to used as background for depth map
  mip = normalize(mip);

  
  % process depth map...lot more happenning here--------------------------------
  % depth = raw depth info, usually max location of procVol
  depth = depth + globalOffset; % like the name suggest, add the global offset
  
  % ignore pixels with amps less that minAmp
  depthRangeMap = depth;
  ignorePixel = (mip < minAmp);
  depthRangeMap(ignorePixel) = NaN; % ignore pixels with signals < 10%
  depthRangeMap = fillmissing(depthRangeMap, 'nearest');
  surfaceLimit = min(depthRangeMap(:));
  depthLimit = max(depthRangeMap(:));

  % offset depth map limits by using manually entered values %%%%%%%%%%%%%%%%%%%
  relShift = strcmp(shiftType,'Relative (above)');
  if relShift
    % convert percent low/high limit to actual mm values
    fullRange = depthLimit - surfaceLimit;
    % maximum possible offset (100%) is half the depth range
    relDepthOffset = relDepthOffset * fullRange;
    relSurfaceOffset = relSurfaceOffset * fullRange;
    surfaceLimit = surfaceLimit + relSurfaceOffset; % move surface 'deeper'
    depthLimit = depthLimit - relDepthOffset; % move bottom 'higher'
    PPA.MapGUI.topcutEditField.Value = double(surfaceLimit);
    PPA.MapGUI.depthcutEditField.Value = double(depthLimit);
  else
    surfaceLimit = absSurfaceCut;
    depthLimit = absDepthCut;
  end

  % shift the final range we want up or down...
  if shiftFinalDepthMap 
    surfaceLimit = surfaceLimit + shiftFinalDepthMap; 
    depthLimit = depthLimit + shiftFinalDepthMap; 
  end

  % truncate min/max values of depth map, can help with visualization ----------
  fullDepth = depth; % full depth before cropping, used for histograms later
  depth(depth < surfaceLimit) = surfaceLimit;
  depth(depth > depthLimit) = depthLimit;
  PPA.Update_Status(sprintf('   Surface: %2.1f Depth: %2.1f', surfaceLimit, depthLimit));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % create background RGB image ------------------------------------------------
  back = mip; % already normalized at this point
  % scale the background image from 0 to num_colors
  % back = imadjust(back);
  back = round(num_colors .* back);
  % convert the background image to true color
  back = ind2rgb(back, maskBackCMap);

  % create depth mask foreground RGB image -------------------------------------

  % scale the depth image from 0 to num_colors, but we don't just normalize,
  % we take the limits into account instead, thus having the option to shift
  % the depth range we are interested in to any values, which is very useful 
  % for plotting different datasets with a matching colormap!!!
  frontIm = depth; 
  frontIm = frontIm - surfaceLimit;
  frontIm = frontIm ./ (depthLimit - surfaceLimit);
  % apply optional gaussian smoothing of depth map
  if depthMapSmooth 
    frontIm = imgaussfilt(frontIm, depthMapSmooth);
  end
  frontIm = round(num_colors .* frontIm);
  % convert the depth mask to true color
  frontIm = ind2rgb(frontIm, maskFrontCMap);

  if PPA.MasterGUI.DebugMode.Value
    figure();
    imshow(frontIm);
    title('Depth Map Front Mask');
  end

  % create foreground transparency mask-----------------------------------------
  % also is faster this way...
  % this makes exporting etc A LOT easier...
  depthImage = back .* frontIm .* transparency;

  set(PPA.MapFig.DepthIm, 'cdata', depthImage);
  set(PPA.MapFig.DepthIm, 'ydata', PPA.xPlot);
  set(PPA.MapFig.DepthIm, 'xdata', PPA.yPlot);
  % imagesc(PPA.MapGUI.imDepthDisp, PPA.yPlot, PPA.xPlot, depthImage);
  colormap(PPA.MapFig.DepthAx, maskFrontCMap);

  % get depth labels and update deph-colorbar ----------------------------------
  nDepthLabels = 8;
  tickLocations = linspace(0.025, 0.975, nDepthLabels); % juuuust next to max limits
  tickValues = linspace(surfaceLimit, depthLimit, nDepthLabels);
  for iLabel = nDepthLabels:-1:1
    zLabels{iLabel} = sprintf('%2.2f', tickValues(iLabel));
  end
  % c = colorbar(PPA.MapFig.DepthAx, 'Location', 'southoutside');
  c = colorbar(PPA.MapFig.DepthAx);
  c.TickLength = 0;
  c.Ticks = tickLocations;
  c.TickLabels = zLabels;
  c.Label.String = 'closer     <-     depth     ->     deeper';

  % store depth map data as property in PPA class, so we can recreate figure for export
  % NOTE: we need to do it this way, as GUI axis can't be exported with export_fig
  % but we need export_fig to export the colormaps properly...
  PPA.depthImage = depthImage;
  PPA.maskFrontCMap = maskFrontCMap;
  PPA.tickLocations = tickLocations;
  PPA.zLabels = zLabels;

  % plot/update depth histograms --------------------------------------------------------
  % settings for histogram, could be put somewhere else some day but here is fine for now
  nbins = round(numel(unique(depth(:)))./5); % get a bin for every 100 um
  nbins = max([nbins 10]); % have at least 10 bins
  nbins = min([nbins 75]); % have no more than 75 bins
  normalizationType = 'countdensity';
  histoColor = Colors.sherpaBlue;
  H = histogram(PPA.MapGUI.histoAx, fullDepth, nbins, 'Normalization', normalizationType);
  H.FaceColor = histoColor;
  H.FaceAlpha = 0.50;
  H.EdgeColor = 'none';
  hold(PPA.MapGUI.histoAx, 'on');
  axis(PPA.MapGUI.histoAx, 'tight');
  origYLim = PPA.MapGUI.histoAx.YLim;

  histoColor = Colors.capeHoney;
  H = histogram(PPA.MapGUI.histoAx, depth, nbins, 'Normalization', normalizationType);
  H.FaceColor = histoColor;
  H.FaceAlpha = 0.75;
  H.EdgeColor = 'none';
  hold(PPA.MapGUI.histoAx, 'off');
  axis(PPA.MapGUI.histoAx, 'tight');
  % restore orig ylim so that truncating does not distort axis so much...
  PPA.MapGUI.histoAx.YLim = origYLim; 
  PPA.ProgBar = [];

  
end
