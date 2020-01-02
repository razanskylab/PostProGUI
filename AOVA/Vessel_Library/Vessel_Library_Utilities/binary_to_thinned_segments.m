function [bw_segments, bw_branches, dist] = binary_to_thinned_segments(bw, spur_length, clear_branches_dist)
  % Computes a binary image containing thinned centrelines from a segmented
  % binary image containing vessels.  Branch points and short spurs are
  % removed during the thinning.
  %
  % Input:
  %   BW - the original segmented image.
  %   SPUR_LENGTH - the length of spurs that should be removed.
  %   CLEAR_BRANCHES_DIST - TRUE if centre lines should be shortened
  %   approaching branch points, so that any pixel is removed from the
  %   centre line if it is closer to the branch than to the background
  %   (i.e. FALSE pixels in BW).  If measurements do not need to be made
  %   very close to branches (where they may be less accurate), this can
  %   give a cleaner result (Default = TRUE).
  %
  % Output:
  %   BW_SEGMENTS - another binary image (the same size as BW) containing
  %   only the central pixels corresponding to segments of vessels
  %   between branches.
  %   BW_BRANCHES - the detected branch points that were removed from the
  %   originally thinned image when generating BW_SEGMENTS.
  %   DIST - the distance transform BWDIST(~BW).  If CLEAR_BRANCHES_DIST
  %   is TRUE, then this is required - and given as an additional output
  %   argument since it has other uses, and it can be time consuming to
  %   recompute for very large images.  Even if CLEAR_BRANCHES_DIST is FALSE,
  %   DIST is given if it is needed.

  bwRaw = bw;

  % Thin the binary image
  useJoeSettings = false;
  if ~useJoeSettings
    bw_thin = bwmorph(bw, 'thin', Inf);
    % Find the branch and end points based upon a count of 'on' neighbours
    neighbour_count = imfilter(uint8(bw_thin), ones(3));
    bw_branches = neighbour_count > 3 & bw_thin;
    bw_ends = neighbour_count <= 2 & bw_thin;

    % Remove the branches to get the segments
    bw_segments = bw_thin & ~bw_branches;

    % Find the terminal segments - i.e. those containing end points
    % imreconstruct(marker,mask) uses info in marker and takes closed segements in mask out
    bw_terminal = imreconstruct(bw_ends, bw_segments);

    % Remove the terminal segments if they are too short
    bw_thin(bw_terminal & ~bwareaopen(bw_terminal, spur_length)) = false;

    % We might still have some single pixel spurs, so remove these
    bw_thin = bwmorph(bw_thin, 'spur');

    % Also need to apply a thinning, since we can have 8-connected pixels that
    % are nonetheless not branch points
    bw_thin = bwmorph(bw_thin, 'thin', Inf);

    % Remove the branches again to get the final segment
    neighbour_count = imfilter(uint8(bw_thin), ones(3));
    bw_branches = neighbour_count > 3 & bw_thin;
    bw_segments = bw_thin & ~bw_branches;
  else
    bw_thin = bwmorph(bw, 'thin', Inf); % thin down to skeleton
    bw_thin = bwmorph(bw_thin, 'clean'); % Removes isolated pixels
    bw_branches = bwmorph(bw_thin, 'branchpoints');
    bw_ends = bwmorph(bw_thin, 'endpoints');
    bw_segments = bw_thin & ~bw_branches;

    % get all segments that contain end points
    % imreconstruct(marker,mask) uses info in marker and takes closed segements in mask out
    bw_terminal = imreconstruct(bw_ends, bw_segments);
    longTerminals = bwareaopen(bw_terminal, spur_length);

    % Remove the terminal segments if they are too short
    bw_thin(bw_terminal & ~longTerminals) = false;

    % We might still have some single pixel spurs, so remove these
    bw_thin = bwmorph(bw_thin, 'spur');
    bw_thin = bwmorph(bw_thin, 'clean'); % Removes isolated pixels


    % Also need to apply a thinning, since we can have 8-connected pixels that
    % are nonetheless not branch points
    bw_thin = bwmorph(bw_thin, 'thin', Inf);

    bw_branches = bwmorph(bw_thin, 'branchpoints');
    bw_segments = bw_thin & ~bw_branches;
    bw_segments = bwmorph(bw_segments, 'clean'); % Removes isolated pixels
    % bw_segments = bwmorph(bw_segments, 'spur');
  end

  % If necessary, remove more pixels at the branches(depending upon how edges
  % are set, these locations can be very problematic).
  % Use the distance transform to identify centreline pixels are closer to
  % the branch than to the background - and then get rid of these.
  if clear_branches_dist
      dist = bwdist(~bw);
      bw(bw_branches) = false;
      dist2 = bwdist(~bw);
      bw_segments = bw_thin & (dist == dist2);
  elseif nargout >= 3
      dist = bwdist(~bw);
  end

  if show_debug_plot_w_figure
    imagescj(bwRaw); axis('off'); colorbar('off'); title('Seg & thinned center');
    showMaskAsOverlay(1,bw_thin);
  end
end
