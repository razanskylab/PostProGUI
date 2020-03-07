function Setup_Map_Figure(PPA)
  % setup UI axis for images
  fHandle = figure('Name', 'Map Processing', 'NumberTitle', 'off');
  % make figure fill half the screen
  set(fHandle, 'Units', 'Normalized', 'OuterPosition', [0 0 0.5 1]);
  % move figure over a little to the right of the vessel GUI
  fHandle.Units = 'pixels';
  fHandle.OuterPosition(1) = PPA.MapGUI.UIFigure.Position(1) + PPA.MapGUI.UIFigure.Position(3);
  FigHandles.MainFig = fHandle;
  FigHandles.TileLayout = tiledlayout(1, 2);
  FigHandles.TileLayout.Padding = 'compact'; % remove uneccesary white space...

  % user can't close the window manually, needs to close the GUI
  FigHandles.MainFig.CloseRequestFcn = [];

  emptyImage = nan(size(PPA.procVolProj));

  FigHandles.MapAx = nexttile;
  FigHandles.MapIm = imagesc(PPA.yPlot,PPA.xPlot,emptyImage);
  axis image;
  axis tight;
  colormap(PPA.MasterGUI.cBars.Value);
  title('Processed Map');

  FigHandles.DepthAx = nexttile;
  FigHandles.DepthIm = imagesc(PPA.yPlot,PPA.xPlot,emptyImage);
  axis image;
  axis tight;
  colormap(PPA.MasterGUI.cBars.Value);
  title('Processed Depth-Map');

  linkaxes([FigHandles.MapAx, ...
            FigHandles.DepthAx, ...
            ], 'xy');
  PPA.MapFig = FigHandles;
end
