function [args] = centre_spline_fit(vessel_data, args)
  % Compute the centrelines for vessel segments from a binary image, then
  % refine these using spline fitting and compute image profiles
  % perpendicular to the vessel.  The length of the profiles is based on an
  % estimate of the largest potential vessel in the image, as determined from
  % the original binary image.
  %
  % ARGS contents:
  %   SPLINE_PIECE_SPACING - The approximate spacing that should occur
  %   between spline pieces (in pixels).  A higher value implies fewer
  %   pieces, and therefore a smoother spline fit (Default = 10).

  %   CENTRE_SPURS - the length of spurs that should be removed from the
  %   thinned vessel centrelines.  Because spurs are offshoots from the
  %   centreline, they cause branches - which can lead to vessels being
  %   erroneously sub-divided.  On the other hand, some spurs can really be
  %   the result of actual vessel branches - and should probably be kept.
  %   This parameter is a length (in pixels) that a spur must exceed for it
  %   to be kept (Default = 10).

  %   CENTRE_MIN_PX - the minimum length of a vessel segment centre
  %   line for it to be kept. Must be >= 3 because of need for angles.  The
  %   spur removal will only get rid of terminal segments, but very short
  %   segments might remain between branches, in which case this parameter
  %   becomes relevant (Default = 3).

  %   CENTRE_REMOVE_EXTREME - TRUE if segments should be removed if a fast
  %   estimate of their maximum diameter (from the binary image) is greater
  %   than the number of pixels in their centreline.  Such segments are
  %   usually not measureable vessels.  Keeping them can have a
  %   disproportionate effect upon processing time, because longer image
  %   profiles need to be computed for every vessel just to make sure that
  %   enough pixels are included for these extreme segements (Default = TRUE).

  % Extract images
  im = vessel_data.im;

  % Get thinned centreline segments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  bw = vessel_data.bw;
  imRaw = vessel_data.im_orig;

  % skeletonize image and return vessels segments and branching points ---------
  [bw_segments, bw_branches, dist_trans] = binary_to_thinned_segments(bw, args.centre_spurs, args.centre_clear_branches_dist_transform);

  vessel_data.bw_branches = bw_branches;
  branchCenters = regionprops(bw_branches,'centroid');
  branchCenters = cat(1, branchCenters.Centroid);
  vessel_data.branchCenters = branchCenters;
  vessel_data.nBranches = size(branchCenters,1);

  if show_debug_plot_w_figure
    % plot raw image with enhanced contrast
    imagescj(adapthisteq(imRaw),'gray'); colorbar('off'); axis('off');
    % plot segemts as overlay
    showMaskAsOverlay(1,bw_segments);
    title('Raw - Segments & Branches');
    % plot branc points as scatter on top
    hold on;
    if ~isempty(branchCenters)
        scatter(branchCenters(:,1),branchCenters(:,2),'LineWidth',1.0,'MarkerEdgeColor',Colors.DarkOrange);
    end
  end

  % Create an array of vessels to store centre pixel locations in [row, col] form
  % order the pixels for eache vessels centerline (not sure why we are doing this)
  [vessels,dist_max] = create_and_order_vessel_centerlines(bw_segments,args.centre_min_px,args.centre_remove_extreme,dist_trans);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Refine the centreline and compute angles by spline-fitting
  vessels = spline_centreline(vessels, args.spline_piece_spacing, true);

  if show_debug_plot_w_figure
    % plot raw image with enhanced contrast
    imagescj(adapthisteq(imRaw,'ClipLimit',0.02),'gray'); colorbar('off'); axis('off');
    hold on;
    plot_vessel_centerlines(vessels,Colors.PureRed,1);
    title('Spline Fitted Segments & Branches');
    % plot branch points as scatter on top
    if ~isempty(branchCenters)
        scatter(branchCenters(:,1),branchCenters(:,2),20,'filled','MarkerFaceColor',Colors.DarkOrange);
    end
  end

  %----------------------------
  % Compute image profiles, using the distance transform of the segmented
  % image to ensure the profile length will be long enough to contain the
  % vessel edges
  width = ceil(dist_max*4);
  if mod(width, 2) == 0
      width = width + 1;
  end
  % Make the image profiles
  vessels = make_image_profiles(vessels, im, width, '*linear');

  % Make sure the list in VESSEL_DATA is empty, then add the vessels
  vessel_data.delete_vessels;
  vessel_data.add_vessels(vessels);
end
