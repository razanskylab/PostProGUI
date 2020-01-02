% Interpolate --------------------------------------------------------------
function Interpolate(ImF,interpFactor)
  % interpolate xy map and update x and y vectors accordingly
  if nargin == 2
    ImF.interpFactor = interpFactor;
  end
  tic;
  % only output text if verbose output is on...
  ImF.VPrintF('[Map] Interpolating (k=%i)...',ImF.interpFactor);

  % get interpolated x and y vectors
  xI = ImF.x(1):(ImF.dX/ImF.interpFactor):ImF.x(end);
  yI = ImF.y(1):(ImF.dY/ImF.interpFactor):ImF.y(end);
  % turn 400 x 400 px image into 800 x 800 px image and not 799 x 799
  xI = linspace(ImF.x(1),ImF.x(end),length(xI)+1);
  yI = linspace(ImF.y(1),ImF.y(end),length(yI)+1);
  % interpolate xy maps based on new x-y vectors
  [X,Y] = meshgrid(ImF.x,ImF.y);
  [XI,YI] = meshgrid(xI,yI);
  extrapVal = 0; % in case we have to extrapolate
  ImF.filt = interp2(X, Y, ImF.filt, XI, YI, ImF.interpMethod, extrapVal);
  ImF.x = xI;
  ImF.y = yI;
  % only output text if verbose output is on...
  ImF.Done();
end
