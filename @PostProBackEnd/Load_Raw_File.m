function Load_Raw_File(PPA, filePath)

  try
    % setup imaging panels once for new data set
    PPA.Start_Wait_Bar('Preparing image panels.');
    PPA.Setup_Image_Panel(PPA.GUI.FiltDisp, true);
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
      PPA.Setup_Image_Panel(PPA.GUI.yzSliceDisp, true);
      PPA.Setup_Image_Panel(PPA.GUI.xzSliceDisp, true);
      PPA.Setup_Image_Panel(PPA.GUI.xzProjDisp, true);
      PPA.Setup_Image_Panel(PPA.GUI.yzProjDisp, true);

      statusText = sprintf('Loading volumetric raw data (%s).', fileName);
      PPA.Start_Wait_Bar(statusText);

      % setup gui element limits etc based on volume size ----------------------
      % set limits based on newly loaded data
      maxZ = size(PPA.rawVol, 1);
      PPA.GUI.zCropLowEdit.Limits = [1 maxZ];
      PPA.GUI.zCropHighEdit.Limits = [1 maxZ];
      PPA.GUI.DwnSplFactorEdit.Limits = [1 round(min([PPA.nX PPA.nY]) ./ 50)];
      % this ensures we get no images smaller than 50x50
      set_image_click_callback(PPA.GUI.FiltDisp);
      PPA.lineCtr = PPA.centers(1:2);
      PPA.Update_Slice_Lines();

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

  function [] = set_image_click_callback(UIAxis)
    % checks for acutal images in a uiaxis and set's their click function
    % lines etc. are ignored
    nChild = numel(UIAxis.Children);

    for iChild = 1:nChild
      obj = UIAxis.Children(iChild);

      if isa(obj, 'matlab.graphics.primitive.Image')
        obj.ButtonDownFcn = {@postpro_image_click, PPA}; %PPA will be passed to the callback
      end

    end

  end

end
