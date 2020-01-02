function [Maps] = aova_analysis(Maps)
  % aoava - automatic oa vessels analyzer
  % bascically just stole code from aria - automatic retinal image analyzer
  % will add more cool stuff eventually

  [AovaSettings] = get_aova_settings(0);

  % this is only for plotting using imshow (and imagesc?)
  VesselSettings = Vessel_Settings;
  VesselData = Vessel_Data(VesselSettings);
  VesselData.im = single(Maps.xy);
  VesselData.im_orig = single(Maps.xy);
  mapWasBinarized = ~isempty(Maps.bin);
  if mapWasBinarized
    VesselData.bw = Maps.bin;
  end

  % Apply the acutal algorithm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Segment the image using the isotropic undecimated wavelet transform
  [AovaSettings] = segment_raw_image(VesselData, AovaSettings);

  % Compute centre lines and profiles by spline-fitting
  jprintf('   Extracting vessel profiles...');
  [AovaSettings] = centre_spline_fit(VesselData, AovaSettings);
  done(toc);

  % Do the rest of the processing, and detect vessel edges using a gradient
  % method
  jprintf('   Calculating vessel widths...');
  [AovaSettings] = edges_max_gradient(VesselData, AovaSettings);
  done(toc);

  % Make sure NaNs are 'excluded' from summary measurements
  VesselData.vessel_list.exclude_nans;

  % Store the arguments so that they are still available if the VESSEL_DATA
  % object is saved later
  VesselData.args = AovaSettings;
  Maps.VesselData = VesselData;
  % vessel statistics also need binarzied mask, if none was supplied with the Maps class,
  % then AOVA created one. Store that mask as the new binary mask for the Map
  if ~mapWasBinarized
    Maps.bin = VesselData.bw;
  end
end
