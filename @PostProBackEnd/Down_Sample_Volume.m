function Down_Sample_Volume(PPA)
  % Down_Sample_Volume  simple index based downsampling of volume datasets
  % 
  % TODO
  % - use mip or mean to get smoother / better downsampled volumes
  % 
  % See also Med_Filt_Volume(), Crop_Volume(),
  try

    if PPA.doVolDownSampling
      statusText = sprintf('Downsampling volumetric data (lateral x%i depth x%i).', PPA.volSplFactor);
      PPA.Start_Wait_Bar(PPA.VolGUI,statusText);
      PPA.dsVol = PPA.rawVol(1:PPA.volSplFactor(2):end, ...
        1:PPA.volSplFactor(1):end, 1:PPA.volSplFactor(1):end);
      PPA.Stop_Wait_Bar();
    else
      PPA.dsVol = PPA.rawVol;
    end

  catch me
    PPA.Stop_Wait_Bar();
    rethrow(me);
  end

end
