% all "simple" image filters are applied here, as most filters
% are really one-liners with pre & post normalization and
% some text...

function [filtImage] = Apply_Image_Filter(IMF, filterType, inputIm)

  if nargin < 2
    error('Apply_Image_Filter(filterType) requires a filterType argument!');
  end

  minmaxPre = minmax(IMF.filt); % get orignal min max
  IMF.filt = normalize(IMF.filt);
  tic();
  % here we have a normalized image and apply our filtering
  switch filterType
      % ----------------------------------------------------------------------
    case 'Guided_Filtering'
      % NOTE the original authors have posted a faster version of their
      % original algorithm, however, for our image sizes it does not seem
      % to be significanly faster (only did a quick test though...)
      IMF.VPrintF('[IMF] Image guided filtering...');

      if (nargin == 3)% guide image provided
        IMF.filt = imguidedfilter(IMF.filt, inputIm, 'NeighborhoodSize', IMF.imGuideNhoodSize, ...
          'DegreeOfSmoothing', IMF.imGuideSmoothValue);
      else % guide image is image itself
        IMF.filt = imguidedfilter(IMF.filt, IMF.filt, 'NeighborhoodSize', IMF.imGuideNhoodSize, ...
          'DegreeOfSmoothing', IMF.imGuideSmoothValue);
      end

      % ----------------------------------------------------------------------
    case 'Apply_Wiener'
      IMF.VPrintF('[IMF] Applying wiener filter...');
      IMF.filt = wiener2(IMF.filt, [IMF.nWienerPixel IMF.nWienerPixel]);

      % ----------------------------------------------------------------------
    case 'Apply_CLAHE'
      IMF.VPrintF('[IMF] CLAHE contrast enhancement...');

      % make sure we use smaller tiles for small images
      imageSize = size(IMF.filt);

      if any(IMF.claheNTiles > min(imageSize))
        IMF.claheNTiles = [min(imageSize) min(imageSize)];
      end

      % perform actual clahe filtering
      IMF.filt = adapthisteq(IMF.filt, 'Distribution', IMF.claheDistr, 'NBins', IMF.claheNBins, ...
        'ClipLimit', IMF.claheLim, 'NumTiles', IMF.claheNTiles);

      % ----------------------------------------------------------------------
    case 'Adjust_Contrast'
      IMF.VPrintF('[IMF] Adjusting image intensity...');

      if IMF.imadAuto
        inLimits = stretchlim(IMF.filt);
      else
        inLimits = IMF.imadLimIn;
      end

      IMF.filt = imadjust(IMF.filt, inLimits, IMF.imadLimOut, IMF.imadGamme);

  end

  IMF.filt = normalize(IMF.filt); % normalize again, then restore orig scale
  IMF.filt = reverse_normalize(IMF.filt, minmaxPre); % restore old max values

  if nargout == 1
    filtImage = IMF.filt;
  end

  IMF.Done();
end
