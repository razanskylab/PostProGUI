function Restore_Gui_Settings(PPA,CS)
  % restores GUI processing settings to those stored in CS (restore settings)

  if CS.doMap
    if isempty(PPA.MapGUI)
      MapGui(PPA);
    elseif isa(PPA.MapGUI,'MapGui') && ishandle(PPA.MapGUI.UIFigure)
      PPA.MapGUI.UIFigure.Visible = 'on';
    end
    PPA.MapGUI.ContrastCheck.Value = CS.Map.ContrastCheck;           
    PPA.MapGUI.imSpotRem.Value = CS.Map.imSpotRem;               
    PPA.MapGUI.SpotRemovalCheckBox.Value = CS.Map.SpotRemovalCheckBox;     
    PPA.MapGUI.imInterpFactor.Value = CS.Map.imInterpFactor;          
    PPA.MapGUI.InterpolateCheckBox.Value = CS.Map.InterpolateCheckBox;     
    PPA.MapGUI.WienerCheckBox.Value = CS.Map.WienerCheckBox;          
    PPA.MapGUI.WienerSize.Value = CS.Map.WienerSize;              
    PPA.MapGUI.ImageGuidedCheckBox.Value = CS.Map.ImageGuidedCheckBox;     
    PPA.MapGUI.AdjustContrastCheckBox.Value = CS.Map.AdjustContrastCheckBox;  
    PPA.MapGUI.UseFrangiCheckBox.Value = CS.Map.UseFrangiCheckBox;       
    PPA.MapGUI.SpecialFilterCheckBox.Value = CS.Map.SpecialFilterCheckBox;   
    PPA.MapGUI.ClaheBins.Value = CS.Map.ClaheBins;               
    PPA.MapGUI.ClaheTiles.Value = CS.Map.ClaheTiles;              
    PPA.MapGUI.ClaheClipLim.Value = CS.Map.ClaheClipLim;            
    PPA.MapGUI.ClaheDistr.Value = CS.Map.ClaheDistr;              
    PPA.MapGUI.ImGuideSizeEditField.Value = CS.Map.ImGuideSizeEditField;    
    PPA.MapGUI.ImGuideSmoothSlider.Value = CS.Map.ImGuideSmoothSlider;     
    PPA.MapGUI.OffsetmmEditField.Value = CS.Map.OffsetmmEditField;       
    PPA.MapGUI.RemoveTrendCheckBox.Value = CS.Map.RemoveTrendCheckBox;     
    PPA.MapGUI.TranspEditField.Value = CS.Map.TranspEditField;         
    PPA.MapGUI.MinAmpEditField.Value = CS.Map.MinAmpEditField;         
    PPA.MapGUI.SmoothEditField.Value = CS.Map.SmoothEditField;         
    PPA.MapGUI.depthColor.Value = CS.Map.depthColor;              
    PPA.MapGUI.topcutEditField.Value = CS.Map.topcutEditField;         
    PPA.MapGUI.depthcutEditField.Value = CS.Map.depthcutEditField;       
    PPA.MapGUI.depthoffsetSlider.Value = CS.Map.depthoffsetSlider;       
    PPA.MapGUI.surfaceoffsetSlider.Value = CS.Map.surfaceoffsetSlider;     
    PPA.MapGUI.CropDepthDropDown.Value = CS.Map.CropDepthDropDown;       
    PPA.MapGUI.shiftEditField.Value = CS.Map.shiftEditField;          
    PPA.MapGUI.FiltStrength.Value = CS.Map.FiltStrength;            
    PPA.MapGUI.FilterDropDown.Value = CS.Map.FilterDropDown;          
    PPA.MapGUI.FiltSize.Value = CS.Map.FiltSize;                
    PPA.MapGUI.ContrastLowLimEdit.Value = CS.Map.ContrastLowLimEdit;      
    PPA.MapGUI.ContrastUpLimEdit.Value = CS.Map.ContrastUpLimEdit;       
    PPA.MapGUI.ContrastGammaEdit.Value = CS.Map.ContrastGammaEdit;       
    PPA.MapGUI.AutoContrCheckBox.Value = CS.Map.AutoContrCheckBox;    
  end

  if CS.doMapFrangi
    if isempty(PPA.MapFrangi)
      PPA.Init_Frangi('map');
    elseif isa(PPA.MapFrangi,'Frangi_Filter') && ishandle(PPA.MapFrangi.GUI.UIFigure)
      PPA.MapFrangi.GUI.Visible = 'on';
    end
    PPA.MapFrangi.GUI.AutoUpdateCheckBox.Value = CS.MapFrangi.AutoUpdateCheckBox;         
    PPA.MapFrangi.GUI.ColormapDropDown.Value = CS.MapFrangi.ColormapDropDown;           
    PPA.MapFrangi.GUI.StartEditField.Value = CS.MapFrangi.StartEditField;             
    PPA.MapFrangi.GUI.StopEditField.Value = CS.MapFrangi.StopEditField;              
    PPA.MapFrangi.GUI.nScalesEditField.Value = CS.MapFrangi.nScalesEditField;           
    PPA.MapFrangi.GUI.ScalesDropDown.Value = CS.MapFrangi.ScalesDropDown;             
    PPA.MapFrangi.GUI.UnitsDropDown.Value = CS.MapFrangi.UnitsDropDown;              
    PPA.MapFrangi.GUI.ScalesTextField.Value = CS.MapFrangi.ScalesTextField;            
    PPA.MapFrangi.GUI.InvertedCheckBox.Value = CS.MapFrangi.InvertedCheckBox;           
    PPA.MapFrangi.GUI.SensitivityEditField.Value = CS.MapFrangi.SensitivityEditField;       
    PPA.MapFrangi.GUI.CLAHEScalesCheckBox.Value = CS.MapFrangi.CLAHEScalesCheckBox;        
    PPA.MapFrangi.GUI.ContrastScalesCheckBox.Value = CS.MapFrangi.ContrastScalesCheckBox;     
    PPA.MapFrangi.GUI.CLAHEFiltCheckBox.Value = CS.MapFrangi.CLAHEFiltCheckBox;          
    PPA.MapFrangi.GUI.ContrastFiltCheckBox.Value = CS.MapFrangi.ContrastFiltCheckBox;       
    PPA.MapFrangi.GUI.FusingTechDropDown.Value = CS.MapFrangi.FusingTechDropDown;         
    PPA.MapFrangi.GUI.LinCombDropDown.Value = CS.MapFrangi.LinCombDropDown;            
    PPA.MapFrangi.GUI.RawEditField.Value = CS.MapFrangi.RawEditField;               
    PPA.MapFrangi.GUI.FrangiEditField.Value = CS.MapFrangi.FrangiEditField;            
    PPA.MapFrangi.GUI.cutoffEditField.Value = CS.MapFrangi.cutoffEditField;            
    PPA.MapFrangi.GUI.spreadEditField.Value = CS.MapFrangi.spreadEditField;            
    PPA.MapFrangi.GUI.nbhEditField.Value = CS.MapFrangi.nbhEditField;               
    PPA.MapFrangi.GUI.smoothEditField.Value = CS.MapFrangi.smoothEditField;            
    PPA.MapFrangi.GUI.ThresholdEditField.Value = CS.MapFrangi.ThresholdEditField;         
    PPA.MapFrangi.GUI.SmoothEditField.Value = CS.MapFrangi.SmoothEditField;            
    PPA.MapFrangi.GUI.PostCLAHECheckBox.Value = CS.MapFrangi.PostCLAHECheckBox;          
    PPA.MapFrangi.GUI.PostClaheClipLim.Value = CS.MapFrangi.PostClaheClipLim;           
    PPA.MapFrangi.GUI.PostContrastCheckBox.Value = CS.MapFrangi.PostContrastCheckBox;       
    PPA.MapFrangi.GUI.ContrastGamma.Value = CS.MapFrangi.ContrastGamma;              
  end

  if CS.doVessel
    if isempty(PPA.VesselGUI)
      VesselGui(PPA);
    elseif isa(PPA.VesselGUI,'VesselGui') && ishandle(PPA.VesselGUI.UIFigure)
      PPA.VesselGUI.UIFigure.Visible = 'on';
    end
    PPA.VesselGUI.BinarizationMethodDropDown.Value = CS.Vessel.BinarizationMethodDropDown;  
    PPA.VesselGUI.BinSensEdit.Value = CS.Vessel.BinSensEdit;                 
    PPA.VesselGUI.BinMultiLevels.Value = CS.Vessel.BinMultiLevels;              
    PPA.VesselGUI.FrangiFiltInput.Value = CS.Vessel.FrangiFiltInput;             
    PPA.VesselGUI.nColors.Value = CS.Vessel.nColors;                     
    PPA.VesselGUI.plotSize.Value = CS.Vessel.plotSize;                    
    PPA.VesselGUI.DataColorMap.Value = CS.Vessel.DataColorMap;                
    PPA.VesselGUI.scatterAlpha.Value = CS.Vessel.scatterAlpha;                
    PPA.VesselGUI.scaleSize.Value = CS.Vessel.scaleSize;                   
    PPA.VesselGUI.removeOutliers.Value = CS.Vessel.removeOutliers;              
    PPA.VesselGUI.maxStd.Value = CS.Vessel.maxStd;                      
    PPA.VesselGUI.WhatDataOverlay.Value = CS.Vessel.WhatDataOverlay;             
    PPA.VesselGUI.AutoUpdateCheckBox.Value = CS.Vessel.AutoUpdateCheckBox;          
    PPA.VesselGUI.MinSplineLength.Value = CS.Vessel.MinSplineLength;             
    PPA.VesselGUI.SplineSmooth.Value = CS.Vessel.SplineSmooth;                
    PPA.VesselGUI.SmoothPer.Value = CS.Vessel.SmoothPer;                   
    PPA.VesselGUI.SmoothPar.Value = CS.Vessel.SmoothPar;                   
    PPA.VesselGUI.ForceConnect.Value = CS.Vessel.ForceConnect;                
    PPA.VesselGUI.RemoveExtreme.Value = CS.Vessel.RemoveExtreme;               
    PPA.VesselGUI.FitToFrangi.Value = CS.Vessel.FitToFrangi;                 
    PPA.VesselGUI.MinHoleSizeEdit.Value = CS.Vessel.MinHoleSizeEdit;             
    PPA.VesselGUI.MinObjSizeEdit.Value = CS.Vessel.MinObjSizeEdit;              
    PPA.VesselGUI.MinSpurLength.Value = CS.Vessel.MinSpurLength;               
    PPA.VesselGUI.ClearNearBranchCheckBox.Value = CS.Vessel.ClearNearBranchCheckBox;     
  end

  
  if CS.doVesselFrangi
    if isempty(PPA.VesselFrangi)
      PPA.Init_Frangi('vessel');
    elseif isa(PPA.VesselFrangi,'Frangi_Filter') && ishandle(PPA.VesselFrangi.GUI.UIFigure)
      PPA.VesselFrangi.GUI.Visible = 'on';
    end
    PPA.VesselFrangi.GUI.AutoUpdateCheckBox.Value = CS.VesselFrangi.AutoUpdateCheckBox;         
    PPA.VesselFrangi.GUI.ColormapDropDown.Value = CS.VesselFrangi.ColormapDropDown;           
    PPA.VesselFrangi.GUI.StartEditField.Value = CS.VesselFrangi.StartEditField;             
    PPA.VesselFrangi.GUI.StopEditField.Value = CS.VesselFrangi.StopEditField;              
    PPA.VesselFrangi.GUI.nScalesEditField.Value = CS.VesselFrangi.nScalesEditField;           
    PPA.VesselFrangi.GUI.ScalesDropDown.Value = CS.VesselFrangi.ScalesDropDown;             
    PPA.VesselFrangi.GUI.UnitsDropDown.Value = CS.VesselFrangi.UnitsDropDown;              
    PPA.VesselFrangi.GUI.ScalesTextField.Value = CS.VesselFrangi.ScalesTextField;            
    PPA.VesselFrangi.GUI.InvertedCheckBox.Value = CS.VesselFrangi.InvertedCheckBox;           
    PPA.VesselFrangi.GUI.SensitivityEditField.Value = CS.VesselFrangi.SensitivityEditField;       
    PPA.VesselFrangi.GUI.CLAHEScalesCheckBox.Value = CS.VesselFrangi.CLAHEScalesCheckBox;        
    PPA.VesselFrangi.GUI.ContrastScalesCheckBox.Value = CS.VesselFrangi.ContrastScalesCheckBox;     
    PPA.VesselFrangi.GUI.CLAHEFiltCheckBox.Value = CS.VesselFrangi.CLAHEFiltCheckBox;          
    PPA.VesselFrangi.GUI.ContrastFiltCheckBox.Value = CS.VesselFrangi.ContrastFiltCheckBox;       
    PPA.VesselFrangi.GUI.FusingTechDropDown.Value = CS.VesselFrangi.FusingTechDropDown;         
    PPA.VesselFrangi.GUI.LinCombDropDown.Value = CS.VesselFrangi.LinCombDropDown;            
    PPA.VesselFrangi.GUI.RawEditField.Value = CS.VesselFrangi.RawEditField;               
    PPA.VesselFrangi.GUI.FrangiEditField.Value = CS.VesselFrangi.FrangiEditField;            
    PPA.VesselFrangi.GUI.cutoffEditField.Value = CS.VesselFrangi.cutoffEditField;            
    PPA.VesselFrangi.GUI.spreadEditField.Value = CS.VesselFrangi.spreadEditField;            
    PPA.VesselFrangi.GUI.nbhEditField.Value = CS.VesselFrangi.nbhEditField;               
    PPA.VesselFrangi.GUI.smoothEditField.Value = CS.VesselFrangi.smoothEditField;            
    PPA.VesselFrangi.GUI.ThresholdEditField.Value = CS.VesselFrangi.ThresholdEditField;         
    PPA.VesselFrangi.GUI.SmoothEditField.Value = CS.VesselFrangi.SmoothEditField;            
    PPA.VesselFrangi.GUI.PostCLAHECheckBox.Value = CS.VesselFrangi.PostCLAHECheckBox;          
    PPA.VesselFrangi.GUI.PostClaheClipLim.Value = CS.VesselFrangi.PostClaheClipLim;           
    PPA.VesselFrangi.GUI.PostContrastCheckBox.Value = CS.VesselFrangi.PostContrastCheckBox;       
    PPA.VesselFrangi.GUI.ContrastGamma.Value = CS.VesselFrangi.ContrastGamma;              
  end

end
   