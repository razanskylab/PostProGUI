function Setup_Map_Figure(PPA)
  % get to colorbar to use
  if isempty(PPA.MasterGUI)
    FH.cbar = gray(256);
  else
    FH.cbar = PPA.MasterGUI.cBars.Value;
    eval(['FH.cbar = ' FH.cbar '(256);']); % turn string to actual colormap matrix
  end

  % check if we have been provided with raw depth info, so we have something
  % to plot later, if not, don't show 2nd plot tile
  hasDeptMap = ~isempty(PPA.rawDepthInfo);

  % setup UI axis for images
  fHandle = figure('Name', 'Fig Map', 'NumberTitle', 'off');
  % make figure fill half the screen
  set(fHandle, 'Units', 'Normalized', 'OuterPosition', [0 0 0.25 0.35]);
  % move figure over a little to the right of the vessel GUI
  fHandle.Units = 'pixels';
  MapGuiPos = PPA.MapGUI.UIFigure.OuterPosition;
  % x-pos = right of map gui
  fHandle.OuterPosition(1) = MapGuiPos(1) + MapGuiPos(3);
  % y-pos = same height as mapgui
  fHandle.OuterPosition(2) = MapGuiPos(2) + MapGuiPos(4) - ...
  fHandle.OuterPosition(4) + 45;
  FH.MainFig = fHandle;

  if hasDeptMap
    FH.TileLayout = tiledlayout(fHandle,1, 2);
  else
    FH.TileLayout = tiledlayout(fHandle,1, 1);
  end 
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


  if hasDeptMap
    FH.DepthAx = nexttile;
    FH.DepthIm = imagesc(FH.DepthAx, PPA.yPlot, PPA.xPlot, emptyImage);
    axis(FH.DepthAx, 'image');
    axis(FH.DepthAx, 'tight');
    colormap(FH.DepthAx, FH.cbar);
    title(FH.DepthAx, 'Processed Depth-Map');

    linkaxes([FH.MapAx, ...
              FH.DepthAx, ...
              ], 'xy');
  end

  PPA.MapFig = FH;
end
