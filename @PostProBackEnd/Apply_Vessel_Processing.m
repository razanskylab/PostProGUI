function Apply_Vessel_Processing(PPA)
  % follows closely what is happening in AVA.Get_Data(); 
  % but this way we can plot in between...
  
  try
    if isempty(PPA.procProj)
      % we don't have any data...this should not happen, but lets be safe
      return;
    end

    if isempty(PPA.VesselFigs) ||~ishandle(PPA.VesselFigs.MainFig)
      PPA.Setup_Vessel_Figures();
    end
    
    doPreFrangi = PPA.VesselGUI.FrangiFiltInput.Value;
    fitToFrangi = PPA.VesselGUI.FitToFrangi.Value;
    % apply frangi filtering already, we need it...
    if doPreFrangi
      PPA.FraFilt.Open_GUI();
      PPA.FraFilt.Apply_Frangi();
    end

    % apply frangi filter for binarization and/or fitting?
    if ~doPreFrangi 
      binInput = single(PPA.procProj);
      fitInput = single(PPA.procProj);
    else
      % ok, we do pre frangi, now decide what to use it for
      if ~fitToFrangi
        binInput = single(PPA.FraFilt.fusedFrangi);
        fitInput = single(PPA.procProj);
      else
        binInput = single(PPA.FraFilt.fusedFrangi);
        fitInput = single(PPA.FraFilt.fusedFrangi);
      end 
    end
    % initialize AVA & Vessel Data object for AVA usage
    PPA.AVA = Vessel_Analysis();
    PPA.AVA.Data = Vessel_Data(PPA.AVA.VesselSettings);
    PPA.AVA.Data.delete_vessels;
    PPA.AVA.Data.im = fitInput;
    PPA.AVA.Data.im_orig = fitInput;
    % we always assume white vessels on dark background
    PPA.AVA.Data.dark_vessels = false;

    % update background of input and final spline fit
    set(PPA.VesselFigs.InIm, 'cData', fitInput); % update input image
    set(PPA.VesselFigs.SplineImBack, 'cData', fitInput);
    set(PPA.VesselFigs.SkeletonImBack, 'cData', fitInput);

    PPA.Apply_Vessel_Pre_Processing(binInput);
    PPA.Find_Vessels(); % takes a moment...

    % bring the figures we use to the front
    figure(PPA.VesselFigs.MainFig);
    figure(PPA.VesselGUI.UIFigure);

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end


end


