function vessels = make_image_profiles(vessels, im, width, method, bw_mask)
  % Compute the profiles perpendicular to the centreline for an array of
  % VESSELs, and store these along with the row and column coordinates for
  % each pixel in the profiles.
  %
  % Input:
  %   VESSELS - the array of VESSEL objects
  %   IM - the image from which the profiles are computed
  %   WIDTH - a scalar giving the length of each profile, in pixels
  %   METHOD - the method of interpolation used when computing the profiles,
  %   as defined in INTERP2 (Default = '*linear')
  %   BW_MASK - a logical mask that may be applied to the image prior to
  %   computing the profiles.  If IM is logical, then values not in BW_MASK
  %   will be set to FALSE, otherwise they will be set to NaN.  BW_MASK must
  %   be the same size as IM.
  %
  % Output:
  %   VESSELS - the same as the input VESSELS, but with profile-related
  %   properties set.
  %
  %
  % Required VESSEL properties: IM, CENTRE, ANGLES
  %
  % Set VESSEL properties: IM_PROFILES, IM_PROFILES_ROWS, IM_PROFILES_COLS
  %
  %
  % Copyright � 2011 Peter Bankhead.
  % See the file : Copyright.m for further details.

  % This code looks more complicated than strictly necessary because INTERP2
  % is relatively slow, and it is much faster to pass all co-ordinates for
  % interpolation to it in one go than to use it to calculate image
  % profiles for each vessel in turn.

  % Use linear interpolation by default

  % Get the number of centre points for each vessel segment, then extract all
  % the centres and angles into single numeric arrays
  % n_rows = cellfun('size', centre, 1);
  vessels = vessels(:);
  centre = cat(1, vessels.centre);
  angles = cat(1, vessels.angles);

  % Determine co-ordinates for interpolation
  inc = (0:width-1) - (width-1)/2;
  angles = single(angles);
  inc = single(inc);
  im_profiles_rows = bsxfun(@plus, centre(:,1), bsxfun(@times, angles(:,1), inc));
  im_profiles_cols = bsxfun(@plus, centre(:,2), bsxfun(@times, angles(:,2), inc));

  im = single(im);

  % Compute the profiles
  all_profiles = interp2(im, im_profiles_cols, im_profiles_rows, method);

  % Loop through the vessels and assign the properties
  current_ind = 1;
  for ii = 1:numel(vessels)
      n_rows = size(vessels(ii).centre, 1);
      rows = current_ind:current_ind + n_rows - 1;
      vessels(ii).im_profiles = all_profiles(rows, :);
      vessels(ii).im_profiles_rows = im_profiles_rows(rows, :);
      vessels(ii).im_profiles_cols = im_profiles_cols(rows, :);
      current_ind = current_ind + n_rows;
  end
end
