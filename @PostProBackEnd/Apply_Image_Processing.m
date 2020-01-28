function Apply_Image_Processing(PPA)

  try
    if isempty(PPA.procVolProj)
      return;
    end

    PPA.Start_Wait_Bar(PPA.MapGUI,'Processing 2D image data...');

    % get variables etc from from GUI
    PPA.IMF = Image_Filter(PPA.procVolProj);
    % PPA.procVolProj is the processed, volumetric projection
    depthIm = PPA.rawDepthInfo; % this is the untouched, i.e. not interp. version

    % processing based on image Filter class, so initialize that here
    % settings will be stored there until overwritten by next Apply_Image_Processing

    % spot removal - affects image and depth map
    if PPA.doImSpotRemoval
      PPA.Start_Wait_Bar(PPA.MapGUI,'Removing image spots...');
      PPA.Update_Status(sprintf('   levels: %2.0f', PPA.imSpotLevel));
      PPA.IMF.spotLevels = PPA.imSpotLevel;
      [~, depthIm] = PPA.IMF.Remove_Spots(depthIm); % also updates PPA.IMF.filt internaly
    end

    % interpolate - also affects image and depth map
    if PPA.doImInterpolate
      PPA.Start_Wait_Bar(PPA.MapGUI,'Interpolating image data...');
      PPA.Update_Status(sprintf('   factor: %2.0f', PPA.imInterpFct));
      PPA.IMF.Interpolate(PPA.imInterpFct);
      % also interpolate depth data, so they match for later overlay...
      IM_Depth = Image_Filter(depthIm);
      IM_Depth.Interpolate(PPA.imInterpFct);
      depthIm = IM_Depth.filt;
      clear('IM_Depth');
    end

    % clahe - affects mip image only
    if PPA.MapGUI.ContrastCheck.Value
      PPA.Start_Wait_Bar(PPA.MapGUI,'CLAHE filtering image data...');
      PPA.Update_Status(sprintf('   distribution: %s | bins: %s | limit: %2.3f | tiles: %s', ...
        PPA.MapGUI.ClaheDistr.Value, PPA.MapGUI.ClaheBins.Value, PPA.MapGUI.ClaheClipLim.Value, PPA.MapGUI.ClaheTiles.Value));
      % setup clahe filter with latest values
      PPA.IMF.claheDistr = PPA.MapGUI.ClaheDistr.Value;
      PPA.IMF.claheNBins = str2double(PPA.MapGUI.ClaheBins.Value);
      PPA.IMF.claheLim = PPA.MapGUI.ClaheClipLim.Value;
      nTiles = str2double(PPA.MapGUI.ClaheTiles.Value);
      PPA.IMF.claheNTiles = [nTiles nTiles];
      % apply clahe to procVolProj
      PPA.IMF.Apply_CLAHE();
    end

    % wiener filter - affects mip image only
    if PPA.MapGUI.WienerCheckBox.Value
      PPA.Start_Wait_Bar(PPA.MapGUI,'Wiener filtering image data...');
      PPA.Update_Status(sprintf('   neighborhood size: %2.0f', PPA.MapGUI.WienerSize.Value));
      PPA.IMF.nWienerPixel = PPA.MapGUI.WienerSize.Value;
      PPA.IMF.Apply_Wiener();
    end

    % image guided filtering
    if PPA.MapGUI.ImageGuidedCheckBox.Value% affects mip image only
      PPA.Start_Wait_Bar(PPA.MapGUI,'Image guided filtering...');
      PPA.IMF.imGuideNhoodSize = PPA.MapGUI.ImGuideSizeEditField.Value;
      PPA.IMF.imGuideSmoothValue = PPA.MapGUI.ImGuideSmoothSlider.Value.^2;
      PPA.Update_Status(sprintf('   neighborhood size: %2.0f | smoothness: %2.5f', ...
        PPA.IMF.imGuideNhoodSize, PPA.IMF.imGuideSmoothValue));
      PPA.IMF.Guided_Filtering();
    end

    if PPA.MapGUI.AdjustContrastCheckBox.Value% affects mip image only
      PPA.Start_Wait_Bar(PPA.MapGUI,'Adjusting contrast...');
      % auto calculate stretch limits?
      PPA.IMF.imadLimOut = [0 1];
      PPA.IMF.imadAuto = PPA.MapGUI.AutoContrCheckBox.Value;
      PPA.IMF.imadLimIn = [PPA.MapGUI.ContrastLowLimEdit.Value PPA.MapGUI.ContrastUpLimEdit.Value];
      PPA.IMF.imadGamme = PPA.MapGUI.ContrastGammaEdit.Value;
      PPA.Update_Status(sprintf('   auto: %i gamma: %3.2f', PPA.IMF.imadAuto, PPA.IMF.imadGamme));
      PPA.IMF.Adjust_Contrast();
    end

    PPA.preFrangi = PPA.IMF.filt; % update pre-frangi
    % NOTE we need this, so we don't keep re-applying frangi filtering on
    % already frangi-filtered images
    if PPA.MapGUI.UseFrangiCheckBox.Value
      PPA.Start_Wait_Bar(PPA.MapGUI,'Vesselness filtering...');
      PPA.Update_Frangi_Scales();
      PPA.Apply_Frangi(PPA.IMF.filt); % creates frangi scales, does plotting, updates frangiCombo
      PPA.IMF.filt = PPA.frangiCombo;
    end

    PPA.depthInfo = depthIm; % needs to updated before procProj
    PPA.procProj = PPA.IMF.filt;

  catch me
    PPA.Stop_Wait_Bar();
    rethrow(me);
  end

end
