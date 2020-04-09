function Setup_Vessel_Figures(PPA)
  % creates two main vessels analysis figures
  % VesselFigs.MainFig
  % VesselFigs.ResultsFig
  % 
  % with subplots:
  % VesselFigs.TileLayout
  % VesselFigs.InPlot
  % VesselFigs.BinPlot 
  % ....
  % 
  % containing images:
  % VesselFigs.InIm
  % VesselFigs.BinIm
  % ...
  % TODO complete list?

  PPA.Start_Wait_Bar(PPA.VesselGUI, 'Setting up figures...');
  PPA.Update_Status('Setting up vessel figures');
  ProgHandle = progressbar('Setting up vessel figures', {Colors.GuiLightOrange});
  overlayAlpha = 0.5;

  % setup processing figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fHandle = figure('Name', 'Figure: Vessel Processing');
  fHandle.NumberTitle = 'off';
  fHandle.ToolBar = 'figure';
  fHandle.Colormap = gray(256);
  progressbar(0.1);
  figure(ProgHandle);

  % make figure fill ~ half the screen and be next to GUI ---------------------
  set(fHandle, 'Units', 'Normalized', 'OuterPosition', [0 0 0.4 0.7]);
  % move figure over a little to the right of the vessel GUI
  fHandle.Units = 'pixels';
  % move figure next to the GUI
  fHandle.OuterPosition(1) = PPA.VesselGUI.UIFigure.Position(1) + ...
    PPA.VesselGUI.UIFigure.Position(3) - 5;
  % bottom pos = bot of GUI + height of GUI - height of figure
  fHandle.OuterPosition(2) = PPA.VesselGUI.UIFigure.Position(2) + ... 
    PPA.VesselGUI.UIFigure.Position(4) - fHandle.OuterPosition(4) + 30;
  VesselFigs.MainFig = fHandle; 

  % create flow-layout for processing steps to use available space as best as possible
  VesselFigs.TileLayout = tiledlayout(fHandle,'flow');
  VesselFigs.TileLayout.Padding = 'compact'; % remove uneccesary white space...

  % closing the processing figure also closes the GUI and vice-versa
  VesselFigs.MainFig.UserData = PPA.VesselGUI; % need that in Gui_Close_Request callback
  VesselFigs.MainFig.CloseRequestFcn = @Gui_Close_Request;
  progressbar(0.2);

  % setup subplots of processing figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Input Image ----------------------------------------------------------------
  emptyImage = nan(size(PPA.procProj));
  VesselFigs.InPlot = nexttile(VesselFigs.TileLayout);
  VesselFigs.InIm = imagesc(VesselFigs.InPlot,emptyImage);
  axis image; axis tight; axis off; % no need for axis labels in these plots
  title('Input Image');
  progressbar(0.3);

  % Binarized Image ------------------------------------------------------------
  VesselFigs.BinPlot = nexttile(VesselFigs.TileLayout);
  VesselFigs.BinIm = imagesc(VesselFigs.BinPlot,emptyImage);
  axis image; axis tight; axis off; % no need for axis labels in these plots
  title('Binarized Image');
  progressbar(0.4);

  % Cleaned Binarized Image ----------------------------------------------------
  VesselFigs.BinCleanPlot = nexttile(VesselFigs.TileLayout);
  VesselFigs.BinCleanIm = imagesc(VesselFigs.BinCleanPlot, emptyImage);
  axis image; axis tight; axis off; % no need for axis labels in these plots
  title('Cleaned Binarized Image');
  progressbar(0.5);

  % skeleton image with branches -----------------------------------------------
  VesselFigs.Skeleton = nexttile(VesselFigs.TileLayout);
  VesselFigs.SkeletonImBack = imagesc(VesselFigs.Skeleton,emptyImage);
  axis image; axis tight; axis off; % no need for axis labels in these plots
  hold on;
  VesselFigs.SkeletonImFront = imagesc(VesselFigs.Skeleton, emptyImage);
  VesselFigs.SkeletonScat = scatter(VesselFigs.Skeleton,NaN, NaN);
  VesselFigs.SkeletonScat.LineWidth = 1.0;
  VesselFigs.SkeletonScat.MarkerEdgeAlpha = 0; 
  VesselFigs.SkeletonScat.MarkerFaceColor = Colors.DarkOrange; 
  VesselFigs.SkeletonScat.MarkerFaceAlpha = overlayAlpha; 
  VesselFigs.SkeletonScat.SizeData = 15; 
  hold off;
  title('Skeletonized Image');
  progressbar(0.6);

  % setup results figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fHandle = figure('Name', 'Figure: Vessel Analysis Results');
  fHandle.NumberTitle = 'off';
  fHandle.ToolBar = 'figure';
  fHandle.Colormap = VesselFigs.cbar;
  progressbar(0.7);
  figure(ProgHandle); % bring progbar back to front

  % make figure fill ~ half the screen and be next to GUI ---------------------
  set(fHandle, 'Units', 'Normalized', 'OuterPosition', [0 0 0.4 0.7]);
  % move figure over a little to the right of the vessel GUI
  fHandle.Units = 'pixels';
  % move figure next to the analysis
  fHandle.OuterPosition(1) = VesselFigs.MainFig.OuterPosition(1) + ...
    VesselFigs.MainFig.OuterPosition(3);
  % bottom pos same as the analysis figure as they are  the same size
  fHandle.OuterPosition(2) = VesselFigs.MainFig.OuterPosition(2);
  VesselFigs.ResultsFig = fHandle;

  % create flow-layout for processing steps to use available space as best as possible
  VesselFigs.ResultsTileLayout = tiledlayout(fHandle, 3, 9);
  VesselFigs.ResultsTileLayout.Padding = 'compact'; % remove uneccesary white space...

  % closing the processing figure also closes the GUI and vice-versa
  VesselFigs.ResultsFig.UserData = PPA.VesselGUI; % need that in Gui_Close_Request callback
  VesselFigs.ResultsFig.CloseRequestFcn = @Gui_Close_Request;
  progressbar(0.8);

  % spline fitted with branches ------------------------------------------------
  VesselFigs.Spline = nexttile(VesselFigs.ResultsTileLayout,[3 4]);
  VesselFigs.SplineImBack = imagesc(VesselFigs.Spline,emptyImage);
  axis image;  axis tight; axis off; % no need for axis labels in these plots
  hold on;
  VesselFigs.SplineScat = scatter(VesselFigs.Spline,NaN, NaN);
  VesselFigs.SplineScat.LineWidth = 1.0;
  VesselFigs.SplineScat.MarkerEdgeAlpha = 0;
  VesselFigs.SplineScat.MarkerFaceColor = Colors.DarkOrange;
  VesselFigs.SplineScat.MarkerFaceAlpha = overlayAlpha;
  VesselFigs.SplineScat.SizeData = 20;

  VesselFigs.SplineLine = line(VesselFigs.Spline,NaN, NaN);
  VesselFigs.SplineLine.LineStyle = '-';
  VesselFigs.SplineLine.Color = Colors.PureRed;
  VesselFigs.SplineLine.Color(4) = overlayAlpha;
  VesselFigs.SplineLine.LineWidth = 2;

  VesselFigs.LEdgeLines = line(VesselFigs.Spline,NaN, NaN);
  VesselFigs.LEdgeLines.LineStyle = '--';
  VesselFigs.LEdgeLines.Color = Colors.PureRed;
  VesselFigs.LEdgeLines.Color(4) = overlayAlpha;
  VesselFigs.LEdgeLines.LineWidth = 1.5;
  VesselFigs.REdgeLines = line(VesselFigs.Spline,NaN, NaN);
  VesselFigs.REdgeLines.LineStyle = '--';
  VesselFigs.REdgeLines.Color = Colors.PureRed;
  VesselFigs.REdgeLines.Color(4) = overlayAlpha;
  VesselFigs.REdgeLines.LineWidth = 1.5;
  hold off;
  title(VesselFigs.Spline,'Found Vessels');
  VesselFigs.SplineLeg = legend(VesselFigs.Spline, ...
    {'Branch Points', 'Centerlines', 'Edges'});
  VesselFigs.SplineLeg.Orientation = 'horizontal';
  VesselFigs.SplineLeg.Location = 'south';
  progressbar(0.9);

  % create empty inbetween tile
  nexttile(VesselFigs.ResultsTileLayout, [1 1]); 
  axis off;

  % data overlay (angle, diameter, turtuosity)
  VesselFigs.DataDisp = nexttile(VesselFigs.ResultsTileLayout, [3 4]);
  VesselFigs.DataImBack = imagesc(VesselFigs.DataDisp, emptyImage);
  axis image; axis tight; axis off; % no need for axis labels in these plots
  title(VesselFigs.DataDisp, 'Data Overlay');
  

  % GUI histogram showing data we are overlaying
  VesselFigs.HistoAx = PPA.VesselGUI.histoAx;
  VesselFigs.Histo = histogram(PPA.VesselGUI.histoAx, NaN, 100);
  VesselFigs.Histo.Normalization = 'countdensity';
  VesselFigs.Histo.FaceColor = Colors.GuiLightOrange;
  VesselFigs.Histo.FaceAlpha = 0.8;
  VesselFigs.Histo.EdgeColor = 'none';

  VesselFigs.HistoAx.YAxis.TickValues = [];
  VesselFigs.HistoAx.YLabel.String = 'Count Density';

  VesselFigs.CBarTile = nexttile(VesselFigs.ResultsTileLayout, [1 1]);
  VesselFigs.Colorbar = colorbar(VesselFigs.CBarTile);
  VesselFigs.Colorbar.Location = 'eastoutside';
  axis off;

  % link all the axis of both the processing and the results figures, so
  % that zooming/panning in one affects all the figures
  linkaxes([VesselFigs.Spline, ...
            VesselFigs.InPlot, ...
            VesselFigs.BinPlot, ...
            VesselFigs.BinCleanPlot ...
            VesselFigs.Skeleton ...
            VesselFigs.DataDisp ...
            ], 'xy');

  PPA.VesselFigs = VesselFigs;
  progressbar(1); % close progbar
  PPA.ProgBar = [];
end
