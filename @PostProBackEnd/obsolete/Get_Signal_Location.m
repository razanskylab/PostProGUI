function Get_Signal_Location(PPA)
  % open new figure window where user can select point to plot depth data

  locIdx = [round(PPA.nX./2) round(PPA.nY./2)];
  x = 1:PPA.nX;
  y = 1:PPA.nY;
  % fig = uifigure('Position',[50 50 800 800]);
  % fig.Resize = 'off';

% Create UIFigure and hide until all components are created
  UIFigure = uifigure('Visible', 'off');
  UIFigure.Color = [0.94 0.94 0.94];
  UIFigure.Position = [100 100 590 600];
  UIFigure.Name = 'UI Figure';
  UIFigure.Resize = 'on';

  % Create Panel
  ImPanel = uipanel(UIFigure);
  ImPanel.Position = [1 141 590 460];

  % Create DepthSignalPanel
  DepthSignalPanel = uipanel(UIFigure);
  DepthSignalPanel.Title = 'Depth Signal';
  DepthSignalPanel.Position = [1 1 470 140];

  % Create DoneButton
  DoneButton = uibutton(UIFigure, 'push',...
    'ButtonPushedFcn', @(btn,event) plotButtonPushed(btn,UIFigure));
  DoneButton.Position = [482 109 100 22];
  DoneButton.Text = 'Done';

  % Show the figure after all components are created
  UIFigure.Visible = 'on';

  % generate image axis in image panel
  imAx = axes(ImPanel,'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1]);
  imAx.PickableParts = 'none';
  axis(imAx,'tight');
  imagesc(imAx,x,y,PPA.procProj);
  axis(imAx,'image');

    % generate depth signal
  depthAx = axes(DepthSignalPanel);
  depthAx.PickableParts = 'none';
  depthSig = squeeze(PPA.procVol(locIdx(1),locIdx(2),:));
  dPlot = plot(depthAx,PPA.zPlot,depthSig);
  axis(depthAx,'tight');

  PointH = drawpoint(imAx, 'Position', locIdx);
  colormap(imAx,PPA.GUI.cBars.Value); % use same colormap as main app
  oldLoc = locIdx;

  while ishandle(UIFigure)
    newLoc = round(PointH.Position);
    if ~isequal(newLoc,oldLoc)
        depthSig = squeeze(PPA.procVol(newLoc(1),newLoc(2),:));
        set(dPlot,'ydata',depthSig);
        oldLoc = newLoc;
    end
    drawnow limitrate
    pause(0.01); % don't loop with 100% cpu
  end
  PPA.locIdx = newLoc;

   % Create the function for the ButtonPushedFcn callback
  function plotButtonPushed(btn,ax)
    close(UIFigure);
  end
end
