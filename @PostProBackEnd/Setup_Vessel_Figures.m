function Setup_Vessel_Figures(PPA)

  % setup UI axis for images
  VesselFigs.MainFig = figure('Name', 'Vessel Pre-Processing', ...
                                  'NumberTitle', 'off');

  % user can't close the window manually, needs to close the GUI
  VesselFigs.MainFig.CloseRequestFcn = []; 

  % add zoom callback, so that all panels zoom when one panel is zoomed
  VesselFigs.ZoomH = zoom(VesselFigs.MainFig);
  VesselFigs.ZoomH.ActionPostCallback = @PostVesselZoomCallback;
  VesselFigs.MainFig.UserData = PPA;

  VesselFigs.InPlot = subplot(2, 3, 1);
    VesselFigs.InIm = imagesc(nan(1));
    axis image;
    axis tight; 
    axis off; % no need for axis labels in these plots
    colormap('gray');
    title('Input Image');

  VesselFigs.BinPlot = subplot(2, 3, 2);
    VesselFigs.BinIm = imagesc(nan(1));
    axis image;
    axis tight; 
    axis off; % no need for axis labels in these plots
    colormap('gray');
    title('Binarized Image');

  VesselFigs.BinCleanPlot = subplot(2, 3, 3);
    VesselFigs.BinCleanIm = imagesc(nan(1));
    axis image;
    axis tight; 
    axis off; % no need for axis labels in these plots
    colormap('gray');
    title('Cleaned Binarized Image');

  % skeleton image with branches
  VesselFigs.Skeleton = subplot(2, 3, 4);
    VesselFigs.SkeletonImBack = imagesc(nan(1));
    axis image;
    axis tight;
    axis off; % no need for axis labels in these plots
    colormap('gray');
    hold on;
    VesselFigs.SkeletonImFront = imshow(nan(1));
    VesselFigs.SkeletonScat = scatter([NaN],[NaN]);
    VesselFigs.SkeletonScat.LineWidth = 1.0;
    VesselFigs.SkeletonScat.MarkerEdgeAlpha = 0; % no marger edge
    VesselFigs.SkeletonScat.MarkerFaceColor = Colors.DarkOrange; % no marger edge
    VesselFigs.SkeletonScat.SizeData = 20; % no marger edge
    hold off;
    title('Skeletonized Image');

  % spline fitted with branches
  VesselFigs.Spline = subplot(2, 3, 5);
    VesselFigs.SplineImBack = imagesc(nan(1));
    axis image;
    axis tight;
    axis off; % no need for axis labels in these plots
    colormap('gray');
    hold on;
    VesselFigs.SplineScat = scatter([NaN], [NaN]);
    VesselFigs.SplineScat.LineWidth = 1.0;
    VesselFigs.SplineScat.MarkerEdgeAlpha = 0; % no marger edge
    VesselFigs.SplineScat.MarkerFaceColor = Colors.DarkOrange; % no marger edge
    VesselFigs.SplineScat.SizeData = 20; % no marger edge

    VesselFigs.SplineLine = line(NaN,NaN);
    VesselFigs.SplineLine.LineStyle = '-';
    VesselFigs.SplineLine.Color = Colors.PureRed;
    VesselFigs.SplineLine.LineWidth = 2;

    VesselFigs.LEdgeLines = line(NaN,NaN);
    VesselFigs.LEdgeLines.LineStyle = '--';
    VesselFigs.LEdgeLines.Color = Colors.PureRed;
    VesselFigs.LEdgeLines.LineWidth = 1.5;
    VesselFigs.REdgeLines = line(NaN,NaN);
    VesselFigs.REdgeLines.LineStyle = '--';
    VesselFigs.REdgeLines.Color = Colors.PureRed;
    VesselFigs.REdgeLines.LineWidth = 1.5;


    hold off;
    title('Spline Fitted Image');
    legend({'Branch Points', 'Centerlines', 'Edges'});

    PPA.VesselFigs = [];
    PPA.VesselFigs = VesselFigs;
end



