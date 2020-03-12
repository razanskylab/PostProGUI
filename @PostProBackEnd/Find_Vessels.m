function Find_Vessels(PPA)
  % follows closely what is happening in AVA.Get_Data(); 
  % but this way we can plot in between...
  % this function only takes care of initializing the AVA data properly
  % and then binarized the latest processed projection
  
  try
    % binarization and cleanup before we find vessels in datasets --------------
    PPA.Update_Status('Sorting vessel skeletons...');
    progressbar('Fitting vessel locations...', {Colors.GuiLightOrange});

    VData = PPA.AVA.Data;

    minSplineLength = PPA.VesselGUI.MinSplineLength.Value;
    removeFat = PPA.VesselGUI.RemoveExtreme.Value;
    splineSmooth = PPA.VesselGUI.SplineSmooth.Value;

    % Create an array of vessels to store centre pixel locations in [row, col] form
    % order the pixels for eache vessels centerline (not sure why we are doing this)
    [vessels, maxDist] = create_and_order_vessel_centerlines(VData.segments, ...
      minSplineLength, removeFat, VData.distTrans);
    progressbar(0.2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Refine the centreline and compute angles by spline-fitting
    % vessel in is just a
    PPA.Update_Status('Spline fitting vessel skeletons...');
    Vessels = spline_centreline(vessels, splineSmooth, true);
    progressbar(0.5);
    %----------------------------
    % Compute image profiles, using the distance transform of the segmented
    % image to ensure the profile length will be long enough to contain the
    % vessel edges
    width = ceil(maxDist * 4);

    if mod(width, 2) == 0
      width = width + 1;
    end

    % Make the image profiles
    PPA.Update_Status('Creating image profiles around vessels...');
    Vessels = make_image_profiles(Vessels, VData.im, width, '*linear');
    progressbar(0.75);
    % add the vessels
    VData.add_vessels(Vessels);
    progressbar(1);

    % calculate widht based on gradient fun
    PPA.Update_Status('Calculating vessel widths...');
    progressbar('Calculating vessel widths...', {Colors.GuiLightOrange});
    PPA.AVA.AviaSettings.smooth_parallel = PPA.VesselGUI.SmoothPar.Value;
    PPA.AVA.AviaSettings.smooth_perpendicular = PPA.VesselGUI.SmoothPer.Value;
    PPA.AVA.AviaSettings.enforce_connectivity = PPA.VesselGUI.ForceConnect.Value;
    edges_max_gradient(VData, PPA.AVA.AviaSettings, true);

    % Make sure NaNs are 'excluded' from summary measurements
    VData.vessel_list.exclude_nans();
    PPA.AVA.Data = VData; % store vessel data in AVA object
    progressbar(1);

    PPA.ProgBar = [];

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end


end



