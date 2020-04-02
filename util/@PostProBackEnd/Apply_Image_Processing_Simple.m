function [filtIm] = Apply_Image_Processing_Simple(PPA, baseIm)

  if PPA.VolGUI.VolClaheCheckBox.Value
    IMF = Image_Filter(baseIm);
    % setup clahe filter with latest values
    % IMF.claheDistr = PPA.GUI.ClaheDistr.Value;
    IMF.claheNBins = 256;
    IMF.claheLim = PPA.VolGUI.ClipLimitEditField.Value;
    IMF.claheNTiles = [32 32];
    IMF.Apply_CLAHE();
    filtIm = IMF.filt;
  else
    filtIm = baseIm;
  end

end
