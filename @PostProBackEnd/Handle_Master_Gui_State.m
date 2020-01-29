function Handle_Master_Gui_State(PPA, stateString)
  % take care of buttons master GUI
  switch stateString
    case 'load_complete'
      % update Volume Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if PPA.isVolData
        PPA.MasterGUI.VolumeProcessingButton.Enable = true;
        PPA.MasterGUI.MapProcessingButton.Enable = false;
        % update volume info status ------------------------------------------------
        PPA.MasterGUI.nXVol.Enable = true;
        PPA.MasterGUI.nYVol.Enable = true;
        PPA.MasterGUI.nZVol.Enable = true;
        PPA.MasterGUI.dXVol.Enable = true;
        PPA.MasterGUI.dYVol.Enable = true;
        PPA.MasterGUI.dZVol.Enable = true;
        PPA.MasterGUI.TotalMemoryEditField.Enable = true;
        % update volume info data --------------------------------------------------
        PPA.MasterGUI.nXVol.Value = PPA.nX;
        PPA.MasterGUI.nYVol.Value = PPA.nY;
        PPA.MasterGUI.nZVol.Value = PPA.nZ;
        PPA.MasterGUI.dXVol.Value = 2;
        PPA.MasterGUI.dYVol.Value = 2;
        PPA.MasterGUI.dZVol.Value = 2;
        volBytes = PPA.Get_Byte_Size_Volumes();
        PPA.MasterGUI.TotalMemoryEditField.Value = ...
          [num2sip(volBytes, 3, false, true) 'B'];

        % auto load next step in processing...
        PPA.processingEnabled = true(); % this will start the raw-processing cascade
        PPA.MasterGUI.Open_Vol_Gui();
      else
        PPA.MasterGUI.VolumeProcessingButton.Enable = false;
        PPA.MasterGUI.VolumeProcessingButton.Enable = false;
        % update volume info status ------------------------------------------------
        PPA.MasterGUI.nXVol.Enable = false;
        PPA.MasterGUI.nYVol.Enable = false;
        PPA.MasterGUI.nZVol.Enable = false;
        PPA.MasterGUI.dXVol.Enable = false;
        PPA.MasterGUI.dYVol.Enable = false;
        PPA.MasterGUI.dZVol.Enable = false;
        PPA.MasterGUI.TotalMemoryEditField.Enable = false;
        % update volume info data --------------------------------------------------
        PPA.MasterGUI.nXVol.Value = -inf;
        PPA.MasterGUI.nYVol.Value = -inf;
        PPA.MasterGUI.nZVol.Value = -inf;
        PPA.MasterGUI.dXVol.Value = -inf;
        PPA.MasterGUI.dYVol.Value = -inf;
        PPA.MasterGUI.dZVol.Value = -inf;
        PPA.MasterGUI.TotalMemoryEditField.Value = '0 B';

        % auto load next step in processing...
        PPA.MasterGUI.Open_Map_Gui();
        PPA.MasterGUI.VolumeProcessingButton.Enable = true;
        PPA.MasterGUI.MapProcessingButton.Enable = true;
      end
  case 'vol_processing_complete'
    % TODO ExportVolumesButton function needs to be implemented
    % after volume processing, we can do map processing
    PPA.MasterGUI.MapProcessingButton.Enable = true; 
    % TODO - Update size info on front panel
  case 'map_processing_complete'
    % TODO ExportVolumesButton function needs to be implemented
    % after volume processing, we can do map processing
    PPA.MasterGUI.MapProcessingButton.Enable = true; 
    % TODO - Update size info on front panel

  case 'default'
  end

 
  if false % get map info here
    % nXMap = PPA.nXF;
    % mapBytes = Get_Byte_Size_Maps();
    % PPA.MasterGUI.TotalMemoryEditField.Value = ...
    %   [num2sip(mapBytes, 3, false, true) 'B'];
  end

  % bring figure windows to front if needed
  figure(PPA.MasterGUI.UIFigure);

  if ~isempty(PPA.VolGUI)
    figure(PPA.VolGUI.UIFigure);
  end

  if ~isempty(PPA.MapGUI)
    figure(PPA.MapGUI.UIFigure);
  end

end
