function Load_Raw_Data(PPA)
  % Load_Raw_Data()
  try

    % check we actually have a valid file to load
    if ~PPA.fileExists
      % if we get this error, something really went wrong....
      error('File does not exist!');
    end

    progBarStr = sprintf('Loading raw data %s\n', PPA.fileName);
    ProgBar = uiprogressdlg(PPA.LoadGUI.UIFigure, 'Title', progBarStr, ...
      'Indeterminate', 'on');
    PPA.Update_Status(progBarStr);

    % disable automatic raw volume processing cascade
    PPA.processingEnabled = false; % this will start the raw-processing cascade

    % clean out old data -------------------------------------------------------
    if ~isempty(PPA.FraFilt)
      PPA.FraFilt.raw = [];
      PPA.FraFilt.filt = [];
      PPA.FraFilt.filtScales = [];
      PPA.FraFilt.fusedFrangi = [];
    end

    PPA.rawVol = [];
    PPA.procVolProj = [];
    PPA.depthInfo = [];
    PPA.rawDepthInfo = [];
    PPA.procProj = [];

    % fill in new data -------------------------------------------------------
    switch PPA.fileType
      case 0% no file, so we try loading from workspace
        PPA.x = evalin('base', 'x');
        PPA.y = evalin('base', 'y');

        if PPA.isVolData% we have volume data, so use it!
          PPA.dt = evalin('base', 'dt');
          PPA.z = evalin('base', 'z');
          PPA.rawVol = evalin('base', 'volData');
          PPA.rawVol = permute(single(PPA.rawVol), [3 1 2]);
        else % map data

          if ismember('mapRaw', PPA.MatFileVars)% new map data
            PPA.procVolProj = single(evalin('base', 'mapRaw'));
          elseif ismember('map', PPA.MatFileVars)% old map data
            PPA.procVolProj = single(evalin('base', 'map'));
          end

        end

        % check if we have a depth map as well?
        if ~PPA.isVolData && evalin('base', 'exist("depthMap")');
          % for map data, we require a
          PPA.depthInfo = single(evalin('base', 'depthMap'));
          PPA.rawDepthInfo = single(evalin('base', 'depthMap'));
        end

      case 1% normal mat file
        PPA.x = PPA.MatFile.x;
        PPA.y = PPA.MatFile.y;

        if PPA.isVolData% we have volume data, so use it!
          PPA.dt = PPA.MatFile.dt;
          PPA.z = PPA.MatFile.z;
          PPA.rawVol = permute(single(PPA.MatFile.volData), [3 1 2]);
        else

          if ismember('mapRaw', PPA.MatFileVars)% new map data
            PPA.procVolProj = single(PPA.MatFile.mapRaw);
          elseif ismember('map', PPA.MatFileVars)% old map data
            PPA.procVolProj = single(PPA.MatFile.map'); % transpose needed!
          end

        end

        % check if we have a depth map as well?
        if ~PPA.isVolData && ismember('depthMap', PPA.MatFileVars)
          % for map data, we require a
          PPA.depthInfo = single(PPA.MatFile.depthMap); % needs to be set before procVolProj!
          PPA.rawDepthInfo = single(PPA.MatFile.depthMap); % only set when loading for 2d data
        end

      case 2% mVolume file
        ProgBar.Message = 'Loading volDataset class...';
        PPA.Update_Status(ProgBar.Message);

        volDataClass = PPA.MatFile.volDataset; % this takes quite a bit of time...
        PPA.x = volDataClass.vecX * 1e3;
        PPA.y = volDataClass.vecY * 1e3;
        PPA.z = volDataClass.vecZ * 1e3; % vol class always has z-vector (I hope)
        PPA.dt = volDataClass.dZ * 1e-3;
        PPA.rawVol = volDataClass.vol;
      case 3%  tiff stack
      case 4% image file
    end

    close(ProgBar);
    PPA.Handle_Master_Gui_State('load_complete');

  catch ME
    close(ProgBar);
    rethrow(ME);
  end

end
