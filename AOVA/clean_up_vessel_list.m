function [CleanList] = clean_up_vessel_list(VesselList)

  jprintf('   Removing short and NaN vessels...');
  % get all diameters positions
  fun = @(x) cat(2, x);
  allDias = cellfun(fun, {VesselList.diameters}, 'UniformOutput', false);

  % get all center positions
  fun = @(x) cat(2, x);
  allCenters = cellfun(fun, {VesselList.centre}, 'UniformOutput', false);

  % get number of entries per vessel
  fun = @(x) numel(x);
  nEntries = cell2mat(cellfun(fun, allDias, 'UniformOutput', false));

  fun = @(x) sum(any(isnan(x)));
  nanDias = cell2mat(cellfun(fun, allDias, 'UniformOutput', false));
  nanCenters = cell2mat(cellfun(fun, allCenters, 'UniformOutput', false));

  tooFewEntries = 3;
  isTooShort = nEntries<=tooFewEntries;

  removeEntries = isTooShort | nanCenters | nanDias;

  CleanList = VesselList(~removeEntries);

  fprintf('removed %i vessels in %1.2f s\n',sum(removeEntries),toc);

end
