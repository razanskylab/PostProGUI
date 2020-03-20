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
    if ~isempty(PPA.MapFrangi)
      PPA.MapFrangi.raw = [];
      PPA.MapFrangi.filt = [];
      PPA.MapFrangi.filtScales = [];
      PPA.MapFrangi.fusedFrangi = [];
    end
    if ~isempty(PPA.VesselFrangi)
      PPA.VesselFrangi.raw = [];
      PPA.VesselFrangi.filt = [];
      PPA.VesselFrangi.filtScales = [];
      PPA.VesselFrangi.fusedFrangi = [];
    end

    PPA.rawVol = [];
    PPA.procVolProj = [];
    PPA.depthInfo = [];
    PPA.rawDepthInfo = [];
    PPA.procProj = [];

    % fill in new data -------------------------------------------------------
    switch PPA.fileType
      case 0% no file, so we try loading from workspace ------------------------
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
        if ~PPA.isVolData && evalin('base', 'exist("depthMap")')
          % for map data, we require a
          PPA.depthInfo = single(evalin('base', 'depthMap'));
          PPA.rawDepthInfo = single(evalin('base', 'depthMap'));
        end

      case 1% normal mat file --------------------------------------------------
        PPA.x = PPA.MatFile.x;
        PPA.y = PPA.MatFile.y;

        if PPA.isVolData% we have volume data, so use it!
          PPA.dt = PPA.MatFile.dt;
          PPA.z = PPA.MatFile.z;
          % NOTE rawVol stored in order [z x y] for performance!
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

      case 2% mVolume file -----------------------------------------------------
        ProgBar.Message = 'Loading volDataset class...';
        PPA.Update_Status(ProgBar.Message);

        volDataClass = PPA.MatFile.volDataset; % this takes quite a bit of time...
        PPA.x = volDataClass.vecX * 1e3;
        PPA.y = volDataClass.vecY * 1e3;
        PPA.z = volDataClass.vecZ * 1e3; % vol class always has z-vector (I hope)
        PPA.dt = volDataClass.dZ * 1e-3;
        PPA.rawVol = volDataClass.vol;
      case 3%  tiff stack
        ProgBar.Message = 'Loading tiff stack...';
        [dx,dy,dz,dt,nCh,ch] = get_vol_info_from_user();
        tempVol = single(tiff_to_mat(PPA.filePath));
        if nCh > 1
          % if channels are interleaved, we start at channel ch and take every 
          % nth channel
          tempVol = tempVol(:,:,ch:nCh:end);
        end
        PPA.rawVol = permute(single(tempVol), [3 1 2]);
          % NOTE rawVol stored in order [z x y] for performance!
        [nX, nY, nZ] = size(tempVol);
        PPA.x = (0:(nX-1)).*dx;
        PPA.y = (0:(nY-1)).*dy;
        PPA.z = (0:(nZ-1)).*dz;
        PPA.dt = dt;
      case 4% image file
    end

    close(ProgBar);
    PPA.Handle_Master_Gui_State('load_complete');

  catch ME
    close(ProgBar);
    rethrow(ME);
  end

end

function [dx,dy,dz,dt,nCh,ch] = get_vol_info_from_user()
  answer = NaN; 
  prompt = {'dx:','dy:','dz:','# Channels:','use channel:'};
  dlgtitle = 'Manually enter volume size!';
  dims = [1 1 1 1 1];
  definput = {'1','1','1','1','1'};
  while any(isnan(answer))
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    answer = str2double(answer); % everything not a number will be NaN!
  end
  dx = answer(1);
  dy = answer(2);
  dz = answer(3);
  dt = 1./(250e6); % kinda arb. dt, as it depends on speed of sound etc...
  nCh = answer(4); % number of channels for de-interlacing
  ch = answer(5); % which channel to use?
end