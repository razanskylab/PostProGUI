function [allDiameters] = plot_vessel_diameters_lines(vessel_list,cMap,maxLineWidth)
  holdfig=ishold; % Get hold state
  hold on;

  % get all diameters, floor the outliers and get bins, which are later used for
  % coloring the lines
  fun = @(x) cat(1, x);
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
  [~,edges] = discretize(diameters,nColors);

  nVessels = numel(vessel_list);

  jprintf('Plotting color coded vessel centerlines...')
  xlim(xlim);
  ylim(ylim);

  hold on
  for iVessel = 1:nVessels
    x = vessel_list(iVessel, 1).centre(:,2);
    y = vessel_list(iVessel, 1).centre(:,1);
    diameters = vessel_list(iVessel, 1).diameters;
    diameters(diameters>upperBound)=upperBound;
    diameters(diameters<lowerBound)=lowerBound;
    diaEdges = discretize(diameters,edges,edges(2:end));
    [~,bins] = ind2sub([numel(diaEdges),numel(edges)], find(edges==diaEdges));
    bins = bins-1;
    lineWidths = bins./nColors*maxLineWidth;
    colors = cMap(bins,:);
    colormapline(x,y,colors,lineWidths);
    if mod(iVessel,50)==0
     drawnow();
    end
  end

  if not(holdfig)
    hold off;
  end % Restore hold state

  done(toc);


end
