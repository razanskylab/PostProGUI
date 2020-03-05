function Apply_Vessel_Pre_Processing(PPA)
  % follows closely what is happening in AVA.Get_Data(); 
  % but this way we can plot in between...
  % this function only takes care of initializing the AVA data properly
  % and then binarized the latest processed projection
  
  try
    % binarization and cleanup before we find vessels in datasets --------------
    PPA.Start_Wait_Bar(PPA.VesselGUI, 'Pre-processing vessel data...');
    startIm = normalize(PPA.procProj);
    PPA.IMF = Image_Filter(startIm); 
    set(PPA.VesselFigs.InIm, 'cData', startIm); % update input image

    % initialize AVA & Vessel Data object for AVA usage
    PPA.AVA = Vessel_Analysis();
    VData = Vessel_Data(PPA.AVA.VesselSettings);
    VData.im = single(startIm);
    VData.im_orig = single(startIm);

    % binarized based on what was selected in GUI
    switch PPA.VesselGUI.BinMethodDropDown.Value
    case 'Adaptive'
      PPA.IMF.binMethod = 'adapt';
      PPA.IMF.threshSens = PPA.VesselGUI.BinSensEdit.Value;
    case 'Otsu'
      PPA.IMF.binMethod = 'gray';
    case 'Multi'
      PPA.IMF.binMethod = 'multi';
      PPA.IMF.nThreshLevels = PPA.VesselGUI.BinMultiLevels.Value;
    case 'Manual'
      PPA.IMF.binMethod = 'manual';
      PPA.IMF.threshLevel = PPA.VesselGUI.BinSensEdit.Value;
    end

    binIm = PPA.IMF.Binarize();
    set(PPA.VesselFigs.BinIm, 'cData', binIm); % update binarized image

    % content from seg_iuwt, but without the segmentation part...
    minObjSize = PPA.VesselGUI.MinObjSizeEdit.Value;
    minHoleSize = PPA.VesselGUI.MinHoleSizeEdit.Value;
    binImClean = clean_segmented_image(binIm, minObjSize, minHoleSize);
    
    % we always assume white vessels on dark background
    VData.dark_vessels = false; 
    % store cleaned up BW data in vessel data object
    VData.bw = binImClean;

    PPA.AVA.Data = VData; % store vessel data in AVA object

    set(PPA.VesselFigs.BinCleanIm, 'cData', binImClean); 
    % update cleaned binarized image

    PPA.ProgBar = [];

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end


end



