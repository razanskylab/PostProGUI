function [] = Filter_2D_fast(F)
  % This function FRANGIFILTER2D uses the eigenvectors of the Hessian to
  % see FrangiFilter2D for original version
  % this one has some new options for processing and is optimized for optimal
  % speed while sacrificing memory efficiency and some of the original functionality

  % FrangiScale = sigma^2
  sigmas = sort(F.allEffectiveScales);
%   sigmas = sort(F.allScales);

  % Make matrices to store all filterd images
  allFiltered = zeros([size(F.filt) length(sigmas)]);
  nSigmas = length(sigmas);

  % Frangi filter for all sigmas
  for iSigma = 1:nSigmas
      % Make 2D hessian
      [Dxx,Dxy,Dyy] = F.Hessian2D(F.filt,sigmas(iSigma));

      % Correct for scale
      Dxx = (sigmas(iSigma)^2)*Dxx;
      Dxy = (sigmas(iSigma)^2)*Dxy;
      Dyy = (sigmas(iSigma)^2)*Dyy;

      % Calculate (abs sorted) eigenvalues and vectors
      [Lambda2,Lambda1] = F.eig2image_fast(Dxx,Dxy,Dyy);

      % Compute some similarity measures
      Lambda1(Lambda1==0) = eps;
      Rb = (Lambda2./Lambda1).^2;
      S2 = Lambda1.^2 + Lambda2.^2;

      Ifiltered = exp(-Rb / F.betaOne) .* (ones(size(F.filt)) - exp(-S2 / F.betaTwo));

      % see pp. 45
      if F.invert
          Ifiltered(Lambda1<0)=0;
      else
          Ifiltered(Lambda1>0)=0;
      end
      % store the results in 3D matrices
      allFiltered(:,:,iSigma) = Ifiltered;
  end

  % Return for every pixel the value of the scale(sigma) with the maximum
  % output pixel value
  if length(sigmas) > 1
      outIm = max(allFiltered,[],3);
      outIm = reshape(outIm,size(F.filt));
  else
      outIm = reshape(allFiltered,size(F.filt));
  end
  % save values in the class
  F.filt = outIm;
  F.filtScales = allFiltered;
end
