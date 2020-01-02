function [AVA] = Get_Data(AVA)
  % this is a computationally expensive function, hence we leave it as a
  % normal method to be invoked on purpose rather than making it a .get
  % method of the class
  % same goes for the Get_VesselStats method
  fprintf('[AVA.Get_Data] Finding and analyzing vessels.\n');
  % this is only for plotting using imshow (and imagesc?)
  VesselSettings = Vessel_Settings;
  Data = Vessel_Data(VesselSettings);
  Data.im = single(AVA.xy);
  Data.im_orig = single(AVA.xy);

  % if binarized image was provided to AVA then use that one
  % otherwise
  binWasProvided = ~isempty(AVA.bin);
  if binWasProvided
    Data.bw = AVA.bin;
  end

  % Apply the acutal algorithm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Segment the image using the isotropic undecimated wavelet transform
  [AVA.AviaSettings] = seg_iuwt(Data, AVA.AviaSettings);
  if AVA.verbosePlotting
    figure;
    imagescj(Data.bw); axis off; colorbar('off');
    title('[AVA] Cleaned, Binarized Image');
  end

  % Compute centre lines and profiles by spline-fitting
  jprintf('   Extracting vessel profiles...');
  [AVA.AviaSettings] = centre_spline_fit(Data, AVA.AviaSettings);
  done(toc);

  % Do the rest of the processing, and detect vessel edges using a gradient
  % method
  jprintf('   Calculating vessel widths...');
  [AVA.AviaSettings] = edges_max_gradient(Data, AVA.AviaSettings);
  done(toc);

  % Make sure NaNs are 'excluded' from summary measurements
  Data.vessel_list.exclude_nans;

  % Store the arguments so that they are still available if the VESSEL_DATA
  % object is saved later
  Data.args = AVA.AviaSettings;
  AVA.Data = Data;
  % vessel statistics also need binarzied mask, if none was supplied with the AVA class,
  % then AOVA created one. Store that mask as the new binary mask for the Map
  if ~binWasProvided
    AVA.bin = Data.bw;
  end
end
