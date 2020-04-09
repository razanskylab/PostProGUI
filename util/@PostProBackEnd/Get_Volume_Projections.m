function [projIm, maxIdx] = Get_Volume_Projections(~, rawVol, dim, rot)
  % get projection and then transpose, so that it can be used
  % with imagesc(x,y,image) + axis xy and everything is right!

  % default rotation of -90 to display images the same way we see 
  % them when scanned in the microscope (x = left-right...)
  if (nargin < 4)
    rot = -90;
  end
  if (nargin < 3)
    dim = 3;
  end

  if (nargout == 1)
    projIm = squeeze(max(rawVol, [], dim));
    projIm = imrotate(projIm, rot);
  elseif (nargout == 2)
    [projIm, maxIdx] = max(rawVol, [], dim);
    projIm = imrotate(projIm, rot);
    maxIdx = imrotate(maxIdx, rot);
  end

end
