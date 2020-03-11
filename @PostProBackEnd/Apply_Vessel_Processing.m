function Apply_Vessel_Processing(PPA)
  % follows closely what is happening in AVA.Get_Data(); 
  % but this way we can plot in between...
  
  try
    if isempty(PPA.procProj)
      return; % we don't have any data...this should not happen, but lets be safe
    end

    PPA.Start_Wait_Bar(PPA.VesselGUI, 'Vessel Analysis');

    if isempty(PPA.VesselFigs) ||~ishandle(PPA.VesselFigs.MainFig)
      PPA.Setup_Vessel_Figures();
    end
    % bring the figures we use to the front
    figure(PPA.VesselFigs.MainFig);
    figure(PPA.VesselFigs.ResultsFig);
    figure(PPA.VesselGUI.UIFigure);

    set_figure_to_processing(PPA.VesselFigs); % local fct below
    [fitInput, binInput] = init_vessel_processing(PPA); % local fct below
 
    % update background of input and final spline fit
    set(PPA.VesselFigs.InIm, 'cData', fitInput); % update input image
    PPA.VesselFigs.InPlot.Colormap = PPA.VesselFigs.cbar; % return to default colormap
    set(PPA.VesselFigs.SplineImBack, 'cData', fitInput);
    set(PPA.VesselFigs.SkeletonImBack, 'cData', fitInput);

    PPA.Apply_Vessel_Pre_Processing(binInput);
    PPA.Find_Vessels(); % takes a moment...

    % restore the original colormaps
    PPA.VesselFigs.MainFig.Colormap = PPA.VesselFigs.cbar;
    PPA.VesselFigs.ResultsFig.Colormap = PPA.VesselFigs.cbar;

    % bring the figures we use to the front
    figure(PPA.VesselFigs.MainFig);
    figure(PPA.VesselFigs.ResultsFig);
    figure(PPA.VesselGUI.UIFigure);

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end

end

function set_figure_to_processing(VesselFigs)
  % set vessel colorbar to low contrast grey to indicate work is happening...
  VesselFigs.MainFig.Colormap = Colors.lowContrast;
  VesselFigs.ResultsFig.Colormap = Colors.lowContrast;
  % delete all old scatter plots
  % VesselFigs.SkeletonImFront.cData = NaN;
  set(VesselFigs.SkeletonImFront, 'cData', NaN);
  VesselFigs.SkeletonScat.XData = NaN;
  VesselFigs.SkeletonScat.YData = NaN;
  VesselFigs.SplineScat.XData = NaN;
  VesselFigs.SplineScat.YData = NaN;
  VesselFigs.SplineLine.XData = NaN;
  VesselFigs.SplineLine.YData = NaN;
  VesselFigs.LEdgeLines.XData = NaN;
  VesselFigs.LEdgeLines.YData = NaN;
  VesselFigs.REdgeLines.XData = NaN;
  VesselFigs.REdgeLines.YData = NaN;
end


function [fitInput, binInput] = init_vessel_processing(PPA)
  % figure out what image to use as input, either the raw or the frangi 
  % filtered one, then also check if we find the vessel characteristics
  % in the normal or the frangi filtered images

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
  PPA.AVA.xy = PPA.procProj;
  % we always assume white vessels on dark background
  PPA.AVA.Data.dark_vessels = false;

end