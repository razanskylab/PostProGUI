function Find_Vessels(PPA)
  % follows closely what is happening in AVA.Get_Data(); 
  % but this way we can plot in between...
  % this function only takes care of initializing the AVA data properly
  % and then binarized the latest processed projection
  
  try
    % binarization and cleanup before we find vessels in datasets --------------
    PPA.Start_Wait_Bar(PPA.VesselGUI, 'Finding vessels...');

    PPA.ProgBar = [];

  catch me
    PPA.ProgBar = [];
    rethrow(me);
  end


end



