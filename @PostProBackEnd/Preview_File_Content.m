function Preview_File_Content(PPA)
  d = uiprogressdlg(PPA.LoadGUI.UIFigure, 'Title', 'Previewing file...', ...
  'Indeterminate', 'on');
  figure(PPA.LoadGUI.UIFigure);
  MatFile = matfile(PPA.filePath);
  FileContent = whos(MatFile);

  names = cell(numel(FileContent), 1);
  sizes = cell(numel(FileContent), 1);
  bytes = cell(numel(FileContent), 1);

  for iData = 1:numel(FileContent)
    names{iData} = FileContent(iData).name;
    sizes{iData} = sprintf('%i ', FileContent(iData).size);
    bytes{iData} = [num2sip(FileContent(iData).bytes, 3, false, true) 'B'];
  end

  PPA.LoadGUI.UITable.Data = table(names, sizes, bytes);
  % PPA.LoadGUI.PrevImage

  % get preview map if possible
  % it's possible when mat file contains map, mapRaw or a small volume
  % if we have a large volume file (e.g. urs datasets) with no map either
  % we don't preview it either, as we would have to load variable first and we
  % don't want to do that yet as it can take quite some time

  % if we have a variable called map, display it...
  prevMap = uint8(normalize(MatFile.map) .* 255);
  PPA.LoadGUI.PrevImage.ImageSource = ind2rgb(prevMap, gray(256));
  close(d);
  figure(PPA.LoadGUI.UIFigure);
end