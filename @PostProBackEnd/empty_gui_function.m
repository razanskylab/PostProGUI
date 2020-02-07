function empty_gui_function(PPA)
  % Function_Name_Here()
  % what is this function doing?
  try
    % PPA.Start_Wait_Bar(PPA.LoadGUI, 'test')
    PPA.Start_Wait_Bar(PPA.App, 'test')
    
  catch ME
    PPA.Stop_Wait_Bar();
    rethrow(ME);
  end

end