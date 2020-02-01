function Update_Depth_Map(PPA, imPanel)

  persistent oldMip;
  persistent oldDepth;

  % check if we actually have data to work with
  if (isempty(PPA.procVolProj) || isempty(PPA.depthInfo))
    return;
  end

  % check if we have new data or if we don't have to update after all...
  mip = PPA.procProj;
  depth = PPA.depthInfo;

  if isempty(oldMip) || isempty(oldDepth)
    oldMip = mip;
    oldDepth = depth;
  elseif isequal(oldMip, mip) && isequal(oldDepth, depth)
    return;
  end

  if nargin == 1
    imPanel = PPA.MapGUI.imDepthDisp;
  end

  PPA.Start_Wait_Bar(PPA.MapGUI, 'Updating depth map...');

  % get all the variables we need here at the top, so we don't affect the
  % Values stored in PPA and displayed in the GUI

  minAmp = PPA.MapGUI.MinAmpEditField.Value ./ 100;
  transparency = PPA.MapGUI.TranspEditField.Value; % 0-500
  claheLim = PPA.MapGUI.ContrastSlider.Value; % returns 10-90
  maskFrontCMap = PPA.MapGUI.depthColor.Value; % 'jet''parula' or 'hot', ...
  surfaceOffset = PPA.MapGUI.surfaceoffsetEditField.Value; % in percent, just because...
  depthOffset = PPA.MapGUI.depthoffsetEditField.Value; % in percent as well
  depthMapSmooth = PPA.MapGUI.SmoothPxEditField.Value;
  maskBackCMap = 'gray';

  %% Convert GUI inputs to usable Values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  num_colors = 256;
  transparency = transparency ./ 100; % 100% -> 1
  claheLim = claheLim ./ 100 * 0.1; % 100% -> 0.1

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
  % depth = raw depth info, usually max location of procVol
  % mip = processed mip to used as background for depth map
  % mip = fillmissing(mip,'linear'); % should not be needed
  % mip(isnan(mip)) = 0; % replaces all potential NANs
  mip = normalize(mip);

  % clahe the already processed image before overlaying depth mask
  % NOTE uses the seperate slider for contrast, get other clahe Values
  % from clahe filtering panel
  if (claheLim > 0)% if contrast == 0 don't apply CLAHE
    claheDistr = PPA.MapGUI.ClaheDistr.Value;
    claheNBins = str2double(PPA.MapGUI.ClaheBins.Value);
    nTiles = str2double(PPA.MapGUI.ClaheTiles.Value);
    nTiles = [nTiles nTiles];
    mip = adapthisteq(mip, 'Distribution', claheDistr, 'NBins', claheNBins, ...
      'ClipLimit', claheLim, 'NumTiles', nTiles);
    mip = normalise(mip); % brink back to "normal" range
  end

  % ignore pixels with amps less that minAmp
  depthRangeMap = depth;
  ignorePixel = (mip < minAmp);
  depthRangeMap(ignorePixel) = NaN; % ignore pixels with signals < 10%
  depthRangeMap = fillmissing(depthRangeMap, 'nearest');
  surfaceLimit = min(depthRangeMap(:));
  depthLimit = max(depthRangeMap(:));
  % offset depth map limits by using manually entered values
  % convert percent low/high limit to actual mm values
  fullRange = depthLimit - surfaceLimit;
  depthOffset = depthOffset ./ 100 * fullRange ./ 2; % maximum possible offset (100%) is half the depth range
  surfaceOffset = surfaceOffset ./ 100 * fullRange ./ 2;
  surfaceLimit = surfaceLimit + surfaceOffset;
  depthLimit = depthLimit - depthOffset;

  % truncate min/max values for display
  fullDepth = depth; % full depth before cropping, used for histograms later
  fullDepthLims = minmax(fullDepth);
  fullDepthRange = fullDepthLims(2) - fullDepthLims(1);
  depth(depth < surfaceLimit) = surfaceLimit;
  depth(depth > depthLimit) = depthLimit;
  PPA.Update_Status(sprintf('   Surface: %2.1f Depth: %2.1f', surfaceLimit, depthLimit));

  % create labels
  nDepthLabels = 6;
  % indexRange = round(linspace(surfaceLimit,depthLimit,nDepthLabels));
  currentTickLims = [0 1];
  tickLocations = linspace(min(currentTickLims), max(currentTickLims), nDepthLabels);
  tickValues = linspace(surfaceLimit, depthLimit, nDepthLabels);

  for iLabel = 1:nDepthLabels
    zLabels{iLabel} = sprintf('%2.1f mm', tickValues(iLabel)); %#ok<AGROW>
  end

  %zLabels{1} = 'closer';
  %zLabels{end} = 'deeper';

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % create background RGB image ------------------------------------------------
  back = normalize(mip); % already normalized at this point
  % scale the background image from 0 to num_colors
  % back = imadjust(back);
  back = round(num_colors .* back);
  % convert the background image to true color
  back = ind2rgb(back, maskBackCMap);

  % create depth mask foreground RGB image ------------------------------------------------
  % scale the depth image from 0 to num_colors
  front = normalize(depth); % we loose depth info here, but it's stored in the cbar labels..
  frontIm = imgaussfilt(front, depthMapSmooth * 0.1);
  frontIm = normalize(frontIm);
  frontIm = round(num_colors .* frontIm);
  % convert the depth mask to true color
  frontIm = ind2rgb(frontIm, maskFrontCMap);

  if PPA.MasterGUI.DebugMode.Value
    figure();
    imshow(frontIm);
    title('Depth Map Front Mask');
    figure();
    pretty_hist(depth);
  end

  % create foreground transparency mask-----------------------------------------
  % also is faster this way...
  % this makes exporting etc A LOT easier...
  % frontIm = medfilt2(frontIm,[3 3]);
  depthImage = back .* frontIm .* transparency;
  imagesc(imPanel, PPA.xPlot, PPA.yPlot, depthImage);
  colormap(imPanel, maskFrontCMap);
  c = colorbar(imPanel);
  c.TickLength = 0;
  c.Ticks = tickLocations;
  c.TickLabels = zLabels;
  % store depth map data as property in PPA class, so we can recreate figure for export
  % NOTE: we need to do it this way, as GUI axis can't be exported with export_fig
  % but we need export_fig to export the colormaps properly...
  PPA.depthImage = depthImage;
  PPA.maskFrontCMap = maskFrontCMap;
  PPA.tickLocations = tickLocations;
  PPA.zLabels = zLabels;

  % plot/update depth histograms --------------------------------------------------------
  % settings for histogram, could be put somewhere else some day but here is fine for now
  nbins = round(fullDepthRange ./ 0.06); % get a bin for every 100 um
  nbins = max([nbins 40]); % have at least 20 bins though...
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
  PPA.MapGUI.histoAx.YLim = origYLim; % restore orig ylim so that truncating does not distort axis so much...

  PPA.Stop_Wait_Bar();

end
