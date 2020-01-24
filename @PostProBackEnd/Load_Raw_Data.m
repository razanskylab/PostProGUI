function Load_Raw_Data(PPA)
  % Load_Raw_Data()
  try

    % check we actually have a valid file to load
    if ~PPA.fileExists
      % if we get this error, something really went wrong....
      error('File does not exist!');
    end

    if ~PPA.fileType
      % if we get this error, something also went wrong....
      error('File format not correct!');
    end

    progBarStr = sprintf('Loading raw data %s', PPA.fileName);
    ProgBar = uiprogressdlg(PPA.LoadGUI.UIFigure, 'Title', progBarStr, ...
      'Indeterminate', 'on');

    % clean out old data
    PPA.frangiFilt = [];
    PPA.frangiScales = [];
    PPA.frangiCombo = [];
    PPA.rawVol = [];
    PPA.procVolProj = [];
    PPA.depthInfo = [];
    PPA.rawDepthInfo = [];

    switch PPA.fileType
      case 1% normal mat file
        PPA.x = PPA.MatFile.x;
        PPA.y = PPA.MatFile.y;

        if PPA.isVolData% we have volume data, so use it!
          PPA.dt = PPA.MatFile.dt;
          PPA.z = PPA.MatFile.z;
          PPA.rawVol = permute(single(PPA.MatFile.volData), [3 1 2]);
        end

        if ismember('mapRaw', PPA.MatFileVars)% new map data
          PPA.procVolProj = single(PPA.MatFile.mapRaw);
        elseif ismember('map', PPA.MatFileVars)% old map data
          PPA.procVolProj = single(PPA.MatFile.map'); % transpose needed!
        end

        % check if we have a depth map as well?
        if ~PPA.isVolData && ismember('depthMap', PPA.MatFileVars)
          % for map data, we require a
          PPA.depthInfo = single(PPA.MatFile.depthMap); % needs to be set before procVolProj!
          PPA.rawDepthInfo = single(PPA.MatFile.depthMap); % only set when loading for 2d data
        end

      case 2% mVolume file
        ProgBar.Message = 'Loading volDataset class...';
        volDataClass = PPA.MatFile.volDataset; % this takes quite a bit of time...
        PPA.x = volDataClass.vecX * 1e3;
        PPA.y = volDataClass.vecY * 1e3;
        PPA.z = volDataClass.vecZ * 1e3; % vol class always has z-vector (I hope)
        PPA.dt = volDataClass.dZ * 1e-3;
        PPA.rawVol = volDataClass.vol;
      case 3%  tiff stack
      case 4% image file
    end

    PPA.Handle_Master_Gui_State('load_complete');

    close(ProgBar);
  catch ME
    close(ProgBar);
    rethrow(ME);
  end

end
