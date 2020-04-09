function Handle_Master_Gui_State(PPA, stateString)
  % check if this was called without the Master Gui even existing...
  if isempty(PPA.MasterGUI)
    return;
  end
  
  % take care of buttons/info in master GUI
  switch stateString
    case 'load_start'
      control_vol_size_elements(PPA, false); % local function, see below
      control_map_size_elements(PPA, false); % local function, see below

      PPA.MasterGUI.VolumeProcessingButton.Enable = false;
      PPA.MasterGUI.MapProcessingButton.Enable = false;
      PPA.MasterGUI.ExportButton.Enable = false;
      PPA.MasterGUI.VesselAnalysisButton.Enable = false;
    case 'load_complete'
      % update Volume Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      PPA.MasterGUI.FileEditField.Enable = true; 
      PPA.MasterGUI.FileEditField.Value = [PPA.fileName PPA.fileExt]; 

      if PPA.isVolData
        PPA.MasterGUI.VolumeProcessingButton.Enable = true;
        PPA.MasterGUI.MapProcessingButton.Enable = false;
        PPA.MasterGUI.VesselAnalysisButton.Enable = false;
        PPA.MasterGUI.ExportButton.Enable = true;
        % update volume info status ------------------------------------------------
        control_vol_size_elements(PPA, true); % local function, see below
        % update volume info data ------------------------ --------------------------
        update_vol_size_display(PPA); % local function, see below

        % auto load next step in processing...
        PPA.processingEnabled = true(); % this will start the raw-processing cascade
        PPA.MasterGUI.Open_Vol_Gui();
        if PPA.Is_Visible(PPA.VolGUI)
          figure(PPA.VolGUI.UIFigure);
        end
      else
        % update volume info status ------------------------------------------------
        control_vol_size_elements(PPA, false); % local function, see below
        PPA.MasterGUI.MapProcessingButton.Enable = true;
        PPA.MasterGUI.VolumeProcessingButton.Enable = false;
        
        % close map if it's empty, not sure why we need this
        if ~isempty(PPA.MapFig) && ishandle(PPA.MapFig.MainFig)
          close(PPA.MapFig.MainFig);
          PPA.MapFig = [];
        end
        % auto load next step in processing...
        PPA.MasterGUI.Open_Map_Gui();

        if PPA.Is_Visible(PPA.MapGUI) 
          figure(PPA.MapGUI.UIFigure);
        end
      end

      % update export name if you choose to do so...
      if ~isempty(PPA.ExportGUI) && (PPA.ExportGUI.UseFileName.Value)
        PPA.ExportGUI.expFileName.Value = PPA.fileName;
      end

      % make sure all images are displayed fully -> axis tight on all axis
      make_axis_tight(PPA); % see below

    case 'vol_processing_complete'
      % after volume processing, we can do map processing
      PPA.MasterGUI.MapProcessingButton.Enable = true;
      update_vol_size_display(PPA); % local function, see below
      control_map_size_elements(PPA, true); % local function, see below
      PPA.MasterGUI.ExportButton.Enable = true;
      figure(PPA.VolGUI.UIFigure);

    case 'map_processing_complete'
      PPA.MasterGUI.ExportButton.Enable = true;
      PPA.MasterGUI.VesselAnalysisButton.Enable = true;
      update_map_size_display(PPA); % local function, see below
      figure(PPA.MapGUI.UIFigure);
    case 'default'
  end

  % bring figure windows to front if needed
  % for all but master gui, also check if they are visible, as otherwise
  % they will be made visible, which we don't want
  figure(PPA.MasterGUI.UIFigure);
end

% enable/disable volume size indicators ----------------------------------------
function control_vol_size_elements(PPA, enabled)
  PPA.MasterGUI.nXVol.Enable = enabled;
  PPA.MasterGUI.nYVol.Enable = enabled;
  PPA.MasterGUI.nZVol.Enable = enabled;
  PPA.MasterGUI.dXVol.Enable = enabled;
  PPA.MasterGUI.dYVol.Enable = enabled;
  PPA.MasterGUI.dZVol.Enable = enabled;
  PPA.MasterGUI.VolMemory.Enable = enabled;
  PPA.MasterGUI.VolResoLabel_2.Enable = enabled;

  if ~enabled
    % update volume info data --------------------------------------------------
    PPA.MasterGUI.nXVol.Value = -inf;
    PPA.MasterGUI.nYVol.Value = -inf;
    PPA.MasterGUI.nZVol.Value = -inf;
    PPA.MasterGUI.dXVol.Value = -inf;
    PPA.MasterGUI.dYVol.Value = -inf;
    PPA.MasterGUI.dZVol.Value = -inf;
    PPA.MasterGUI.VolMemory.Value = '0 B';
  end

end

% update volume info data --------------------------------------------------
function update_vol_size_display(PPA)
  PPA.MasterGUI.nXVol.Value = PPA.nX;
  PPA.MasterGUI.nYVol.Value = PPA.nY;
  PPA.MasterGUI.nZVol.Value = PPA.nZ;
  PPA.MasterGUI.dXVol.Value = PPA.dX*1e3;
  PPA.MasterGUI.dYVol.Value = PPA.dY * 1e3;
  PPA.MasterGUI.dZVol.Value = PPA.dZ * 1e3;
  volBytes = PPA.Get_Byte_Size_Volumes();
  PPA.MasterGUI.VolMemory.Value = ...
    [num2sip(volBytes, 3, false, true) 'B'];
end

% enable/disable volume size indicators ----------------------------------------
function control_map_size_elements(PPA, enabled)
  PPA.MasterGUI.nXMap.Enable = enabled;
  PPA.MasterGUI.nYMap.Enable = enabled;
  PPA.MasterGUI.dXIm.Enable = enabled;
  PPA.MasterGUI.dYIm.Enable = enabled;
  PPA.MasterGUI.MapMemory.Enable = enabled;
  PPA.MasterGUI.MapResoLabelUnit.Enable = enabled;

  if ~enabled
    % update volume info data --------------------------------------------------
    PPA.MasterGUI.nXMap.Value = -inf;
    PPA.MasterGUI.nYMap.Value = -inf;
    PPA.MasterGUI.dXIm.Value = -inf;
    PPA.MasterGUI.dYIm.Value = -inf;
    PPA.MasterGUI.MapMemory.Value = '0 B';
  end

end

% update map info data --------------------------------------------------
function update_map_size_display(PPA)
  PPA.MasterGUI.nXMap.Value = PPA.nXIm;
  PPA.MasterGUI.nYMap.Value = PPA.nYIm;
  PPA.MasterGUI.dXIm.Value = PPA.dXIm * 1e3;
  PPA.MasterGUI.dYIm.Value = PPA.dYIm * 1e3;
  mapBytes = PPA.Get_Byte_Size_Maps();
  PPA.MasterGUI.MapMemory.Value = ...
    [num2sip(mapBytes, 3, false, true) 'B'];
end

% update map info data --------------------------------------------------
function make_axis_tight(PPA)
  % make map images tight
  if ~isempty(PPA.MapFig) && ishandle(PPA.MapFig.MainFig)
    figure(PPA.MapFig.MainFig);
    axis tight;
  end
  % make frangi images tight for map processing
  if ~isempty(PPA.MapFrangi) && ishandle(PPA.MapFrangi.FigHandles.MainFig)
    figure(PPA.MapFrangi.FigHandles.MainFig);
    axis tight;
  end

  % make vessel analysis images tight
  if ~isempty(PPA.VesselFigs) && ishandle(PPA.VesselFigs.MainFig)
    figure(PPA.VesselFigs.MainFig);
    axis tight;
  end
  if ~isempty(PPA.VesselFigs) && ishandle(PPA.VesselFigs.ResultsFig)
    figure(PPA.VesselFigs.ResultsFig);
    axis tight;
  end

  % make frangi images tight for vessel analysis
  if ~isempty(PPA.VesselFrangi) && ishandle(PPA.VesselFrangi.FigHandles.MainFig)
    figure(PPA.VesselFrangi.FigHandles.MainFig);
    axis tight;
  end

end