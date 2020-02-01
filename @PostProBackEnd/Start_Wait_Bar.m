function Start_Wait_Bar(PPA, CallingGui, waitBarText)
  % handles wait bars for all open GUI windows, so that one displays the current 
  % status and the other ones are blocked, as to not let the user do multiple 
  % things at once....
  PPA.ProgBar = [];
  
  % start Indeterminate progress bar
  PPA.ProgBar{1} = uiprogressdlg(CallingGui.UIFigure, 'Title', waitBarText, ...
    'Indeterminate', 'on');

  % if ~isempty(PPA.VolGUI) && set_this_gui(PPA.VolGUI, CallingGui)% set_this_gui is local (see below)
  %   PPA.ProgBar{end + 1} = uiprogressdlg(PPA.VolGUI.UIFigure, ...
  %     'Title', 'Busy', 'Indeterminate', 'on');
  % end

  % if ~isempty(PPA.LoadGUI) && set_this_gui(PPA.LoadGUI, CallingGui)
  %   PPA.ProgBar{end + 1} = uiprogressdlg(PPA.LoadGUI.UIFigure, ...
  %     'Title', 'Busy', 'Indeterminate', 'on');
  % end

  % LoadGUI; % handle to app for loading raw files
  % VolGUI;
  % MapGUI;
  PPA.Update_Status(waitBarText);
  drawnow();
end

function setVolGui = set_this_gui(TestGui, CallingGui)
  % find out what UI figure we have, so we don't set that prog bar twice
  setVolGui = strcmp(TestGui.UIFigure.Visible, 'on') && ...
   ~(TestGui == CallingGui);
end