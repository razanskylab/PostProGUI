function Setup_Vessel_Figures(PPA)

  % setup UI axis for images
  fHandle = figure('Name', 'Vessel Pre-Processing', 'NumberTitle', 'off');
  % make figure fill half the screen
  set(fHandle, 'Units', 'Normalized', 'OuterPosition', [0 0 0.5 1]);
  % move figure over a little to the right of the vessel GUI
  fHandle.Units = 'pixels';
  fHandle.OuterPosition(1) = PPA.VesselGUI.UIFigure.Position(1) + PPA.VesselGUI.UIFigure.Position(3);
  VesselFigs.MainFig = fHandle; 
  VesselFigs.TileLayout = tiledlayout(3, 4);
  VesselFigs.TileLayout.Padding = 'compact'; % remove uneccesary white space...

  % user can't close the window manually, needs to close the GUI
  VesselFigs.MainFig.CloseRequestFcn = [];

  emptyImage = nan(size(PPA.procProj));
  VesselFigs.InPlot = nexttile;
  VesselFigs.InIm = imagesc(emptyImage);
  axis image;
  axis tight;
  axis off; % no need for axis labels in these plots
  colormap(PPA.MasterGUI.cBars.Value);
  title('Input Image');

  VesselFigs.BinPlot = nexttile;
  VesselFigs.BinIm = imagesc(emptyImage);
  axis image;
  axis tight;
  axis off; % no need for axis labels in these plots
  colormap(PPA.MasterGUI.cBars.Value);
  title('Binarized Image');

  VesselFigs.BinCleanPlot = nexttile;
  VesselFigs.BinCleanIm = imagesc(emptyImage);
  axis image;
  axis tight;
  axis off; % no need for axis labels in these plots
  colormap(PPA.MasterGUI.cBars.Value);
  title('Cleaned Binarized Image');

  % skeleton image with branches
  VesselFigs.Skeleton = nexttile;
  VesselFigs.SkeletonImBack = imagesc(emptyImage);
  axis image;
  axis tight;
  axis off; % no need for axis labels in these plots
  colormap(PPA.MasterGUI.cBars.Value);
  hold on;
  VesselFigs.SkeletonImFront = imshow(nan(1));
  VesselFigs.SkeletonScat = scatter([NaN], [NaN]);
  VesselFigs.SkeletonScat.LineWidth = 1.0;
  VesselFigs.SkeletonScat.MarkerEdgeAlpha = 0; % no marger edge
  VesselFigs.SkeletonScat.MarkerFaceColor = Colors.DarkOrange; % no marger edge
  VesselFigs.SkeletonScat.SizeData = 20; % no marger edge
  hold off;
  title('Skeletonized Image');

  % spline fitted with branches ------------------------------------------------
  VesselFigs.Spline = nexttile([2 2]);
  VesselFigs.SplineImBack = imagesc(emptyImage);
  axis image;
  axis tight;
  axis off; % no need for axis labels in these plots
  colormap(PPA.MasterGUI.cBars.Value);
  hold on;
  VesselFigs.SplineScat = scatter([NaN], [NaN]);
  VesselFigs.SplineScat.LineWidth = 1.0;
  VesselFigs.SplineScat.MarkerEdgeAlpha = 0; % no marger edge
  VesselFigs.SplineScat.MarkerFaceColor = Colors.DarkOrange; % no marger edge
  VesselFigs.SplineScat.SizeData = 20; % no marger edge

  VesselFigs.SplineLine = line(NaN, NaN);
  VesselFigs.SplineLine.LineStyle = '-';
  VesselFigs.SplineLine.Color = Colors.PureRed;
  VesselFigs.SplineLine.LineWidth = 2;

  VesselFigs.LEdgeLines = line(NaN, NaN);
  VesselFigs.LEdgeLines.LineStyle = '--';
  VesselFigs.LEdgeLines.Color = Colors.PureRed;
  VesselFigs.LEdgeLines.LineWidth = 1.5;
  VesselFigs.REdgeLines = line(NaN, NaN);
  VesselFigs.REdgeLines.LineStyle = '--';
  VesselFigs.REdgeLines.Color = Colors.PureRed;
  VesselFigs.REdgeLines.LineWidth = 1.5;
  hold off;
  title('Spline Fitted Image');
  legend({'Branch Points', 'Centerlines', 'Edges'});

  % angles overlay? ------------------------------------------------------------
  VesselFigs.Angles = nexttile([2 2]);
  VesselFigs.AnglesImBack = imagesc(emptyImage);
  axis image;
  axis tight;
  axis off; % no need for axis labels in these plots
  colormap(PPA.MasterGUI.cBars.Value);
  hold on;
  VesselFigs.AnglesScat = scatter([NaN], [NaN]);
  hold off;
  title('Angles TODO');


  linkaxes([VesselFigs.Spline, ...
            VesselFigs.InPlot, ...
            VesselFigs.BinPlot, ...
            VesselFigs.BinCleanPlot ...
            VesselFigs.Skeleton ...
            VesselFigs.Angles ...
            ], 'xy');
  PPA.VesselFigs = VesselFigs;
end
