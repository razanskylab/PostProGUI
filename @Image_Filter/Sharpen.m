% imsharpen --------------------------------------------------------------
function [filtImage] = Sharpen(IMF)
  IMF.VPrintF('[IMF] Sharpen image using unsharp masking...');

  minmaxPre = minmax(IMF.filt); % get orignal min max
  IMF.filt = normalize(IMF.filt);

  IMF.filt = imsharpen(IMF.filt, 'Radius', IMF.sharpRadius, 'Amount', IMF.sharpAmout, ...
    'Threshold', IMF.sharpThresh);

  IMF.filt = normalize(IMF.filt); % normalize again, then restore orig scale
  IMF.filt = reverse_normalize(IMF.filt, minmaxPre); % restore old max values
  filtImage = IMF.filt;
end
