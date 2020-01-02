function Update_Controls(PPA)

  % enable/disable controls in GUI
  PPA.GUI.ClaheDistr.Enable = PPA.GUI.ContrastCheck.Value;
  PPA.GUI.ClaheBins.Enable = PPA.GUI.ContrastCheck.Value;
  PPA.GUI.ClaheTiles.Enable = PPA.GUI.ContrastCheck.Value;
  PPA.GUI.ClaheClipLim.Enable = PPA.GUI.ContrastCheck.Value;

  PPA.GUI.imInterpFct.Enable = PPA.GUI.InterpolateCheckBox.Value;

  PPA.GUI.WienerSize.Enable = PPA.GUI.WienerCheckBox.Value;

  PPA.GUI.UnsharpMaskRadiusEditField.Enable = PPA.GUI.UnsharpMaskingCheckBox.Value;
  PPA.GUI.UnsharpMaskThresholdEditField.Enable = PPA.GUI.UnsharpMaskingCheckBox.Value;
  PPA.GUI.UnsharpMaskAmountSlider.Enable = PPA.GUI.UnsharpMaskingCheckBox.Value;

  PPA.GUI.ImGuideSizeEditField.Enable = PPA.GUI.ImageGuidedCheckBox.Value;
  PPA.GUI.ImGuideSmoothSlider.Enable = PPA.GUI.ImageGuidedCheckBox.Value;

  PPA.GUI.ContrastLowLimEdit.Enable = PPA.GUI.AdjustContrastCheckBox.Value && ...
    ~PPA.GUI.AutoContrCheckBox.Value;
  PPA.GUI.ContrastUpLimEdit.Enable = PPA.GUI.AdjustContrastCheckBox.Value && ...
    ~PPA.GUI.AutoContrCheckBox.Value;
  PPA.GUI.ContrastGammaEdit.Enable = PPA.GUI.AdjustContrastCheckBox.Value;
  PPA.GUI.AutoContrCheckBox.Enable = PPA.GUI.AdjustContrastCheckBox.Value;

end
