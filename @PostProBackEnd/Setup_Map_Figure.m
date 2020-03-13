function Setup_Map_Figure(PPA)
  % get to colorbar to use
  if isempty(PPA.MasterGUI)
    FH.cbar = gray(256);
  else
    FH.cbar = PPA.MasterGUI.cBars.Value;
    eval(['FH.cbar = ' FH.cbar '(256);']); % turn string to actual colormap matrix
  end

  % setup UI axis for images
  fHandle = figure('Name', 'Figure: Map Processing', 'NumberTitle', 'off');
  % make figure fill half the screen
  set(fHandle, 'Units', 'Normalized', 'OuterPosition', [0 0 0.5 1]);
  % move figure over a little to the right of the vessel GUI
  fHandle.Units = 'pixels';
  fHandle.OuterPosition(1) = PPA.MapGUI.UIFigure.Position(1) + PPA.MapGUI.UIFigure.Position(3);
  FH.MainFig = fHandle;
  FH.TileLayout = tiledlayout(fHandle,1, 2);
  FH.TileLayout.Padding = 'compact'; % remove uneccesary white space...

  FH.MainFig.UserData = PPA.MapGUI; % need that in Gui_Close_Request callback
  FH.MainFig.CloseRequestFcn = @Gui_Close_Request;

  emptyImage = nan(size(PPA.procVolProj));

  FH.MapAx = nexttile;
  FH.MapIm = imagesc(FH.MapAx, PPA.yPlot, PPA.xPlot, emptyImage);
  axis(FH.MapAx, 'image');
  axis(FH.MapAx, 'tight');
  colormap(FH.MapAx, FH.cbar);
  title(FH.MapAx, 'Processed Map');

  FH.DepthAx = nexttile;
  FH.DepthIm = imagesc(FH.DepthAx, PPA.yPlot, PPA.xPlot, emptyImage);
  axis(FH.DepthAx, 'image');
  axis(FH.DepthAx, 'tight');
  colormap(FH.DepthAx, FH.cbar);
  title(FH.DepthAx, 'Processed Depth-Map');

  linkaxes([FH.MapAx, ...
            FH.DepthAx, ...
            ], 'xy');
  PPA.MapFig = FH;
end
