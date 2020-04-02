function [CS] = Get_Current_Settings(PPA)
  % returns all current settings as stored in the GUI
  % I don't know a better way of doing this right now...
  
  CS.doVol =  ~isempty(PPA.VolGUI);
  CS.doMap =  ~isempty(PPA.MapGUI);
  CS.doMapFrangi =  ~isempty(PPA.MapFrangi);

  CS.doVessel =  ~isempty(PPA.VesselGUI);
  CS.doVesselFrangi =  ~isempty(PPA.VesselFrangi);

  CS.doExport =  ~isempty(PPA.ExportGUI);

  if CS.doMap
    CS.Map.ContrastCheck = PPA.MapGUI.ContrastCheck.Value;           
    CS.Map.imSpotRem = PPA.MapGUI.imSpotRem.Value;               
    CS.Map.SpotRemovalCheckBox = PPA.MapGUI.SpotRemovalCheckBox.Value;     
    CS.Map.imInterpFactor = PPA.MapGUI.imInterpFactor.Value;          
    CS.Map.InterpolateCheckBox = PPA.MapGUI.InterpolateCheckBox.Value;     
    CS.Map.WienerCheckBox = PPA.MapGUI.WienerCheckBox.Value;          
    CS.Map.WienerSize = PPA.MapGUI.WienerSize.Value;              
    CS.Map.ImageGuidedCheckBox = PPA.MapGUI.ImageGuidedCheckBox.Value;     
    CS.Map.AdjustContrastCheckBox = PPA.MapGUI.AdjustContrastCheckBox.Value;  
    CS.Map.UseFrangiCheckBox = PPA.MapGUI.UseFrangiCheckBox.Value;       
    CS.Map.SpecialFilterCheckBox = PPA.MapGUI.SpecialFilterCheckBox.Value;   
    CS.Map.ClaheBins = PPA.MapGUI.ClaheBins.Value;               
    CS.Map.ClaheTiles = PPA.MapGUI.ClaheTiles.Value;              
    CS.Map.ClaheClipLim = PPA.MapGUI.ClaheClipLim.Value;            
    CS.Map.ClaheDistr = PPA.MapGUI.ClaheDistr.Value;              
    CS.Map.ImGuideSizeEditField = PPA.MapGUI.ImGuideSizeEditField.Value;    
    CS.Map.ImGuideSmoothSlider = PPA.MapGUI.ImGuideSmoothSlider.Value;     
    CS.Map.OffsetmmEditField = PPA.MapGUI.OffsetmmEditField.Value;       
    CS.Map.RemoveTrendCheckBox = PPA.MapGUI.RemoveTrendCheckBox.Value;     
    CS.Map.TranspEditField = PPA.MapGUI.TranspEditField.Value;         
    CS.Map.MinAmpEditField = PPA.MapGUI.MinAmpEditField.Value;         
    CS.Map.SmoothEditField = PPA.MapGUI.SmoothEditField.Value;         
    CS.Map.depthColor = PPA.MapGUI.depthColor.Value;              
    CS.Map.topcutEditField = PPA.MapGUI.topcutEditField.Value;         
    CS.Map.depthcutEditField = PPA.MapGUI.depthcutEditField.Value;       
    CS.Map.depthoffsetSlider = PPA.MapGUI.depthoffsetSlider.Value;       
    CS.Map.surfaceoffsetSlider = PPA.MapGUI.surfaceoffsetSlider.Value;     
    CS.Map.CropDepthDropDown = PPA.MapGUI.CropDepthDropDown.Value;       
    CS.Map.shiftEditField = PPA.MapGUI.shiftEditField.Value;          
    CS.Map.FiltStrength = PPA.MapGUI.FiltStrength.Value;            
    CS.Map.FilterDropDown = PPA.MapGUI.FilterDropDown.Value;          
    CS.Map.FiltSize = PPA.MapGUI.FiltSize.Value;                
    CS.Map.ContrastLowLimEdit = PPA.MapGUI.ContrastLowLimEdit.Value;      
    CS.Map.ContrastUpLimEdit = PPA.MapGUI.ContrastUpLimEdit.Value;       
    CS.Map.ContrastGammaEdit = PPA.MapGUI.ContrastGammaEdit.Value;       
    CS.Map.AutoContrCheckBox = PPA.MapGUI.AutoContrCheckBox.Value;    
  end

  if CS.doMapFrangi
    CS.MapFrangi.AutoUpdateCheckBox = PPA.MapFrangi.GUI.AutoUpdateCheckBox.Value;         
    CS.MapFrangi.ColormapDropDown = PPA.MapFrangi.GUI.ColormapDropDown.Value;           
    CS.MapFrangi.StartEditField = PPA.MapFrangi.GUI.StartEditField.Value;             
    CS.MapFrangi.StopEditField = PPA.MapFrangi.GUI.StopEditField.Value;              
    CS.MapFrangi.nScalesEditField = PPA.MapFrangi.GUI.nScalesEditField.Value;           
    CS.MapFrangi.ScalesDropDown = PPA.MapFrangi.GUI.ScalesDropDown.Value;             
    CS.MapFrangi.UnitsDropDown = PPA.MapFrangi.GUI.UnitsDropDown.Value;              
    CS.MapFrangi.ScalesTextField = PPA.MapFrangi.GUI.ScalesTextField.Value;            
    CS.MapFrangi.InvertedCheckBox = PPA.MapFrangi.GUI.InvertedCheckBox.Value;           
    CS.MapFrangi.SensitivityEditField = PPA.MapFrangi.GUI.SensitivityEditField.Value;       
    CS.MapFrangi.CLAHEScalesCheckBox = PPA.MapFrangi.GUI.CLAHEScalesCheckBox.Value;        
    CS.MapFrangi.ContrastScalesCheckBox = PPA.MapFrangi.GUI.ContrastScalesCheckBox.Value;     
    CS.MapFrangi.CLAHEFiltCheckBox = PPA.MapFrangi.GUI.CLAHEFiltCheckBox.Value;          
    CS.MapFrangi.ContrastFiltCheckBox = PPA.MapFrangi.GUI.ContrastFiltCheckBox.Value;       
    CS.MapFrangi.FusingTechDropDown = PPA.MapFrangi.GUI.FusingTechDropDown.Value;         
    CS.MapFrangi.LinCombDropDown = PPA.MapFrangi.GUI.LinCombDropDown.Value;            
    CS.MapFrangi.RawEditField = PPA.MapFrangi.GUI.RawEditField.Value;               
    CS.MapFrangi.FrangiEditField = PPA.MapFrangi.GUI.FrangiEditField.Value;            
    CS.MapFrangi.cutoffEditField = PPA.MapFrangi.GUI.cutoffEditField.Value;            
    CS.MapFrangi.spreadEditField = PPA.MapFrangi.GUI.spreadEditField.Value;            
    CS.MapFrangi.nbhEditField = PPA.MapFrangi.GUI.nbhEditField.Value;               
    CS.MapFrangi.smoothEditField = PPA.MapFrangi.GUI.smoothEditField.Value;            
    CS.MapFrangi.ThresholdEditField = PPA.MapFrangi.GUI.ThresholdEditField.Value;         
    CS.MapFrangi.SmoothEditField = PPA.MapFrangi.GUI.SmoothEditField.Value;            
    CS.MapFrangi.PostCLAHECheckBox = PPA.MapFrangi.GUI.PostCLAHECheckBox.Value;          
    CS.MapFrangi.PostClaheClipLim = PPA.MapFrangi.GUI.PostClaheClipLim.Value;           
    CS.MapFrangi.PostContrastCheckBox = PPA.MapFrangi.GUI.PostContrastCheckBox.Value;       
    CS.MapFrangi.ContrastGamma = PPA.MapFrangi.GUI.ContrastGamma.Value;              
  end

  if CS.doVessel
    CS.Vessel.BinarizationMethodDropDown = PPA.VesselGUI.BinarizationMethodDropDown.Value;  
    CS.Vessel.BinSensEdit = PPA.VesselGUI.BinSensEdit.Value;                 
    CS.Vessel.BinMultiLevels = PPA.VesselGUI.BinMultiLevels.Value;              
    CS.Vessel.FrangiFiltInput = PPA.VesselGUI.FrangiFiltInput.Value;             
    CS.Vessel.nColors = PPA.VesselGUI.nColors.Value;                     
    CS.Vessel.plotSize = PPA.VesselGUI.plotSize.Value;                    
    CS.Vessel.DataColorMap = PPA.VesselGUI.DataColorMap.Value;                
    CS.Vessel.scatterAlpha = PPA.VesselGUI.scatterAlpha.Value;                
    CS.Vessel.scaleSize = PPA.VesselGUI.scaleSize.Value;                   
    CS.Vessel.removeOutliers = PPA.VesselGUI.removeOutliers.Value;              
    CS.Vessel.maxStd = PPA.VesselGUI.maxStd.Value;                      
    CS.Vessel.WhatDataOverlay = PPA.VesselGUI.WhatDataOverlay.Value;             
    CS.Vessel.AutoUpdateCheckBox = PPA.VesselGUI.AutoUpdateCheckBox.Value;          
    CS.Vessel.MinSplineLength = PPA.VesselGUI.MinSplineLength.Value;             
    CS.Vessel.SplineSmooth = PPA.VesselGUI.SplineSmooth.Value;                
    CS.Vessel.SmoothPer = PPA.VesselGUI.SmoothPer.Value;                   
    CS.Vessel.SmoothPar = PPA.VesselGUI.SmoothPar.Value;                   
    CS.Vessel.ForceConnect = PPA.VesselGUI.ForceConnect.Value;                
    CS.Vessel.RemoveExtreme = PPA.VesselGUI.RemoveExtreme.Value;               
    CS.Vessel.FitToFrangi = PPA.VesselGUI.FitToFrangi.Value;                 
    CS.Vessel.MinHoleSizeEdit = PPA.VesselGUI.MinHoleSizeEdit.Value;             
    CS.Vessel.MinObjSizeEdit = PPA.VesselGUI.MinObjSizeEdit.Value;              
    CS.Vessel.MinSpurLength = PPA.VesselGUI.MinSpurLength.Value;               
    CS.Vessel.ClearNearBranchCheckBox = PPA.VesselGUI.ClearNearBranchCheckBox.Value;     
  end

  
  if CS.doVesselFrangi
    CS.VesselFrangi.AutoUpdateCheckBox = PPA.VesselFrangi.GUI.AutoUpdateCheckBox.Value;         
    CS.VesselFrangi.ColormapDropDown = PPA.VesselFrangi.GUI.ColormapDropDown.Value;           
    CS.VesselFrangi.StartEditField = PPA.VesselFrangi.GUI.StartEditField.Value;             
    CS.VesselFrangi.StopEditField = PPA.VesselFrangi.GUI.StopEditField.Value;              
    CS.VesselFrangi.nScalesEditField = PPA.VesselFrangi.GUI.nScalesEditField.Value;           
    CS.VesselFrangi.ScalesDropDown = PPA.VesselFrangi.GUI.ScalesDropDown.Value;             
    CS.VesselFrangi.UnitsDropDown = PPA.VesselFrangi.GUI.UnitsDropDown.Value;              
    CS.VesselFrangi.ScalesTextField = PPA.VesselFrangi.GUI.ScalesTextField.Value;            
    CS.VesselFrangi.InvertedCheckBox = PPA.VesselFrangi.GUI.InvertedCheckBox.Value;           
    CS.VesselFrangi.SensitivityEditField = PPA.VesselFrangi.GUI.SensitivityEditField.Value;       
    CS.VesselFrangi.CLAHEScalesCheckBox = PPA.VesselFrangi.GUI.CLAHEScalesCheckBox.Value;        
    CS.VesselFrangi.ContrastScalesCheckBox = PPA.VesselFrangi.GUI.ContrastScalesCheckBox.Value;     
    CS.VesselFrangi.CLAHEFiltCheckBox = PPA.VesselFrangi.GUI.CLAHEFiltCheckBox.Value;          
    CS.VesselFrangi.ContrastFiltCheckBox = PPA.VesselFrangi.GUI.ContrastFiltCheckBox.Value;       
    CS.VesselFrangi.FusingTechDropDown = PPA.VesselFrangi.GUI.FusingTechDropDown.Value;         
    CS.VesselFrangi.LinCombDropDown = PPA.VesselFrangi.GUI.LinCombDropDown.Value;            
    CS.VesselFrangi.RawEditField = PPA.VesselFrangi.GUI.RawEditField.Value;               
    CS.VesselFrangi.FrangiEditField = PPA.VesselFrangi.GUI.FrangiEditField.Value;            
    CS.VesselFrangi.cutoffEditField = PPA.VesselFrangi.GUI.cutoffEditField.Value;            
    CS.VesselFrangi.spreadEditField = PPA.VesselFrangi.GUI.spreadEditField.Value;            
    CS.VesselFrangi.nbhEditField = PPA.VesselFrangi.GUI.nbhEditField.Value;               
    CS.VesselFrangi.smoothEditField = PPA.VesselFrangi.GUI.smoothEditField.Value;            
    CS.VesselFrangi.ThresholdEditField = PPA.VesselFrangi.GUI.ThresholdEditField.Value;         
    CS.VesselFrangi.SmoothEditField = PPA.VesselFrangi.GUI.SmoothEditField.Value;            
    CS.VesselFrangi.PostCLAHECheckBox = PPA.VesselFrangi.GUI.PostCLAHECheckBox.Value;          
    CS.VesselFrangi.PostClaheClipLim = PPA.VesselFrangi.GUI.PostClaheClipLim.Value;           
    CS.VesselFrangi.PostContrastCheckBox = PPA.VesselFrangi.GUI.PostContrastCheckBox.Value;       
    CS.VesselFrangi.ContrastGamma = PPA.VesselFrangi.GUI.ContrastGamma.Value;              
  end

end
   
