function [hasValidVariables, needsInfo] = Check_Workspace_Content(PPA)
  % Check_File_Content()

  PPA.MatFile = [];
  PPA.FileContent = [];
  PPA.LoadGUI.UITable.Data = [];

  PPA.fileType = 0; % 0 = invalid, 1 = mat, 2 = tiff, 3 = image
  needsInfo = false;

  % check for specific variables in the workspace
  hasXVec = evalin('base', 'exist("x") && isvector(x)');
  hasYVec = evalin('base', 'exist("y") && isvector(y)');
  hasZector = evalin('base', 'exist("z") && isvector(z)');
  hasXYvectors = hasXVec && hasYVec;
  hasVolData = evalin('base', 'exist("volData") && ndims(volData) == 3');
  hasMapRaw = evalin('base', 'exist("mapRaw") && ismatrix(mapRaw)');
  hasMap = evalin('base', 'exist("map") && ismatrix(map)');
  hasMapOnly = hasMap &&~hasMapRaw; % old map data
  isVolData = hasVolData; % TODO check for MVolume class as well...

  if isVolData
    hasValidVariables = (hasXYvectors && hasZector) || isMVolume;
  else % new or old map data
    hasValidVariables = hasXYvectors && (hasMapRaw || hasMapOnly);
  end

  if hasMap
    prevMap = evalin('base', 'map');
    prevMap = uint8(normalize(prevMap) .* 255);
    PPA.LoadGUI.PrevImage.ImageSource = ind2rgb(prevMap, gray(256));
  end


  if ~hasValidVariables
    msg = 'Workspace does not contain required variables!';
    title = 'Missing variables!';
    selection = uiconfirm(PPA.LoadGUI.UIFigure, msg, title, ...
      'Options', {'Get help', 'Accept your fate'}, ...
      'DefaultOption', 1, 'CancelOption', 2);

    if strcmp(selection, 'Get help')
      % open web browser with readme
      web('https://github.com/razanskylab/PostProGUI#supported-data-formats');
    end
    short_warn('Require at least volData + xyz vector or map + xy vector!');

    PPA.fileType = 0;
    PPA.isVolData = 0;
  else
    PPA.isVolData = isVolData;
  end

end


