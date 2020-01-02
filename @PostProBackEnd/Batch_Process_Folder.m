function Batch_Process_Folder(PPA)

  try
    filePaths = find_all_files_in_path(PPA.batchPath, ...
      'extention', '.mat', ...
      'verboseOutput', false, ...
      'searchSubFolders', false);
    nFiles = numel(filePaths);

    for iFile = 1:nFiles

      try
        fprintf('Processing file %i / %i\n', iFile, nFiles);
        currentFilePath = filePaths{iFile};
        % load the file, during load we already set the volumes and projections
        % and doing so, but using the set methods, we already apply
        % all the processing we need
        PPA.Load_Raw_File(currentFilePath);
        % switch to the image processing tab to also get the depth map
        PPA.GUI.TabGroup.SelectedTab = PPA.GUI.ImageProcessingTab;
        PPA.Update_Depth_Map();
        % then export all of this!
        PPA.Export();
      catch me
        warnMesasge = sprintf('Processing file %s failed', currentFilePath);
        short_warn(warnMesasge);
        short_warn(getReport(me, 'basic', 'hyperlinks', 'on'))
      end

    end

  catch me
    rethrow(me);
  end

end
