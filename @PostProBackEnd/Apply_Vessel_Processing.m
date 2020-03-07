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

    % now that we have a figure and all the data we need, we do the actual 
    % processing 
    PPA.Apply_Vessel_Pre_Processing(); % fast stuff
    PPA.Find_Vessels(); % takes a moment...

    figure(PPA.VesselGUI.UIFigure);

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end


end


