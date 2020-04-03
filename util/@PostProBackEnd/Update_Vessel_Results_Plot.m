function Update_Vessel_Results_Plot(PPA)
  % follows closely what is happening in AVA.Get_Data(); 
  % but this way we can plot in between...
  % this function only takes care of initializing the AVA data properly
  % and then binarized the latest processed projection
  
  try
    % check if we have done the vessel analysis yet..
    if isempty(PPA.AVA)
      PPA.Apply_Vessel_Processing();
    end
    
    % get more convenient variables
    VData = PPA.AVA.Data; 
    vList = VData.vessel_list;
    VesselFigs = PPA.VesselFigs;

    % bring the figures we use to the front
    figure(VesselFigs.MainFig);
    figure(VesselFigs.ResultsFig);
    figure(PPA.VesselGUI.UIFigure);

    progressbar('Plotting found vessels...', {Colors.GuiLightOrange});
    PPA.Update_Status('Plotting fitted vessels...');

    % update scatter overlay alpha
    scatterAlpha = PPA.VesselGUI.scatterAlpha.Value;
    VesselFigs.SplineScat.MarkerFaceAlpha = scatterAlpha;
    VesselFigs.SplineLine.Color(4) = scatterAlpha;
    VesselFigs.LEdgeLines.Color(4) = scatterAlpha;
    VesselFigs.REdgeLines.Color(4) = scatterAlpha;

    % Plot fitted vessel center lines etc... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fun = @(x) cat(1, x, [nan, nan]);
    centers = cellfun(fun, {vList.centre}, 'UniformOutput', false);
    centers = cell2mat(centers');
    VesselFigs.SplineLine.XData = centers(:, 2);
    VesselFigs.SplineLine.YData = centers(:, 1);
    progressbar(0.15);

    fun = @(x) cat(1, x, [nan, nan]);
    side1 = cellfun(fun, {vList.side1}, 'UniformOutput', false);
    side2 = cellfun(fun, {vList.side2}, 'UniformOutput', false);
    side1 = cell2mat(side1');
    side2 = cell2mat(side2');
    VesselFigs.LEdgeLines.XData = side1(:, 2);
    VesselFigs.LEdgeLines.YData = side1(:, 1);
    VesselFigs.REdgeLines.XData = side2(:, 2);
    VesselFigs.REdgeLines.YData = side2(:, 1);
    progressbar(0.3);

    if ~isempty(VData.branchCenters)
      VesselFigs.SplineScat.XData = VData.branchCenters(:, 1);
      VesselFigs.SplineScat.YData = VData.branchCenters(:, 2);
    end
    % update scatter overlay alpha
    scatterAlpha = PPA.VesselGUI.scatterAlpha.Value;
    VesselFigs.SplineScat.MarkerFaceAlpha = scatterAlpha;
    VesselFigs.SplineLine.Color(4) = scatterAlpha;
    VesselFigs.LEdgeLines.Color(4) = scatterAlpha;
    VesselFigs.REdgeLines.Color(4) = scatterAlpha;
    progressbar(0.5);

    % Plot angle turt or diameter... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dataColorMap = PPA.VesselGUI.DataColorMap.Value;
    nColors = PPA.VesselGUI.nColors.Value;
    scaleSize = PPA.VesselGUI.scaleSize.Value;
    plotSize = PPA.VesselGUI.plotSize.Value;
    removeOutliers = PPA.VesselGUI.removeOutliers.Value;
    stdMulti = PPA.VesselGUI.maxStd.Value;

    switch PPA.VesselGUI.DataColorMap.Value
      case {'jet', 'hot', 'gray', 'parula', 'hsv'}
        eval(['dataColorMap = ' dataColorMap '(nColors);']); % turn string to actual colormap matrix
      case {'GreenRed'} 
        dataColorMap = make_linear_colormap(Colors.PureRed, Colors.BrightGreen, nColors); 
      case {'RedGreen'} 
        dataColorMap = make_linear_colormap(Colors.BrightGreen, Colors.PureRed, nColors);
      case {'GreenBlue'}
        dataColorMap = make_linear_colormap(Colors.PureBlue, Colors.BrightGreen, nColors);
      case {'BlueGreen'}
        dataColorMap = make_linear_colormap(Colors.BrightGreen, Colors.PureBlue, nColors);
    end

    switch PPA.VesselGUI.WhatDataOverlay.Value
      case 'angle' % per vessel-segment
        PPA.Update_Status('Plotting vessel angles...');
        titleStr = 'Vessel Angle';
        histTitle = 'Angle (Deg)';
        % get all unit vecrtors
        fun = @(x) cat(1, x, [NaN NaN]);
        unitVectors = cellfun(fun, {vList.angles}, 'UniformOutput', false);
        unitVectors = cell2mat(unitVectors');
        angles = atan2d(unitVectors(:, 2), unitVectors(:, 1));
        angles(angles < 0) = angles(angles < 0) + 180; % only use 0 - 180 deg
        data = angles;
      case 'diameter' % per vessel-segment
        PPA.Update_Status('Plotting vessel diameters...');
        titleStr = 'Vessel Diameter';
        histTitle = 'Diameter (Px)';
        % get all corresponding diameters
        fun = @(x) cat(1, x, NaN);
        diameters = cellfun(fun, {vList.diameters}, 'UniformOutput', false);
        diameters = cell2mat(diameters');
        data = diameters;
      case 'turtuosity' % per vessel
        PPA.Update_Status('Plotting vessel turtuosity...');
        titleStr = 'Vessel Turtuosity';
        histTitle = 'Turtuosity';
        fun = @(x) cat(1, x);
        cumLength = cellfun(fun, {vList.length_cumulative}, 'UniformOutput', false);
        cumLength = cell2mat(cumLength');

        fun = @(x) cat(1, x);
        straightLength = cellfun(fun, {vList.length_straight_line}, 'UniformOutput', false);
        straightLength = cell2mat(straightLength');

        turtuosity = cumLength ./ straightLength;
        % split up diameters and corresponding center positions based on their plot color
        data = turtuosity;
    end

    if removeOutliers
      % cast outliers to minmax values
      upLim = median(data,'omitnan') + std(data,'omitnan') .* stdMulti;
      lowLim = median(data,'omitnan') - std(data,'omitnan') .* stdMulti;
      data(data >= upLim) = upLim;
      data(data <= lowLim) = lowLim;
    end

    % plot the overlay data
    groups = discretize(data, nColors);
    
    % redraw entire figure as everything else gets complicated and safe almost no time...
    oldXLim = VesselFigs.DataDisp.XLim;
    oldYLim = VesselFigs.DataDisp.YLim;
    VesselFigs.DataImBack = imagesc(VesselFigs.DataDisp, VesselFigs.plotBackground);
    axis(VesselFigs.DataDisp, 'image'); 
    VesselFigs.DataDisp.XLim = oldXLim;
    VesselFigs.DataDisp.YLim = oldYLim;
    axis(VesselFigs.DataDisp, 'off'); % no need for axis labels in these plots
    title(VesselFigs.DataDisp, titleStr);
    progressbar(0.7);


    % loop trough all colors and plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold(VesselFigs.DataDisp,'on');
    if scaleSize
      scatterArea = (normalize(1:nColors)+0.1) .* plotSize .* 10; % make sure it's always in the 0-1 range
    else
      scatterArea = ones(1, nColors) .* plotSize;
    end
    if ~strcmp(PPA.VesselGUI.WhatDataOverlay.Value, 'turtuosity')
      for iColor = 1:nColors
        plotCtr = centers(groups == iColor, :);
        if ~isempty(plotCtr)
          scatter(VesselFigs.DataDisp, plotCtr(:, 2), plotCtr(:, 1), scatterArea(iColor), ...
            'MarkerFaceColor', dataColorMap(iColor, :), ...
            'MarkerFaceAlpha', scatterAlpha, ...
            'MarkerEdgeColor', 'none');
        end
      end
    else
      for iColor = 1:nColors
        plotVessels = vList(groups == iColor);
        if ~isempty(plotVessels)
          fun = @(x) cat(1, x, [nan, nan]);
          temp = cellfun(fun, {plotVessels.centre}, 'UniformOutput', false);
          lineCtr = cell2mat(temp');
          line(VesselFigs.DataDisp,lineCtr(:, 2), lineCtr(:, 1),...
            'LineStyle', '-', ...
            'Color', dataColorMap(iColor, :), ...
            'linewidth', scatterArea(iColor));
        end
      end
    end 
    hold(VesselFigs.DataDisp, 'off');
    VesselFigs.DataDisp.Colormap = dataColorMap; % update colors of colorbar
    progressbar(0.8);

    % update colorbar labels
    % get depth labels and update deph-colorbar ----------------------------------
    nDepthLabels = 9;
    tickLocations = linspace(0, 1, nDepthLabels); % juuuust next to max limits
    tickValues = linspace(min(data), max(data), nDepthLabels);
    for iLabel = nDepthLabels:-1:1
      zLabels{iLabel} = sprintf('%2.2f', tickValues(iLabel));
    end
    VesselFigs.Colorbar.TickLength = 0;
    VesselFigs.Colorbar.Ticks = tickLocations;
    VesselFigs.Colorbar.TickLabels = zLabels;
    VesselFigs.Colorbar.Label.String = titleStr;
    colormap(VesselFigs.Colorbar, dataColorMap);
    % VesselFigs.Colorbar.Location = 'westoutside';

    % update histogram in GUI
    PPA.Update_Status('Updating histogram data...');
    progressbar(0.9);
    HistoAx = PPA.VesselGUI.histoAx;
    HistoAx.Title.String = [titleStr ' Distribution'];
    HistoAx.XLabel.String = histTitle;
    nbins = round(numel(data)); % get a bin for every 100 um
    nbins = max([nbins 10]); % have at least 10 bins
    nbins = min([nbins 75]); % have no more than 75 bins
    % this seems to be the only way one can properly update a histogram
    % and it's axis correctly...
    [~, edges] = histcounts(data, nbins, 'Normalization', 'countdensity');
    VesselFigs.Histo.Data = data;
    VesselFigs.Histo.BinEdges = edges;
    VesselFigs.Histo.BinLimits = minmax(edges);
    axis(HistoAx, 'tight');

    PPA.VesselFigs = VesselFigs;
    PPA.ProgBar = [];
    progressbar(1);

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end
end
