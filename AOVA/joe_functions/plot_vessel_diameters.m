function [allDiameters] = plot_vessel_diameters(vessel_list,cMap,areaScaling)
  % Somewhat convoluted but improves painting speed by rather
  % a lot (perhaps 5-10 times), and also improves toggling
  % visible / invisible speed.
  % Because centre lines and vessel edges will either all be
  % shown or none at all, each can be plotted as a single
  % 'line' object rather than separate objects for each
  % vessel.  To do so, they need to be converted into single
  % vectors, with NaN values where points should not be
  % connected (i.e. between vessels).
  % Paint centre lines
  % if nargin < 3
  %   lineWidth = 2;
  %   color = Colors.PureRed;
  % elseif nargin < 2
  %   color = Colors.PureRed;
  % end


  % get all center positions
  fun = @(x) cat(1, x,[NaN NaN]);
  centers = cellfun(fun, {vessel_list.centre}, 'UniformOutput', false);
  centers = cell2mat(centers');

  % get all corresponding diameters
  fun = @(x) cat(1, x,NaN);
  diameters = cellfun(fun, {vessel_list.diameters}, 'UniformOutput', false);
  diameters = cell2mat(diameters');

  % create colormap based on diameters, the smaller the number of colors the faster
  nColors = size(cMap,1);

  diaStats = get_descriptive_stats(diameters);
  lowerBound = diaStats.mean-diaStats.std*1;
  upperBound = diaStats.mean+diaStats.std*1.5;
  diameters(diameters>upperBound)=upperBound;
  diameters(diameters<lowerBound)=lowerBound;
  allDiameters = diameters;
  % split up diameters and corresponding center positions based on their plot color
  groups = discretize(diameters,nColors);

  holdfig=ishold; % Get hold state
  hold on;

  % loop trough all colors and plot
  for iColor = 1:nColors
    % plotIdx = find(groups==iColor);
    plotCenters = centers(groups==iColor,:);
    % line(plotCenters(:,2), plotCenters(:,1),'LineStyle','-','Color', cMap(iColor,:),'linewidth', 1);
    scatter(plotCenters(:,2), plotCenters(:,1),iColor*areaScaling,'MarkerFaceColor', cMap(iColor,:),'MarkerEdgeColor','none');
  end

  if not(holdfig)
    hold off;
  end % Restore hold state

  %
  %
  % fun = @(x) cat(1, x, [nan, nan]);
  % temp = cellfun(fun, {vessel_list.centre}, 'UniformOutput', false);
  % % cent = cell2mat(temp');
  % line(cent(:,2), cent(:,1),'LineStyle','-','Color', color,'linewidth', lineWidth);
  %
  % nVessels = numel(vessel_list);
  % for iVessel = 1:nVessels
  %   x = vessel_list(iVessel, 1).centre(:,2);
  %   y = vessel_list(iVessel, 1).centre(:,1);
  %   z = zeros(size(x));
  %   x = x';
  %   y = y';
  %   z = z';
  %   col = vessel_list(iVessel, 1).diameters;  % This is the color, vary with x in this case.
  %   col = col';
  %   % surface([x;x],[y;y],[z;z],[col;col],...
  %   % 'facecol','no',...
  %   % 'edgecol','interp',...
  %   % 'linew',2);
  %   colormapline(x,y,[],jet(256));
  % end

end
