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
      tempVol = PPA.filtVol;
      [nX, nY, nZ] = size(tempVol);
      tempVol = reshape(tempVol, nX * nY, nZ)';
      tempVol = apply_signal_polarity(tempVol, PPA.volPolarity);
      tempVol = reshape(tempVol', nX, nY, nZ);
      PPA.procVol = tempVol;
      PPA.Stop_Wait_Bar();
    else
      PPA.procVol = PPA.filtVol; % use full polarity if nothing selected
    end

  catch me
    PPA.Stop_Wait_Bar();
    rethrow(me);
  end

end