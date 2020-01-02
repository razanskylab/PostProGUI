function [] = Filter_2D_Matlab(F)
  % This function FRANGIFILTER2D uses the eigenvectors of the Hessian to
  % see FrangiFilter2D for original version
  % this one has some new options for processing and is optimized for optimal
  % speed while sacrificing memory efficiency and some of the original functionality

  % FrangiScale = sigma^2
  sigmas = sort(F.allScales)*5;
  nSigmas = length(sigmas);

  c = F.sensitivity; % 'StructureSensitivity'

  sigmas = double(sigmas);
  unFilt = F.filt;
  F.filtScales = zeros([size(unFilt) nSigmas]);
  F.filt = zeros(size(F.filt), 'like', F.filt);

  for id = 1:nSigmas
    iSigma = sigmas(id) / 6;
    iFilt = imgaussfilt(unFilt, iSigma, 'FilterSize', 2 * ceil(3 * iSigma) + 1);
    iFilt = builtin("_fibermetricmex", iFilt, c, ~F.invert, iSigma);
    F.filt = max(F.filt, iFilt);
    F.filtScales(:, :, id) = iFilt;
  end

end

