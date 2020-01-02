% Interpolate --------------------------------------------------------------
function interpXY = Equalize_Pixels(M)
  % interpolate xy map and depth info map so that dx and dy are equal
  if M.dX ~= M.dY
    t1 = tic;
    M.VPrintF('[Map] Equalizing x-y step sizes...');

    % imshow, montage etc needs equal dx and dy, so interpolate to get that
    % get new step size
    dR = min(M.dX,M.dY);

    % get interpolated x and y vectors
    xI = M.x(1):dR:M.x(end);
    yI = M.y(1):dR:M.y(end);
    % turn 400 x 400 px image into 800 x 800 px image and not 799 x 799
    xI = linspace(M.x(1),M.x(end),length(xI)+1);
    yI = linspace(M.y(1),M.y(end),length(yI)+1);
    % interpolate xy maps based on new x-y vectors
    [X,Y] = meshgrid(M.x,M.y);
    [XI,YI] = meshgrid(xI,yI);
    M.xy = interp2(X,Y,M.xy,XI,YI,M.interpMethod);
    % also update depth info if present
    if ~isempty(M.depthInfo)
      M.depthInfo = interp2(X,Y,M.depthInfo,XI,YI,M.interpMethod);
    end
    M.x = xI;
    M.y = yI;
    M.Done(t1);
  else
    M.VPrintF('[Map] X and Y step sizes are already equal!\n');
  end
end
