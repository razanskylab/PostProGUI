function Get_Stats(AVA)
  % Get_Vessel_Stats returns vessels statisitics in microns
  % LengthStats - statisitics on vessel lengths
  % DiameterStats - statisitics on vessel diameters
  % TurtosityStats -  statisitics on vessel turtosity (arc-length/(endpoint distance))
    % each with the follwing statisitics:
    %  min = min(vect); % Smallest elements in array
    %  max = max(vect); % max	Largest elements in array
    %  bounds = bounds(vect); % bounds	Smallest and largest elements
    %  mean = mean(vect);   % mean	Average or mean value of array
    %  median = median(vect); % median	Median value of array
    %  mode = mode(vect); % mode	Most frequent values in array
    %  std = std(vect); % std	Standard deviation
    %  stdPer = std(vect)/mean(vect); % std	Standard deviation
    %  var = var(vect); % var	Variance
    %  nEntries = numel(vect); % number of vector elements
  % nVessels - total vessels found
  % totalLength - sum of all vessels
  t1 = tic;
  fprintf('[AVA.Get_Stats] Collecting vessel statistics.\n');
  pxToMicron = AVA.dR*1e3; % return vessels length and diameters in microns!

  % all vessels is a list with each cell entry giving info about indivd. vessels
  % vessels consist of a center line, edges and have a length and such
  % get_diameter_stats calculates the statisitics of each ind. vessels diameters
  % using the seperate segements of each vessel
  AllVessels = AVA.Data.vessel_list;

  % prepare data/stats to be stored in Stats struct %%%%%%%%%%%%%%%%%%%%%%
  % get lengths and straight lenghts as vectors, also calculate turtosity
  lengths = cell2mat({AllVessels.length_cumulative})*pxToMicron;
  straighLengths = cell2mat({AllVessels.length_straight_line})*pxToMicron;
  turtosity = lengths./straighLengths;

  % diameter stats are special, as they have multiple values per vessel
  % as diameter changes along the vessel
  % FullDiameterStats = stats for diameter of indivd vessels
  % DiameterStats = stats for mean vessel diameters
  [FullDiameterStats] = get_diameter_stats(AllVessels);
  diameters = [FullDiameterStats.mean]*pxToMicron;

  % store data in Stats struct %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  AVA.Stats.nVessels = AVA.Data.num_vessels;
  AVA.Stats.nBranches = AVA.Data.nBranches;
  AVA.Stats.totalLength = sum(lengths);

  AVA.Stats.Length = get_descriptive_stats(lengths,0);
  AVA.Stats.StraigtLenght = get_descriptive_stats(straighLengths,0);
  AVA.Stats.Diameter = get_descriptive_stats(diameters,0);
  AVA.Stats.FullDiameter = FullDiameterStats;
  AVA.Stats.Turtosity = get_descriptive_stats(turtosity,0);

  % vessel coverage in percent
  % coverage defined as nVesselPixel/nTotalPixel
  AVA.Stats.vesselCoverage = sum(AVA.bin(:))/numel(AVA.bin)*100;
  % vessel area density, defined as nVessel/area
  AVA.Stats.vesselAreaDensity = AVA.Stats.nVessels/AVA.area;

  % Vessel Data Relevant Infos ---------------------------------------------------
  fprintf('[AVA.Get_Stats] Vessels analysis on %i vessels completed in %2.2f s\n',AVA.Stats.nVessels,toc(t1));
end

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
