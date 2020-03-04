function Setup_Vessel_Figures(PPA)

  % setup UI axis for images
  PPA.VesselFigs.MainFig = figure('Name', 'Vessel Pre-Processing', 'NumberTitle', 'off');

  PPA.VesselFigs.InPlot = subplot(2, 2, 1);
    PPA.VesselFigs.InIm = imagesc(nan(1));
    axis image; 
    colormap('gray');
    title('Input Image');

  PPA.VesselFigs.BinPlot = subplot(2, 2, 2);
    PPA.VesselFigs.BinIm = imagesc(nan(1));
    axis image; 
    colormap('gray');
    title('Binarize Image');

  PPA.VesselFigs.BinCleanPlot = subplot(2, 2, 3);
    PPA.VesselFigs.BinCleanIm = imagesc(nan(1));
    axis image; 
    colormap('gray');
    title('Cleaned Binarize Image');
end



