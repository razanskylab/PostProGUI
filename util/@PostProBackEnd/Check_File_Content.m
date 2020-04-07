function [isValidFile, needsInfo] = Check_File_Content(PPA)
  % Check_File_Content()

  PPA.MatFile = [];
  PPA.FileContent = [];
  PPA.fileType = 0; 
  PPA.MatFileVars = [];
  % 0 = invalid file, 1 = mat file, 2 = mVolume file, 3 = tiff stack, 4 = image file
  needsInfo = false;
  %TODO
  % add check and functionality of these file types
  % tiff file with single tiff or tiff stack
  % other 2d image files, i.e. jpg, png, ???
  % isTiffStack = false; %Todo load tiff stack as volume
  % isImFile = false; % Todo load 2d tiff, jpg, png
  % isMatFile = false; % Todo load 2d tiff, jpg, png

  % check what file type we are loading
  switch PPA.fileExt
    case '.mat'
      % check if the file we are previewing / loading has all the required infos...
      PPA.fileType = 1; % 1 = mat file

      PPA.MatFileVars = who('-file', PPA.filePath);
      PPA.MatFile = matfile(PPA.filePath);
      PPA.FileContent = whos(PPA.MatFile);

      % check for a valid file containing map or vol data %%%%%%%%%%%%%%%%%%%%%%%%%%

      % check if this dataset is based on the "new" volDataset class
      % https://github.com/hofmannu/MVolume
      %       isMVolume = ismember('volDataset', PPA.MatFileVars);
      isMVolume = strcmp(PPA.FileContent(1).class, 'VolumetricDataset');

      if isMVolume
        PPA.fileType = 2; % we handle the volDataset class differently...
      end

      % check for specific variables in the mat file
      hasXYvectors = ismember('x', PPA.MatFileVars) && ismember('y', PPA.MatFileVars);
      hasZector = ismember('z', PPA.MatFileVars);
      hasVolData = ismember('volData', PPA.MatFileVars);
      hasMapRaw = ismember('mapRaw', PPA.MatFileVars); % new map data
      hasMapOnly = ismember('map', PPA.MatFileVars) &&~hasMapRaw; % old map data

      isVolData = isMVolume || hasVolData;

      if isVolData
        isValidFile = (hasXYvectors && hasZector) || isMVolume;
      else % new or old map data
        isValidFile = hasXYvectors && (hasMapRaw || hasMapOnly);
      end

    case {'.tiff','.tif'}
      % PPA.fileType = 3/4; % could be either
      % needsInfo
      isValidFile = 1;
      tiffInfo = imfinfo(PPA.filePath);
      nImages = length(tiffInfo);
      if (nImages > 1)
        PPA.fileType = 3;
        isVolData = true;
      else
        PPA.fileType = 4;
        isVolData = false;
      end
      needsInfo = true; % ask for resolution? 
      
    case '.jpg'
      PPA.fileType = 4;
      isValidFile = 1;
      
    case '.png' 
      PPA.fileType = 4;
      isValidFile = 1;

    otherwise
      PPA.fileType = 0;
      error('Unknow file extention: %s!',PPA.fileExt);
  end

  if ~isValidFile
    msg = 'File content not in required format!';
    title = 'Unknown file format!';
    selection = uiconfirm(PPA.LoadGUI.UIFigure, msg, title, ...
      'Options', {'Get help', 'Accept your fate'}, ...
      'DefaultOption', 1, 'CancelOption', 2);

    if strcmp(selection, 'Get help')
      % open web browser with readme
      web('https://github.com/razanskylab/PostProGUI#supported-data-formats');
    end

    PPA.fileType = 0;
    PPA.LoadGUI.LoadDataButton.Enable = false;
  else
    PPA.LoadGUI.LoadDataButton.Enable = true;
  end

  PPA.isVolData = isVolData;

end
