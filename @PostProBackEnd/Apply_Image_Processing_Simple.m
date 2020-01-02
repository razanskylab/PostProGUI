function [filtIm] = Apply_Image_Processing_Simple(PPA,baseIm)

  interpFactor = PPA.GUI.imInterpFct.Value;
  IMF = Image_Filter(baseIm);

  if PPA.GUI.InterpolateCheckBox.Value
    IMF.Interpolate(interpFactor);
    % also interpolate depth data, so they match for later overlay...
  end

  if PPA.GUI.ContrastCheck.Value
    % setup clahe filter with latest values
    IMF.claheDistr = PPA.GUI.ClaheDistr.Value;
    IMF.claheNBins = str2double(PPA.GUI.ClaheBins.Value);
    IMF.claheLim = PPA.GUI.ClaheClipLim.Value;
    nTiles = str2double(PPA.GUI.ClaheTiles.Value);
    IMF.claheNTiles = [nTiles nTiles];
    IMF.Apply_CLAHE();
  end

  filtIm = IMF.filt;

end
