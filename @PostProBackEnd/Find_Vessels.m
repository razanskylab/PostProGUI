function Find_Vessels(PPA)
  % follows closely what is happening in AVA.Get_Data(); 
  % but this way we can plot in between...
  % this function only takes care of initializing the AVA data properly
  % and then binarized the latest processed projection
  
  try
    % binarization and cleanup before we find vessels in datasets --------------
    PPA.Update_Status('Sorting vessel skeletons...');

    VData = PPA.AVA.Data;

    minSplineLength = PPA.VesselGUI.MinSplineLength.Value;
    removeFat = PPA.VesselGUI.RemoveExtreme.Value;
    splineSmooth = PPA.VesselGUI.SplineSmooth.Value;

    % Create an array of vessels to store centre pixel locations in [row, col] form
    % order the pixels for eache vessels centerline (not sure why we are doing this)
    [vessels, maxDist] = create_and_order_vessel_centerlines(VData.segments, ...
      minSplineLength, removeFat, VData.distTrans);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Refine the centreline and compute angles by spline-fitting
    % vessel in is just a
    PPA.Update_Status('Spline fitting vessel skeletons...');
    Vessels = spline_centreline(vessels, splineSmooth, true);

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

    % add the vessels
    VData.add_vessels(Vessels);

    % calculate widht based on gradient fun
    PPA.Update_Status('Calculating vessel widths...');
    PPA.AVA.AviaSettings.smooth_parallel = PPA.VesselGUI.SmoothPar.Value;
    PPA.AVA.AviaSettings.smooth_perpendicular = PPA.VesselGUI.SmoothPer.Value;
    PPA.AVA.AviaSettings.enforce_connectivity = PPA.VesselGUI.ForceConnect.Value;
    edges_max_gradient(VData, PPA.AVA.AviaSettings);

    % Make sure NaNs are 'excluded' from summary measurements
    VData.vessel_list.exclude_nans();

    PPA.AVA.Data = VData; % store vessel data in AVA object

    % plot final image with fitted splines, widths and branch points
    fun = @(x) cat(1, x, [nan, nan]);
    temp = cellfun(fun, {Vessels.centre}, 'UniformOutput', false);
    cent = cell2mat(temp');
    PPA.VesselFigs.SplineLine.XData = cent(:, 2);
    PPA.VesselFigs.SplineLine.YData = cent(:, 1);

    fun = @(x) cat(1, x, [nan, nan]);
    side1 = cellfun(fun, {Vessels.side1}, 'UniformOutput', false);
    side2 = cellfun(fun, {Vessels.side2}, 'UniformOutput', false);
    side1 = cell2mat(side1');
    side2 = cell2mat(side2');
    PPA.VesselFigs.LEdgeLines.XData = side1(:, 2);
    PPA.VesselFigs.LEdgeLines.YData = side1(:, 1);
    PPA.VesselFigs.REdgeLines.XData = side2(:, 2);
    PPA.VesselFigs.REdgeLines.YData = side2(:, 1);

    if ~isempty(VData.branchCenters)
      PPA.VesselFigs.SplineScat.XData = VData.branchCenters(:, 1);
      PPA.VesselFigs.SplineScat.YData = VData.branchCenters(:, 2);
    end

    PPA.ProgBar = [];

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end


end



