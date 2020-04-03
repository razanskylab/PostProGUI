function Batch_Process_Folder(PPA)

  try
    folder = uigetdir(PPA.folderPath);

    if folder
      PPA.batchPath = folder;
    else
      uialert(PPA.ExportGUI.UIFigure, 'No folder selected!', 'No folder selected!');
      return;
    end

    % TODO based on PPA.fileType, we should look for mat data, tiff stacks etc..
    filePaths = find_all_files_in_path(PPA.batchPath, ...
      'extention', '.mat', ...
      'verboseOutput', false, ...
      'searchSubFolders', false);
    nFiles = numel(filePaths);

    if ~nFiles
      uialert(PPA.ExportGUI.UIFigure, 'No compatible files found!', 'No compatible files found!');
      return;
    end

    for iFile = 1:nFiles

      try
        fprintf('Processing file %i / %i\n', iFile, nFiles);
        PPA.filePath = filePaths{iFile};
        PPA.Preview_File_Content();
        % PPA.Check_File_Content();
        PPA.Load_Raw_Data();
        PPA.processingEnabled = true; % this will start the raw-processing cascade

        if ~isempty(PPA.rawVol)%
          PPA.MasterGUI.Open_Vol_Gui(); % handles processing etc...
        end

        if ~isempty(PPA.procProj) && ~isempty(PPA.MapFig)
          % PPA.MasterGUI.Open_Map_Gui(); % handles processing etc...
          PPA.Apply_Image_Processing();
        end
      
        if ~isempty(PPA.VesselFigs)
          PPA.Apply_Vessel_Processing();
        end

        PPA.ExportGUI.expFileName.Value = PPA.fileName;
        PPA.exportPath = fullfile(PPA.folderPath,'gui_export');
        PPA.ExportGUI.expFolderPath.Value = PPA.exportPath;
        PPA.Export();
      catch me
        warnMessage = sprintf('Processing file %s failed', filePaths{iFile});
        short_warn(warnMessage);
        short_warn(getReport(me, 'basic', 'hyperlinks', 'on'));
      end

    end

  catch me2
    rethrow(me2);
  end

end
