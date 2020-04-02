function Apply_Vessel_Pre_Processing(PPA,startIm)
  % follows closely what is happening in AVA.Get_Data();
  % but this way we can plot in between...
  % this function only takes care of initializing the AVA data properly
  % and then binarized the latest processed projection
  % things in here should be fast, so that one can immediately see the results...

  try
    % figure was closed, but vessel GUI is still open, so
    % just open a new figure
    if isempty(PPA.VesselFigs) ||~ishandle(PPA.VesselFigs.MainFig)
      PPA.Setup_Vessel_Figures();
    end

    % binarization and cleanup before we find vessels in datasets --------------
    progressbar('Pre-processing vessel data...',{Colors.GuiLightOrange});
    PPA.Update_Status('Pre-processing vessel data...');
    startIm = normalize(startIm);
    PPA.IMF = Image_Filter(startIm);
    progressbar(0.1);

    VData = PPA.AVA.Data;

    % binarized based on what was selected in GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch PPA.VesselGUI.BinarizationMethodDropDown.Value
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
    PPA.VesselFigs.BinPlot.Colormap = PPA.VesselFigs.cbar; % return to default colormap
    progressbar(0.25);
    
    % content from seg_iuwt, but without the segmentation part...
    minObjSize = PPA.VesselGUI.MinObjSizeEdit.Value;
    minHoleSize = PPA.VesselGUI.MinHoleSizeEdit.Value;
    binImClean = clean_segmented_image(binIm, minObjSize, minHoleSize);
    
    % update cleaned binarized image
    set(PPA.VesselFigs.BinCleanIm, 'cData', binImClean);
    PPA.VesselFigs.BinCleanPlot.Colormap = PPA.VesselFigs.cbar; % return to default colormap
    % store cleaned up BW data in vessel data object
    VData.bw = binImClean;
    progressbar(0.5);

    % reduce binnary image down to a skeleton
    % Get thinned centreline segments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PPA.Update_Status('Skeletonizing vessel data...');
    minSpurLength = PPA.VesselGUI.MinSpurLength.Value;
    clearNearBranch = PPA.VesselGUI.ClearNearBranchCheckBox.Value;

    % skeletonize image and return vessels segments and branching points ---------
    [VData.segments, VData.bw_branches, VData.distTrans] = ...
      binary_to_thinned_segments(binImClean, minSpurLength, clearNearBranch);

    % find branch centers
    VData.branchCenters = regionprops(VData.bw_branches, 'centroid');
    VData.branchCenters = cat(1, VData.branchCenters.Centroid);
    VData.nBranches = size(VData.branchCenters, 1);

    skelImMask = logical(VData.segments);
    skelImMask = ind2rgb(skelImMask, [0, 0, 0; 1, 0, 0]);
    PPA.VesselFigs.SkeletonImFront.CData = skelImMask;
    PPA.VesselFigs.SkeletonImFront.AlphaData = double(VData.segments);
    progressbar(0.75);

    if ~isempty(VData.branchCenters)
      PPA.VesselFigs.SkeletonScat.XData = VData.branchCenters(:, 1);
      PPA.VesselFigs.SkeletonScat.YData = VData.branchCenters(:, 2);
    end
    progressbar(0.9);
    % return to default colormap
    PPA.VesselFigs.Skeleton.Colormap = PPA.VesselFigs.cbar; 

    PPA.AVA.Data = VData; % store vessel data in AVA object
    progressbar(1);
  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end
end