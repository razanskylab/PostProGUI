function Apply_Image_Processing(PPA)

  try

    if isempty(PPA.procVolProj)
      % we don't have any volume data...this should not happen, but lets be safe
      return;
    end

    if isempty(PPA.MapFig) ||~ishandle(PPA.MapFig.MainFig)
      PPA.Setup_Map_Figure();
    end

    PPA.Handle_Map_Controls();
    PPA.Start_Wait_Bar(PPA.MapGUI, 'Processing 2D image data...');

    % get variables etc from from GUI
    PPA.IMF = Image_Filter(PPA.procVolProj);
    % PPA.procVolProj is the processed, volumetric projection
    depthIm = PPA.rawDepthInfo; % this is the untouched, i.e. not interp. version
    hasDepthInfo = ~isempty(depthIm);
    % processing based on image Filter class, so initialize that here
    % settings will be stored there until overwritten by next Apply_Image_Processing

    % spot removal - affects image and depth map
    if PPA.MapGUI.SpotRemovalCheckBox.Value
      PPA.Update_Status('Removing image spots...');
      PPA.Update_Status(sprintf('   levels: %2.0f', PPA.MapGUI.imSpotRem.Value));
      PPA.IMF.spotLevels = PPA.MapGUI.imSpotRem.Value;
      if hasDepthInfo
        [~, depthIm] = PPA.IMF.Remove_Spots(depthIm); % also updates PPA.IMF.filt internaly
      end
    end

    % interpolate - also affects image and depth map
    if PPA.MapGUI.InterpolateCheckBox.Value
      PPA.Update_Status('Interpolating image data...');
      PPA.Update_Status(sprintf('   factor: %2.0f', PPA.MapGUI.imInterpFactor.Value));
      PPA.IMF.Interpolate(PPA.MapGUI.imInterpFactor.Value);
      if hasDepthInfo
        % also interpolate depth data, so they match for later overlay...
        IM_Depth = Image_Filter(depthIm);
        IM_Depth.Interpolate(PPA.MapGUI.imInterpFactor.Value);
        depthIm = IM_Depth.filt;
        clear('IM_Depth');
      end
    end

    % fspecial filter
    if PPA.MapGUI.SpecialFilterCheckBox.Value
      PPA.Update_Status('Filtering image data...');
      PPA.IMF.fsStrength = PPA.MapGUI.FiltStrength.Value;
      PPA.IMF.fsSize = PPA.MapGUI.FiltSize.Value;
      PPA.IMF.Apply_Image_Filter(PPA.MapGUI.FilterDropDown.Value);
    end

    % clahe - affects mip image only
    if PPA.MapGUI.ContrastCheck.Value
      PPA.Update_Status('CLAHE filtering image data...');
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
    
    if PPA.MapGUI.AdjustContrastCheckBox.Value% affects mip image only
      PPA.Update_Status('Adjusting contrast...');
      % auto calculate stretch limits?
      PPA.IMF.imadLimOut = [0 1];
      PPA.IMF.imadAuto = PPA.MapGUI.AutoContrCheckBox.Value;
      PPA.IMF.imadLimIn = [PPA.MapGUI.ContrastLowLimEdit.Value PPA.MapGUI.ContrastUpLimEdit.Value];
      PPA.IMF.imadGamme = PPA.MapGUI.ContrastGammaEdit.Value;
      PPA.Update_Status(sprintf('   auto: %i gamma: %3.2f', PPA.IMF.imadAuto, PPA.IMF.imadGamme));
      PPA.IMF.Adjust_Contrast();
    end

    % wiener filter - affects mip image only
    if PPA.MapGUI.WienerCheckBox.Value
      PPA.Update_Status('Wiener filtering image data...');
      PPA.Update_Status(sprintf('   neighborhood size: %2.0f', PPA.MapGUI.WienerSize.Value));
      PPA.IMF.nWienerPixel = PPA.MapGUI.WienerSize.Value;
      PPA.IMF.Apply_Wiener();
    end

    % image guided filtering
    if PPA.MapGUI.ImageGuidedCheckBox.Value% affects mip image only
      PPA.Update_Status('Image guided filtering...');
      PPA.IMF.imGuideNhoodSize = PPA.MapGUI.ImGuideSizeEditField.Value;
      PPA.IMF.imGuideSmoothValue = PPA.MapGUI.ImGuideSmoothSlider.Value.^2;
      PPA.Update_Status(sprintf('   neighborhood size: %2.0f | smoothness: %2.5f', ...
        PPA.IMF.imGuideNhoodSize, PPA.IMF.imGuideSmoothValue));
      PPA.IMF.Guided_Filtering();
    end

    % PPA.preFrangi = PPA.IMF.filt; % update pre-frangi
    % NOTE we need this, so we don't keep re-applying frangi filtering on
    % already frangi-filtered images
    if PPA.MapGUI.UseFrangiCheckBox.Value
      PPA.Update_Status('Vesselness filtering...');
      % update frangi variables
      PPA.MapFrangi.raw = PPA.IMF.filt;
      PPA.MapFrangi.x = PPA.xPlotIm;
      PPA.MapFrangi.y = PPA.yPlotIm;
      PPA.MapFrangi.Apply_Frangi(); % update frangi plot...
      PPA.IMF.filt = PPA.MapFrangi.fusedFrangi;
    end

    PPA.depthInfo = depthIm; % needs to updated before procProj
    PPA.procProj = PPA.IMF.filt;
    PPA.Update_Status('Updating map projections...')

    if ~isempty(PPA.MapGUI)
      PPA.Update_Map_Projections(PPA.IMF.filt);
    end

    PPA.Handle_Master_Gui_State('map_processing_complete');
    drawnow();
    PPA.ProgBar = [];

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end

end
