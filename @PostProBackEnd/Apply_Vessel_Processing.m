function Apply_Vessel_Processing(PPA)
  % follows closely what is happening in AVA.Get_Data(); 
  % but this way we can plot in between...
  
  try
    if isempty(PPA.procProj)
      % we don't have any volume data...this should not happen, but lets be safe
      return;
    end
    
    % vessel GUI is switched "off"
    if strcmp(PPA.VesselGUI.UIFigure.Visible,'off')
      return;
    end

    % figure was closed, but vessel GUI is still open, so 
    % just open a new figure
    if isempty(PPA.VesselFigs) || ~ishandle(PPA.VesselFigs.MainFig)
      PPA.Setup_Vessel_Figures();
    end
    figure(PPA.VesselFigs.MainFig);

    % now that we have a figure and all the data we need, we do the actual 
    % processing 
    PPA.Apply_Vessel_Pre_Processing();
    PPA.Find_Vessels();


  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end


end



