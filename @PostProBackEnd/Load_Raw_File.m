function Load_Raw_File(PPA)

  try
    PPA.Setup_Image_Panel(PPA.GUI.imFiltDisp, true);
    colorbar(PPA.GUI.imFiltDisp);
    PPA.Setup_Image_Panel(PPA.GUI.imDepthDisp, true);

    % setup frangi panels as well
    PPA.Setup_Image_Panel(PPA.GUI.imFrangiFilt, true);
    PPA.Setup_Image_Panel(PPA.GUI.imFrangiCombined, true);
    PPA.Setup_Image_Panel(PPA.GUI.imFrangiFiltIn, true);
    PPA.Setup_Image_Panel(PPA.GUI.imFrangiScale, true);

    % load and process volumetric data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if PPA.isVolData
      % setup gui element limits etc based on volume size ----------------------
      % set limits based on newly loaded data


      % load and process MAP data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isMatFileMap || isOldMapData
      PPA.Set_Controls('map_only');
      cla(PPA.GUI.yzSliceDisp);
      cla(PPA.GUI.xzSliceDisp);
      cla(PPA.GUI.xzProjDisp);
      cla(PPA.GUI.yzProjDisp);
      statusText = sprintf('Loading projected (MAP) raw data (%s).', fileName);
      PPA.Start_Wait_Bar(statusText);
      PPA.rawVol = [];
      PPA.procVolProj = []; % clear out old data
      % this is only required if the same data is loaded from a different location
      % as matlab will detect that the procVolProj property has not changed and
      % will thus not trigger some required set functions...
    end

    % set default export file name and path
    PPA.GUI.expFolderPath.Value = [folderPath '\export'];
    PPA.GUI.expFileName.Value = fileName;
    PPA.exportCounter = 0;

    PPA.Stop_Wait_Bar();

  catch me
    PPA.Stop_Wait_Bar();
    rethrow(me);
  end
end
