function Load_Raw_File(PPA)

    % set default export file name and path
    PPA.GUI.expFolderPath.Value = [folderPath '\export'];
    PPA.GUI.expFileName.Value = fileName;
    PPA.exportCounter = 0;

  end
