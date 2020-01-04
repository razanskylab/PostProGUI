function Load_Raw_File(PPA, filePath)

  try

    if (nargin == 2)
      PPA.filePath = filePath; % update stored file path
    end

    % check for new file?
    PPA.Update_Status(' '); % new line
    PPA.Update_Status(); % hor. divider
    PPA.Update_Status(); % hor. divider
    PPA.Start_Wait_Bar('Checking mat file contents.');
    MatFile = matfile(PPA.filePath);
    variableInfo = who(MatFile);

    % check for a valid file containing map or vol data %%%%%%%%%%%%%%%%%%%%%%%%%%
    hasXYvectors = ismember('x', variableInfo) && ismember('y', variableInfo);
    % map files don't have dt argument
    hasZector = ismember('z', variableInfo);
    % check if this dataset is based on the "new" volDataset class
    % https://github.com/hofmannu/MVolume
    isMVolume = ismember('volDataset', variableInfo);
    % alternative is just variables stored in mat file
    isMatFileVolume = ismember('volData', variableInfo);
    isMatFileMap = ismember('mapRaw', variableInfo);
    PPA.isVolData = isMatFileVolume || isMVolume;
    hasDepth = ismember('depthMap', variableInfo);
    isOldMapData = ismember('map', variableInfo) &&~isMatFileMap;
    isValidFile = (PPA.isVolData && hasXYvectors && hasZector) || ...
      (hasXYvectors && (isMatFileMap || isOldMapData)) || isMVolume;

    if ~isValidFile
      PPA.Stop_Wait_Bar();
      uialert(PPA.GUI.UIFigure, 'File content not in required format!', 'Can''t read file!');
      return;
    end

    if ((isMatFileMap || isOldMapData) &&~hasDepth)
      PPA.Stop_Wait_Bar();
      uialert(PPA.GUI.UIFigure, 'No depth data in Map file!!', 'Depth data missing!');
      return;
    end

    % prepare projection panels based on XYZ data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isMVolume% could be map or volume data
      PPA.x = MatFile.x;
      PPA.y = MatFile.y;
    else
      % can't access user define classes via matfile object, so load it here
      PPA.Start_Wait_Bar('Loading volDataset class...');
      volDataClass = MatFile.volDataset;
      PPA.x = volDataClass.vecX * 1e3;
      PPA.y = volDataClass.vecY * 1e3;
      PPA.z = volDataClass.vecZ * 1e3; % vol class always has z-vector (I hope)
    end

    [folderPath, fileName] = fileparts(PPA.filePath);

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

    % clean out old frangi images, as we otherwise mix old and new datasets
    PPA.frangiFilt = [];
    PPA.frangiScales = [];
    PPA.frangiCombo = [];

    % load and process volumetric data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if PPA.isVolData
      PPA.Set_Controls('default');
      PPA.Setup_Image_Panel(PPA.GUI.yzSliceDisp, true);
      PPA.Setup_Image_Panel(PPA.GUI.xzSliceDisp, true);
      PPA.Setup_Image_Panel(PPA.GUI.xzProjDisp, true);
      PPA.Setup_Image_Panel(PPA.GUI.yzProjDisp, true);

      statusText = sprintf('Loading volumetric raw data (%s).', fileName);
      PPA.Start_Wait_Bar(statusText);

      PPA.rawVol = []; % clear out old data

      if ~isMVolume% mat file containing volumetric data
        PPA.dt = MatFile.dt;
        PPA.z = MatFile.z;
        PPA.rawVol = permute(single(MatFile.volData), [3 1 2]);
      else % mat file containing MVolume class
        PPA.dt = volDataClass.dZ * 1e-3;
        PPA.rawVol = volDataClass.vol;
      end

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
      depthMap = MatFile.depthMap;
      PPA.depthInfo = single(depthMap); % needs to be set before procVolProj!
      PPA.rawDepthInfo = single(depthMap); % only set when loading for 2d data
      % NOTE depthmap does not need to be transposed
      if isMatFileMap
        PPA.procVolProj = single(MatFile.mapRaw);
      elseif isOldMapData
        PPA.procVolProj = single(MatFile.map');
      end

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
