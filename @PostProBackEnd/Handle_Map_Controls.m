function Handle_Map_Controls(PPA)

  if PPA.Is_Visible(PPA.MapGUI)
    % enable/disable controls in GUI
    PPA.MapGUI.ClaheDistr.Enable = PPA.MapGUI.ContrastCheck.Value;
    PPA.MapGUI.ClaheBins.Enable = PPA.MapGUI.ContrastCheck.Value;
    PPA.MapGUI.ClaheTiles.Enable = PPA.MapGUI.ContrastCheck.Value;
    PPA.MapGUI.ClaheClipLim.Enable = PPA.MapGUI.ContrastCheck.Value;

    PPA.MapGUI.imInterpFct.Enable = PPA.MapGUI.InterpolateCheckBox.Value;

    PPA.MapGUI.WienerSize.Enable = PPA.MapGUI.WienerCheckBox.Value;

    PPA.MapGUI.ImGuideSizeEditField.Enable = PPA.MapGUI.ImageGuidedCheckBox.Value;
    PPA.MapGUI.ImGuideSmoothSlider.Enable = PPA.MapGUI.ImageGuidedCheckBox.Value;

    PPA.MapGUI.ContrastLowLimEdit.Enable = PPA.MapGUI.AdjustContrastCheckBox.Value && ...
      ~PPA.MapGUI.AutoContrCheckBox.Value;
    PPA.MapGUI.ContrastUpLimEdit.Enable = PPA.MapGUI.AdjustContrastCheckBox.Value && ...
      ~PPA.MapGUI.AutoContrCheckBox.Value;
    PPA.MapGUI.ContrastGammaEdit.Enable = PPA.MapGUI.AdjustContrastCheckBox.Value;
    PPA.MapGUI.AutoContrCheckBox.Enable = PPA.MapGUI.AdjustContrastCheckBox.Value;
  end

end
