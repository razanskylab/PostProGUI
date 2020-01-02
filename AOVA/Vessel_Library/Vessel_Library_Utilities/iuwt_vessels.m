function w = iuwt_vessels(im, levels, padding)
  % Compute the sum of one or more wavelet levels computed using the
  % isotropic undecimated wavelet transform (IUWT).
  %
  % Input:
  %   IM - the input image
  %   LEVELS - a 1-dimensional vector giving the wavelet levels to compute
  %   PADDING - the same as the PADDING input argument in IMFILTER; here it
  %   is 'symmetric' by default.
  %
  % Output:
  %   W - the sum of the requested wavelet levels
  %
  %
  % This will compute transform and return the sum of the requested levels.
  % Therefore
  %     W = IUWT_VESSELS(IM, 1:5);
  % is equivalent to
  %     W = SUM(IUWT_VESSELS_ALL(IM, 1:5), 3);
  % assuming that IM is a 2D image, but using this function is more
  % efficient because individual levels are not stored longer than necessary.
  %
  % Copyright � 2011 Peter Bankhead.
  % See the file : Copyright.m for further details.

  fprintf('(levels %i-%i)...',levels(1),levels(end));
  % Default padding
  if nargin < 3
     padding = 'symmetric';
  end

  % First smoothing level = input image
  s_in = im;

  % Inititalise output
  w = 0;

  % B3 spline coefficients for filter
  b3 = [1 4 6 4 1] / 16;

  [m,n] = find_subplot_dividers(max(levels)*2);

  show_debug_plot_w_figure(); %  creates empty figure if debug plotting is on
  % Compute transform
  for processLevel = levels
    % Create convolution kernel
    h = dilate_wavelet_kernel(b3, 2^(processLevel-1)-1);

    % Convolve and subtract to get wavelet level
    s_out = imfilter(s_in, h' * h, padding);

    % Add wavelet level if in LEVELS
    if ismember(processLevel, levels)
        w = w + s_in - s_out;
    end

    % Update input for new iteration
    s_in = s_out;
    if show_debug_plot &&  ismember(processLevel, levels)
      subplot(m,n,2*processLevel-1);
      imagescj(s_out);
      title(sprintf('Level: %i',processLevel));
      subplot(m,n,2*processLevel);
      imagescj(w,'hot');
    end
  end
  if show_debug_plot
    sub_plot_title('Wavelet Levels')
  end
end

function h2 = dilate_wavelet_kernel(h, spacing)
  % Dilates a wavelet kernel by entering SPACING zeros between each
  % coefficient of the filter kernel H.

  % Check input
  if ~isvector(h) && ~isscalar(spacing)
      error(['Invalid input to DILATE_WAVELET_KERNEL: ' ...
            'H must be a vector and SPACING must be a scalar']);
  end

  % Preallocate the expanded filter
  h2 = zeros(1, numel(h) + spacing * (numel(h) - 1));
  % Ensure output kernel orientation is the same
  if size(h,1) > size(h,2)
      h2 = h2';
  end
  % Put in the coefficients
  h2(1:spacing+1:end) = h;
end
