function [AovaSettings] = get_aova_settings(whichSetting)
  if nargin < 1
    whichSetting = 0; % use default settings
  end
  if (whichSetting > 0) || (whichSetting < 0)
    short_warn('AOVA settings must be between 0 and 0! Using default (0)!');
    whichSetting = 0;
  end
  switch whichSetting
  case 0
    AovaSettings.processor_function                   = 'aria_algorithm_general';

    AovaSettings.mask_option                          = 'none';
    AovaSettings.mask_erode                           = 1;
    AovaSettings.mask_dark_threshold                  = 0;
    AovaSettings.mask_bright_threshold                = 1;
    AovaSettings.mask_largest_region                  = 1;

    % IUWT Thresholding Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AovaSettings.iuwt_dark                            = 0; % 0 - white vessel on dark background
    AovaSettings.iuwt_inpainting                      = 0;
    AovaSettings.iuwt_w_levels                        = [2:5];
    %   IUWT_W_THRESH - threshold defined as a proportion of the pixels in the
    %   image or FOV (default 0.2, which will detect ~20% of the pixels).
    AovaSettings.iuwt_w_thresh                        = 0.3;
    %   IUWT_PX_REMOVE - the minimum size an object needs to exceed in order to
    %   be kept, defined as a proportion of the image or FOV (default 0.05).
    % AovaSettings.iuwt_px_remove                       = 1e-03;
    AovaSettings.iuwt_px_remove                       = 0.5e-03;
    %   IUWT_PX_FILL - the minimum size of a 'hole' (i.e. an undetected region
    %   entirely surrounded by detected pixels), defined as a proportion of the
    %   image or FOV.  Smaller holes will be filled in (default 0.05).
    AovaSettings.iuwt_px_fill                         = 0.01;

    % centre_spline_fit settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   SPLINE_PIECE_SPACING - The approximate spacing that should occur
    %   between spline pieces (in pixels).  A higher value implies fewer
    %   pieces, and therefore a smoother spline fit (Default = 10).
    AovaSettings.spline_piece_spacing                 = 5;

    %   CENTRE_SPURS - the length of spurs that should be removed from the
    %   thinned vessel centrelines.  Because spurs are offshoots from the
    %   centreline, they cause branches - which can lead to vessels being
    %   erroneously sub-divided.  On the other hand, some spurs can really be
    %   the result of actual vessel branches - and should probably be kept.
    %   This parameter is a length (in pixels) that a spur must exceed for it
    %   to be kept (Default = 10).
    AovaSettings.centre_spurs                         = 5;

    %   CENTRE_MIN_PX - the minimum length of a vessel segment centre
    %   line for it to be kept. Must be >= 3 because of need for angles.  The
    %   spur removal will only get rid of terminal segments, but very short
    %   segments might remain between branches, in which case this parameter
    %   becomes relevant (Default = 3).
    AovaSettings.centre_min_px                        = 5;

    %   CENTRE_REMOVE_EXTREME - TRUE if segments should be removed if a fast
    %   estimate of their maximum diameter (from the binary image) is greater
    %   than the number of pixels in their centreline.  Such segments are
    %   usually not measureable vessels.  Keeping them can have a
    %   disproportionate effect upon processing time, because longer image
    %   profiles need to be computed for every vessel just to make sure that
    %   enough pixels are included for these extreme segements (Default = TRUE).
    AovaSettings.centre_remove_extreme                = 1;

    %    CLEAR_BRANCHES_DIST - TRUE if centre lines should be shortened
    %    approaching branch points, so that any pixel is removed from the
    %    centre line if it is closer to the branch than to the background
    %    (i.e. FALSE pixels in BW).  If measurements do not need to be made
    %    very close to branches (where they may be less accurate), this can
    %    give a cleaner result (Default = TRUE).
    AovaSettings.centre_clear_branches_dist_transform = 0;

    %   SMOOTH_PARALLEL and SMOOTH_PERPENDICULAR are scaling parameters that
    %   multiply the estimate width computed for the vessel under consideration to
    %   determine how much smoothing is applied
    %   SMOOTH_PARALLEL and SMOOTH_PERPENDICULAR are scaling parameters that
    %   multiply the mean width estimate for the vessel under consideration to
    %   determine how much smoothing is applied.  SMOOTH_PARALLEL/PERPENDICULAR
    %   is multiplied by the width, and the square root of the result gives the
    %   sigma for the Gaussian filter.  Although not essential,
    %   SMOOTH_SCALE_PERPENDICULAR should be >= SMOOTH_SCALE_PARALLEL (Default
    %   SMOOTH_PARALLEL = 1, SMOOTH_SCALE_PERPENDICULAR = 0.1).
    AovaSettings.smooth_parallel                      = 1;
    AovaSettings.smooth_perpendicular                 = 0.5;
    %   ENFORCE_CONNECTEDNESS - TRUE if all pixels along the vessel edge should
    %   be connected to one another, i.e. within a distance of approximately
    %   one pixel from one another, FALSE otherwise.  Setting this to TRUE can
    %   improve the results by reducing the risk that the edges of neighbouring
    %   structures or the central light reflex are erroneously linked to the
    %   vessel, but in some images it might cause even vessels that appear
    %   clearly visible to be missed because their edge (as determined by the
    %   algorithm) is too variable or fragmented (Default = TRUE).
    AovaSettings.enforce_connectivity                 = 1;
  otherwise
    error('Unknown AOVA setting. Using 0 (default).')
  end
end
