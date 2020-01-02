function [Dxx, Dxy, Dyy] = Hessian2D(~,I, sigma)
  %  This function Hessian2 Filters the image with 2nd derivatives of a
  %  Gaussian with parameter sigma.

  % Make kernel coordinates
  [X, Y] = ndgrid(-round(3 * sigma):round(3 * sigma));

  % Build the gaussian 2nd derivatives filters
  dGaussxx = 1 / (2 * pi * sigma^4) * (X.^2 / sigma^2 - 1) .* exp(-(X.^2 + Y.^2) / (2 * sigma^2));
  dGaussxy = 1 / (2 * pi * sigma^6) * (X .* Y) .* exp(-(X.^2 + Y.^2) / (2 * sigma^2));
  dGaussyy = dGaussxx';

  Dxx = imfilter(I, dGaussxx, 'conv', 'replicate');
  Dxy = imfilter(I, dGaussxy, 'conv', 'replicate');
  Dyy = imfilter(I, dGaussyy, 'conv', 'replicate');
end
