function Apply_Vessel_Pre_Processing(PPA)
  try
  
    if ~ishandle(PPA.VesselFigs.MainFig)
      PPA.Setup_Vessel_Figures();
    end
    figure(PPA.VesselFigs.MainFig);
    
    if isempty(PPA.procProj)
      % we don't have any volume data...this should not happen, but lets be safe
      return;
    end

    PPA.Start_Wait_Bar(PPA.VesselGUI, 'Pre-processing vessel data...');
    PPA.IMF = Image_Filter(normalize(PPA.procProj));
    set(PPA.VesselFigs.InIm, 'cData', PPA.IMF.filt);

    switch PPA.VesselGUI.BinMethodDropDown.Value
    case 'Adaptive'
      PPA.IMF.binMethod = 'adapt';
      PPA.IMF.threshSens = PPA.VesselGUI.BinSensEdit.Value;
    case 'Otsu'
      PPA.IMF.binMethod = 'gray';
    case 'Multi'
      PPA.IMF.binMethod = 'multi';
      PPA.IMF.nThreshLevels = PPA.VesselGUI.BinMultiLevels.Value;
    end

    binIm = PPA.IMF.Binarize();
    set(PPA.VesselFigs.BinIm, 'cData', binIm)

    binCleanIm = PPA.VesselFigs.BinCleanIm;

    PPA.ProgBar = [];

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end


end



