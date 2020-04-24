function Apply_Polarity_Volume(PPA)
  % Apply_Polarity_Volume converts bipolar volume signal
  % to unipolar
  %
  % See also Med_Filt_Volume(), Crop_Volume()
  try

    if PPA.doVolPolarity
      PPA.Start_Wait_Bar(PPA.VolGUI, 'Applying signal polarity to volumetric data.');
      statusText = sprintf('Applying signal polarity (%s) to volumetric data.', ...
        PPA.VolGUI.PolarityDropDown.Value);
      PPA.Update_Status(statusText);
      [nX, nY, nZ] = size(PPA.filtVol);
      PPA.procVol = reshape(PPA.filtVol, nX * nY, nZ)';
      PPA.procVol = apply_signal_polarity(PPA.procVol, PPA.volPolarity);
      PPA.procVol = reshape(PPA.procVol', nX, nY, nZ);
      PPA.Stop_Wait_Bar();
    else
      PPA.procVol = PPA.filtVol; % use full polarity if nothing selected
    end

  catch me
    PPA.Stop_Wait_Bar();
    rethrow(me);
  end

end