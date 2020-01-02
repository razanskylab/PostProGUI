function [args] = seg_iuwt(vessel_data, args)
  % Segment an image using the Isotropic Undecimated Wavelet Transform (IUWT,
  % or 'a trous' transform).
  %
  % Required VESSEL_DATA properties: IM
  % Optional VESSEL_DATA properties: BW_MASK
  % Set VESSEL_DATA properties:      BW
  %
  % ARGS contents:
  %   IUWT_DARK - TRUE if vessels are darker than their surroundings (e.g.
  %   fundus images), FALSE if they are brighter (e.g. fluorescein
  %   angiograms; default FALSE).
  %   IUWT_INPAINTING - TRUE if pixels outside the FOV should be replaced
  %   with the closest pixel values inside before computing the IUWT.  This
  %   reduces boundary artifacts.  It is more useful with fluorescein
  %   angiograms, since the artifacts here tend to produce bright features
  %   that are more easily mistaken for vessels (default FALSE).
  %   IUWT_W_LEVELS - a numeric vector containing the wavelet levels that
  %   should (default 2-3).
  %   IUWT_W_THRESH - threshold defined as a proportion of the pixels in the
  %   image or FOV (default 0.2, which will detect ~20% of the pixels).
  %   IUWT_PX_REMOVE - the minimum size an object needs to exceed in order to
  %   be kept, defined as a proportion of the image or FOV (default 0.05).
  %   IUWT_PX_FILL - the minimum size of a 'hole' (i.e. an undetected region
  %   entirely surrounded by detected pixels), defined as a proportion of the
  %   image or FOV.  Smaller holes will be filled in (default 0.05).
  %
  %
  % Copyright � 2011 Peter Bankhead.
  % See the file : Copyright.m for further details.

  if isempty(vessel_data.bw) % use wavelet based segmentation
    % Compute IUWT and do segmentation
    jprintf('   Wavelet filtering ');
    w = iuwt_vessels(vessel_data.im, args.iuwt_w_levels);
    done(toc);

    jprintf('   Segmenting filtered image...');
    vessel_data.bw = percentage_segment(w, args.iuwt_w_thresh, args.iuwt_dark);
    % Get total number of pixels to convert percentages
  else
    tic
    fprintf('   Using provided binarized images, NOT using wavelets...');
  end
  %
  % if ~isempty(vessel_data.bw_mask)
  %     scale = nnz(vessel_data.bw_mask) / 100;
  % else
      scale = numel(vessel_data.bw) / 100;
  % end


  % Remove small objects and fill holes
  vessel_data.bw = clean_segmented_image(vessel_data.bw, args.iuwt_px_remove * scale, args.iuwt_px_fill * scale);

  % Set DARK property of vessel_data
  vessel_data.dark_vessels = args.iuwt_dark;
  done(toc);
end
