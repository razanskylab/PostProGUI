% Create an array of vessels to store centre pixel locations in [row, col] form
% order the pixels for eache vessels centerline (not sure why we are doing this)
function [vessels,dist_max] = create_and_order_vessel_centerlines(bw_segments,min_px,remove_extreme,dist_trans)

  % Get indices for the 'on' pixels of each centre line segment
  cc = bwconncomp(bw_segments);

  % Create an array of vessels to store centre pixel locations in [row, col] form
  vessels(cc.NumObjects) = Vessel;

  % We may need to remove some vessels in the end if they have insufficient
  % pixels
  remove_inds = false(size(vessels));

  % Put the pixel locations in order, from one end to the other
  for ii = cc.NumObjects:-1:1
      % Extract the indices of the pixels
      px_inds = cc.PixelIdxList{ii};

      % If there are too few pixels, or the distance transform indicates we
      % have a short segment inside
      if numel(px_inds) < min_px || (remove_extreme && max(dist_trans(px_inds)) * 2 > numel(px_inds))
          remove_inds(ii) = true;
          continue;
      end

      % Get the row and column of each pixel
      row = rem(px_inds-1, size(bw_segments,1)) + 1;
      col = (px_inds - row) / size(bw_segments,1) + 1;
      % ALTERNATIVE (slightly slower) to the above
      %  [row, col] = ind2sub(size(bw), cc.PixelIdxList{ii});

      % If only 1 or 2 pixels are present, these can't possibly be out of order
      % (although this only matters if the minimum pixels part is overridden)
      if numel(cc.PixelIdxList{ii}) <= 2
          vessels(ii).centre = [row, col];
          continue;
      end

      % Calculate the distance of each pixel from one another -
      % DIST is a symmetric logical matrix, where TRUE indicates that two
      % pixel locations (identified by the row and column) in the matrix
      % are within 1 pixel distance of one another
      dist = (abs(bsxfun(@minus, row, row')) <= 1) & (abs(bsxfun(@minus, col, col')) <= 1);
      % ALTERNATIVE (slightly slower)
      %  dist = (bsxfun(@minus, row, row').^2 + bsxfun(@minus, col, col').^2) <= 2;

      % Here, things become a bit confusing.  We temporarily don't care where
      % the pixel locations are (this is stored in the ROW and COL arrays),
      % but we DO care about which are beside one another - which is encoded
      % in the DIST array.  To make sense of this, consider the TRUE values
      %   [y, x] = FIND(DIST);
      % Then the pixel identified by ROW(y), COL(y) is next to the pixel
      % identified by ROW(x), COL(x).

      % If DIST is tridiagonal (tested by all TRUE on first diagonal),
      % the pixels are already in order - that is, pixels next to one another
      % are always within one pixel of each other.
      if all(diag(dist, 1))
          vessels(ii).centre = [row, col];
          continue;
      end

      % If we reached this point, it means we need to reorder the pixels.
      % First, find the adjacent pixels - because DIST is symmetric,
      % and TRUE along main diagonal doesn't mean anything very useful (as it
      % only indicates that a pixel is extremely close to itself), to find
      % out which pixels are adjacent we only need where the TRUE entries in
      % the upper (or lower) part of the matrix are to be found.
      link = [];
      [link(:,1), link(:,2)] = find(triu(dist, 1));

      % We are now working with indices to ROW and COL, and want to find
      % where entries belong beside one another.  LINK gives us that
      % information, by giving pairs of linked indices.
      % Now get the number of occurrences of each index.
      locs = 1:max(link(:));
      n = histc(link(:), locs);

      % The indices that only occur once must be the end points.
      % Based upon the previous code, there should be precisely two - but if
      % we were very unlucky we might have happened upon a loop, in which
      % case we remove the segment.
      loc_inds = n == 1;
      if nnz(loc_inds) ~= 2
          remove_inds(ii) = true;
          continue;
      end

      % LOCS is really a vector of indices into ROW and COL.
      % We now know what its first and last values should be, based upon the
      % end points we have.
      locs([1,end]) = locs(loc_inds);

      % Starting at the initial end point, follow the links to the other one.
      % End points have only one link.  Every other pixel has two.  But by
      % removing the links we have already visited, we are only looking for a
      % single link on each iteration.
      for jj = 2:numel(locs)-1
          % Get the row in LINKS containing the last index found (which
          % might be in the first or second column)
          rem_row = any(link == locs(jj-1), 2);
          rem_links = link(rem_row, :);
          % Get the linked index (which is the entry in REM_LINKS that is not
          % the index we already have)
          locs(jj)  = rem_links(rem_links ~= locs(jj-1));
          % Remove the row from LINK in preparation for the next iteration
          link = link(~rem_row, :);
      end
      % Go back now to the original ROW and COL arrays to get the pixel
      % segment centre line locations in order, and store these in the cell array
      vessels(ii).centre = [row(locs), col(locs)];
  end

  % Remove any vessels where there were not enough pixels
  if any(remove_inds)
      vessels(remove_inds) = [];
  end

  cc.PixelIdxList(remove_inds) = [];
  inds_all = cat(1, cc.PixelIdxList{:});
  if isempty(inds_all)
      dist_max = 0;
  else
      dist_max = max(dist_trans(inds_all));
  end
end
