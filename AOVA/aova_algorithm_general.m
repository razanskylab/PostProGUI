function [vessel_data, args] = aova_algorithm_general(vessel_data, args, prompt)

  % Segment the image using the isotropic undecimated wavelet transform
  [args] = seg_iuwt(vessel_data, args);
  if show_debug_plot_w_figure()
    imagescj(vessel_data.bw);
    title('Cleaned, Binarized Image');
  end

  % Compute centre lines and profiles by spline-fitting
  jprintf('   Extracting vessel profiles...');
  [args] = centre_spline_fit(vessel_data, args);
  done(toc);

  % Do the rest of the processing, and detect vessel edges using a gradient
  % method
  jprintf('   Calculating vessel widths...');
  [args] = edges_max_gradient(vessel_data, args);
  done(toc);

  % Make sure NaNs are 'excluded' from summary measurements
  vessel_data.vessel_list.exclude_nans;

  % Store the arguments so that they are still available if the VESSEL_DATA
  % object is saved later
  vessel_data.args = args;
end
