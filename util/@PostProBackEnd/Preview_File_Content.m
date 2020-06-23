function [isValidFile] = Preview_File_Content(PPA)

  try
    figure(PPA.LoadGUI.UIFigure);
    
    progBarStr = sprintf('Previewing file %s\n', PPA.fileName);
    ProgBar = uiprogressdlg(PPA.LoadGUI.UIFigure, 'Title', progBarStr, ...
      'Indeterminate', 'on');
    PPA.Update_Status(progBarStr);

    % make sure file exists...
    if ~PPA.fileExists
      close(ProgBar);
      uialert(PPA.LoadGui.UIFigure, 'File does not exist!', ...
        'File does not exist!');
      return;
    end

    % get file info
    [isValidFile, needsInfo] = PPA.Check_File_Content();

    % if we have a mat file, we preview the mat file content
    if ~isempty(PPA.FileContent)
      names = cell(numel(PPA.FileContent), 1);
      sizes = cell(numel(PPA.FileContent), 1);
      bytes = cell(numel(PPA.FileContent), 1);

      for iData = 1:numel(PPA.FileContent)
        names{iData} = PPA.FileContent(iData).name;
        sizes{iData} = sprintf('%i ', PPA.FileContent(iData).size);
        bytes{iData} = [num2sip(PPA.FileContent(iData).bytes, 3, false, true) 'B'];
      end

      % update table with info on file names, size, etc
      PPA.LoadGUI.UITable.Data = table(names, sizes, bytes);

      if isValidFile &&~needsInfo
        PPA.LoadGUI.FullInfoLamp.Color = Colors.DarkGreen;
        PPA.LoadGUI.GoodFormatLamp.Color = Colors.DarkGreen;
      elseif isValidFile && needsInfo
        PPA.LoadGUI.GoodFormatLamp.Color = Colors.DarkGreen;
        PPA.LoadGUI.FullInfoLamp.Color = Colors.DarkOrange;
      else
        PPA.LoadGUI.GoodFormatLamp.Color = Colors.DarkRed;
        PPA.LoadGUI.FullInfoLamp.Color = [1 1 1];
      end
    else
      PPA.LoadGUI.UITable.Data = [];
    end

    % get preview map if possible ----------------------------------------------
    % it's possible when mat file contains map, mapRaw or a small volume
    % if we have a large volume file (e.g. urs datasets) with no map either
    % we don't preview it either, as we would have to load variable first and we
    % don't want to do that yet as it can take quite some time

    % if we have a variable called map, display it...
    hasMap = ~isempty(PPA.MatFileVars) && ismember('map', PPA.MatFileVars); % old map data

    if hasMap
      prevMap = PPA.MatFile.map;
    elseif (PPA.fileType == 3) % is a tiff stack
      % for preview, we just want a quick MIP!
      prevMap = max(double(tiff_to_mat(PPA.filePath)),[],3);
    elseif (PPA.fileType == 4) % normal image
      prevMap = single(imread(PPA.filePath));
    else
      prevMap = [];  
    end
    
    if ~isempty(prevMap)
      prevMap = normalize(prevMap);
      
      if ismatrix(prevMap)
        prevMap = uint8(prevMap .* 255);
        prevMap = ind2rgb(prevMap, gray(256));
      end
      PPA.LoadGUI.PrevImage.ImageSource = prevMap;
    else % no preview, also not a problem
      % display default image with new overlay...
      defaultImage = imread('load_gui_default_im.jpg');
      defaultImage = imresize(defaultImage, 4) .* 0.2; % 0.2 makes image dark
      infoStr = sprintf('No preview available!');
      ctrPos = round(size(defaultImage) ./ 2);
      ctrPos = ctrPos(1:2); % remove 3rd dim of rgb image
      defaultImage = insertText(defaultImage, ctrPos, infoStr, ...
        'FontSize', 60, 'TextColor', 'black', 'BoxColor', 'white', ...
        'BoxOpacity', 0.5, 'AnchorPoint', 'center');
      PPA.LoadGUI.PrevImage.ImageSource = defaultImage;
    end

    close(ProgBar);
    figure(PPA.LoadGUI.UIFigure);
  catch ME
    close(ProgBar);
    rethrow(ME);
  end

end
