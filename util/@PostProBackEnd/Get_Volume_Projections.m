function [projIm, maxIdx] = Get_Volume_Projections(~, rawVol, dim)
  % get projection and then transpose, so that it can be used
  % with imagesc(x,y,image) + axis xy and everything is right!

  if (nargin == 2)
    dim = 3;
  end

  if (nargout == 1)
    projIm = squeeze(max(rawVol, [], dim));
    projIm = imrotate(projIm, -90);
  elseif (nargout == 2)
    [projIm, maxIdx] = max(rawVol, [], dim);
    projIm = imrotate(projIm, -90);
    maxIdx = imrotate(maxIdx, -90);
  end

end
