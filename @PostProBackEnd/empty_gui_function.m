function Function_Name_Here(PPA)
  % Function_Name_Here()
  % what is this function doing?
  try
    titleStr = sprintf('');
    d = uiprogressdlg(PPA.LoadGUI.UIFigure, 'Title', titleStr, ...
      'Indeterminate', 'on');
    close(d);
  catch ME
    close(d);
    rethrow(ME);
  end

end
