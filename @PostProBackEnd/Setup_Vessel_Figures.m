function Setup_Vessel_Figures(PPA)

  % setup UI axis for images
  PPA.VesselFigs.MainFig = figure('Name', 'Vessel Pre-Processing', ...
                                  'NumberTitle', 'off');

  % user can't close the window manually, needs to close the GUI
  PPA.VesselFigs.MainFig.CloseRequestFcn = []; 

  % add zoom callback, so that all panels zoom when one panel is zoomed
  PPA.VesselFigs.ZoomH = zoom(PPA.VesselFigs.MainFig);
  PPA.VesselFigs.ZoomH.ActionPostCallback = @PostVesselZoomCallback;
  PPA.VesselFigs.MainFig.UserData = PPA;

  PPA.VesselFigs.InPlot = subplot(2, 2, 1);
    PPA.VesselFigs.InIm = imagesc(nan(1));
    axis image; 
    axis off; % no need for axis labels in these plots
    colormap('gray');
    title('Input Image');

  PPA.VesselFigs.BinPlot = subplot(2, 2, 2);
    PPA.VesselFigs.BinIm = imagesc(nan(1));
    axis image; 
    axis off; % no need for axis labels in these plots
    colormap('gray');
    title('Binarize Image');

  PPA.VesselFigs.BinCleanPlot = subplot(2, 2, 3);
    PPA.VesselFigs.BinCleanIm = imagesc(nan(1));
    axis image; 
    axis off; % no need for axis labels in these plots
    colormap('gray');
    title('Cleaned Binarize Image');
end



