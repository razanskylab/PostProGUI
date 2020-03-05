function Apply_Vessel_Pre_Processing(PPA)
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

    figure(PPA.VesselFigs.MainFig);

    % binarization and cleanup before we find vessels in datasets --------------
    PPA.Start_Wait_Bar(PPA.VesselGUI, 'Pre-processing vessel data...');
    startIm = normalize(PPA.procProj);
    PPA.IMF = Image_Filter(startIm);
    set(PPA.VesselFigs.InIm, 'cData', startIm); % update input image
    % update background of overlay images
    set(PPA.VesselFigs.SkeletonImBack, 'cData', startIm);
    set(PPA.VesselFigs.SplineImBack, 'cData', startIm);

    % initialize AVA & Vessel Data object for AVA usage
    PPA.AVA = Vessel_Analysis();
    VData = Vessel_Data(PPA.AVA.VesselSettings);
    VData.delete_vessels;
    VData.im = single(startIm);
    VData.im_orig = single(startIm);
    % we always assume white vessels on dark background
    VData.dark_vessels = false;

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

    % update cleaned binarized image
    set(PPA.VesselFigs.BinCleanIm, 'cData', binImClean);
    % store cleaned up BW data in vessel data object
    VData.bw = binImClean;

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

    if ~isempty(VData.branchCenters)
      PPA.VesselFigs.SkeletonScat.XData = VData.branchCenters(:, 1);
      PPA.VesselFigs.SkeletonScat.YData = VData.branchCenters(:, 2);
    end

    PPA.AVA.Data = VData; % store vessel data in AVA object

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end
end