function Crop_Volume(PPA)
  % Crop_Volume  remove first and last rows of volume
  %
  % See also Med_Filt_Volume(), Down_Sample_Volume(),
  try

    if PPA.GUI.CropCheck.Value
      statusText = sprintf('Cropping volumetric data (%i:%i).', minmax(PPA.cropRange));
      PPA.Start_Wait_Bar(statusText);
      PPA.cropVol = PPA.dsVol(PPA.cropRange, :, :);
      PPA.Stop_Wait_Bar();
    else
      PPA.cropVol = PPA.dsVol;
    end

  catch me
    PPA.Stop_Wait_Bar();
    rethrow(me);
  end

end
