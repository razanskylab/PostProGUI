function Handle_Master_Gui_State(PPA, stateString)
  % take care of buttons master GUI
  switch stateString
    case 'load_complete'

      if PPA.isVolData
        PPA.MasterGUI.VolumeProcessingButton.Enable = true;
        VolGui(PPA); % auto load next step in processing...
      else
        PPA.MasterGUI.VolumeProcessingButton.Enable = false;
        PPA.LoadGUI.UIFigure.Visible = 'off';
        % VolGui(PPA); % auto load next step in processing...
      end

      PPA.MasterGUI.MapProcessingButton.Enable = true;
    case 'default'

  end
  figure(PPA.MasterGUI.UIFigure);
  if ishandle(PPA.VolGUI)
    figure(PPA.VolGUI.UIFigure);
  end

end
