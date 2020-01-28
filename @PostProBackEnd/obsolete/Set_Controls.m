function Set_Controls(PPA, controlState)

  disableDefaultInteractivity(PPA.GUI.histoAx);
  PPA.GUI.histoAx.Toolbar.Visible = 'off';

  if isempty(controlState)
    controlState = 'default';
  end

  switch controlState
    case 'default'
      PPA.GUI.TabGroup.SelectedTab = PPA.GUI.VolTab;

      PPA.GUI.DwnSplCheck.Enable = true;
      PPA.GUI.DwnSplCheck.Value = 0;
      PPA.GUI.DwnSplFactorEdit.Enable = PPA.GUI.DwnSplCheck.Value;
      PPA.GUI.DepthDwnSplFactorEdit.Enable = PPA.GUI.DwnSplCheck.Value;

      PPA.GUI.CropCheck.Enable = true;
      PPA.GUI.zCropLowEdit.Enable = PPA.GUI.CropCheck.Value;
      PPA.GUI.zCropHighEdit.Enable = PPA.GUI.CropCheck.Value;

      PPA.GUI.FreqFiltCheck.Enable = true;
      PPA.GUI.filtDesign.Enable = PPA.GUI.FreqFiltCheck.Value;
      PPA.GUI.filtType.Enable = PPA.GUI.FreqFiltCheck.Value;
      PPA.GUI.MHzLabel.Enable = PPA.GUI.FreqFiltCheck.Value;
      PPA.GUI.freqHigh.Enable = PPA.GUI.FreqFiltCheck.Value;
      PPA.GUI.freqLow.Enable = PPA.GUI.FreqFiltCheck.Value;
      PPA.GUI.filtOrder.Enable = PPA.GUI.FreqFiltCheck.Value;

      PPA.GUI.PolarityCheck.Enable = true;
      PPA.GUI.PolarityDropDown.Enable = PPA.GUI.PolarityCheck.Value;

      PPA.GUI.MedFiltCheck.Enable = true;
      PPA.GUI.MedFiltX.Enable = PPA.GUI.MedFiltCheck.Value;
      PPA.GUI.MedFiltY.Enable = PPA.GUI.MedFiltCheck.Value;
      PPA.GUI.MedFiltZ.Enable = PPA.GUI.MedFiltCheck.Value;

      PPA.GUI.SliceWidthEditField.Enable = true;

      PPA.GUI.yzSliceDisp.Visible = true;
      PPA.GUI.xzSliceDisp.Visible = true;
      PPA.GUI.xzProjDisp.Visible = true;
      PPA.GUI.yzProjDisp.Visible = true;

    case 'map_only'
      % automatically switch to processing tab for images
      PPA.GUI.TabGroup.SelectedTab = PPA.GUI.ImageProcessingTab;

      PPA.GUI.DwnSplCheck.Enable = false;
      PPA.GUI.DwnSplFactorEdit.Enable = false;

      PPA.GUI.CropCheck.Enable = false;
      PPA.GUI.zCropLowEdit.Enable = false;
      PPA.GUI.zCropHighEdit.Enable = false;

      PPA.GUI.FreqFiltCheck.Enable = false;
      PPA.GUI.filtDesign.Enable = false;
      PPA.GUI.filtType.Enable = false;
      PPA.GUI.MHzLabel.Enable = false;
      PPA.GUI.freqHigh.Enable = false;
      PPA.GUI.freqLow.Enable = false;
      PPA.GUI.filtOrder.Enable = false;

      PPA.GUI.PolarityCheck.Enable = false;
      PPA.GUI.PolarityDropDown.Enable = false;

      PPA.GUI.MedFiltCheck.Enable = false;
      PPA.GUI.MedFiltX.Enable = false;
      PPA.GUI.MedFiltY.Enable = false;
      PPA.GUI.MedFiltZ.Enable = false;

      PPA.GUI.SliceWidthEditField.Enable = false;

      PPA.GUI.yzSliceDisp.Visible = false;
      PPA.GUI.xzSliceDisp.Visible = false;
      PPA.GUI.xzProjDisp.Visible = false;
      PPA.GUI.yzProjDisp.Visible = false;

  end

end
