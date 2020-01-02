function [DiameterStats] = get_diameter_stats(AllVessels)
  % all vessels is a list with each cell entry giving info about indivd. vessels
  % vessels consist of a center line, edges and have a length and such
  % get_diameter_stats calculates the statisitics of each ind. vessels diameters
  % using the seperate segements of each vessel 
  fun = @(x) remove_nan(x);
  DiameterStats = cellfun(fun, {AllVessels.diameters}, 'UniformOutput', false);
  fun = @(x) get_descriptive_stats(x(:));
  DiameterStats = cell2mat(cellfun(fun, DiameterStats, 'UniformOutput', false));
end
