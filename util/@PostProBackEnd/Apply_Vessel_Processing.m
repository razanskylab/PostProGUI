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
    plotBackground = normalize(fitInput);
    plotBackground = gray2ind(plotBackground, 256);
    plotBackground = ind2rgb(plotBackground, PPA.VesselFigs.cbar);

    set(PPA.VesselFigs.InIm, 'cData', fitInput); % update input image
    PPA.VesselFigs.InPlot.Colormap = PPA.VesselFigs.cbar; % return to default colormap
    set(PPA.VesselFigs.SkeletonImBack, 'cData', fitInput);
    set(PPA.VesselFigs.SplineImBack, 'cData', plotBackground);
    set(PPA.VesselFigs.DataImBack, 'cData', plotBackground);
    PPA.VesselFigs.plotBackground = plotBackground; 
      % used in Update_Vessel_Results_Plot

    % this is where we do the actual work... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PPA.Apply_Vessel_Pre_Processing(binInput);
    PPA.Find_Vessels(); % takes a moment...
    % restore the original colormaps -------------------------------------------
    PPA.VesselFigs.MainFig.Colormap = PPA.VesselFigs.cbar;
    PPA.VesselFigs.ResultsFig.Colormap = PPA.VesselFigs.cbar;
    
    % plot final image with fitted splines, widths and branch points
    PPA.Update_Vessel_Results_Plot();

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
  VesselFigs.SkeletonImFront.AlphaData = 1;
  VesselFigs.SkeletonImFront.CData = NaN;
  VesselFigs.SkeletonScat.XData = 0;
  VesselFigs.SkeletonScat.YData = 0;
  VesselFigs.SplineScat.XData = 0;
  VesselFigs.SplineScat.YData = 0;
  VesselFigs.SplineLine.XData = 0;
  VesselFigs.SplineLine.YData = 0;
  VesselFigs.LEdgeLines.XData = 0;
  VesselFigs.LEdgeLines.YData = 0;
  VesselFigs.REdgeLines.XData = 0;
  VesselFigs.REdgeLines.YData = 0;

  % remove all old scatter / line plots in result figure
  while (numel(VesselFigs.DataDisp.Children) > 1)
    delete(VesselFigs.DataDisp.Children(1));
  end
end


function [fitInput, binInput] = init_vessel_processing(PPA)
  % figure out what image to use as input, either the raw or the frangi 
  % filtered one, then also check if we find the vessel characteristics
  % in the normal or the frangi filtered images

  doPreFrangi = PPA.VesselGUI.FrangiFiltInput.Value;
  fitToFrangi = PPA.VesselGUI.FitToFrangi.Value;
  % apply frangi filtering already, we need it...
  if doPreFrangi
    PPA.Init_Frangi('vessel');
    PPA.VesselFrangi.Open_GUI();
    PPA.VesselFrangi.Apply_Frangi();
  end

  % apply frangi filter for binarization and/or fitting?
  if ~doPreFrangi
    binInput = single(PPA.procProj);
    fitInput = single(PPA.procProj);
  else
    % ok, we do pre frangi, now decide what to use it for
    if ~fitToFrangi
      binInput = single(PPA.VesselFrangi.fusedFrangi);
      fitInput = single(PPA.procProj);
    else
      binInput = single(PPA.VesselFrangi.fusedFrangi);
      fitInput = single(PPA.VesselFrangi.fusedFrangi);
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