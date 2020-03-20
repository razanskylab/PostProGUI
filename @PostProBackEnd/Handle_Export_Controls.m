function Handle_Export_Controls(PPA)

  if PPA.Is_Visible(PPA.ExportGUI)
    hasVol = ~isempty(PPA.procVol);
    hasMap = ~isempty(PPA.procProj);
    hasDeptMap = ~isempty(PPA.depthImage);
    hasVessel = ~isempty(PPA.AVA);
    hasVesselFig = ~isempty(PPA.VesselFigs) && ishandle(PPA.VesselFigs.MainFig);
    useFileName = PPA.ExportGUI.UseFileName.Value; % can't manually change filename
    

    PPA.ExportGUI.ExpVolMat.Enable = hasVol;
    % TODO VTK export function needs to be implemented
    % PPA.ExportGUI.ExpVolVtk.Enable = hasVol;
    PPA.ExportGUI.ExpVolWrk.Enable = hasVol;

    PPA.ExportGUI.ExpImMat.Enable = hasMap;
    PPA.ExportGUI.ExpWrkIm.Enable = hasMap;

    PPA.ExportGUI.ExpImMat.Enable = hasMap;

    PPA.ExportGUI.ExpOverview.Enable = hasMap;
    PPA.ExportGUI.ExpOverJpg.Enable = hasMap && PPA.ExportGUI.ExpOverview.Value;
    PPA.ExportGUI.ExpOverPdf.Enable = hasMap && PPA.ExportGUI.ExpOverview.Value;
    PPA.ExportGUI.ExpOverPng.Enable = hasMap && PPA.ExportGUI.ExpOverview.Value;
    PPA.ExportGUI.ExpOverTiff.Enable = hasMap && PPA.ExportGUI.ExpOverview.Value;

    PPA.ExportGUI.ExpNative.Enable = hasMap;
    PPA.ExportGUI.ExpNativeJpg.Enable = hasMap && PPA.ExportGUI.ExpNative.Value;
    PPA.ExportGUI.ExpNativeTiff.Enable = hasMap && PPA.ExportGUI.ExpNative.Value;
    PPA.ExportGUI.ExpNativePng.Enable = hasMap && PPA.ExportGUI.ExpNative.Value;

    PPA.ExportGUI.ExpDepthMap.Enable = hasDeptMap;

    PPA.ExportGUI.StartBatchProcessButton.Enable = (hasMap || hasVol);
    PPA.ExportGUI.ExportDataButton.Enable = (hasMap || hasVol);
    PPA.ExportGUI.SelectExportPathButton.Enable = (hasMap || hasVol);

    % vessel data related settings
    PPA.ExportGUI.VesselInMap.Enable = (hasMap && hasVessel);
    PPA.ExportGUI.ExpVesselOverview.Enable = hasVessel;
    doOverview = PPA.ExportGUI.ExpVesselOverview.Value;
    PPA.ExportGUI.ExpVesselFig.Enable = (hasVessel && hasVesselFig && doOverview);
    PPA.ExportGUI.ExpVesselJpg.Enable = (hasVessel && hasVesselFig && doOverview);
    PPA.ExportGUI.ExpVesselMat.Enable = hasVessel;

    PPA.ExportGUI.expFileName.Enable = useFileName;
  end

end
