function Update_Vol_Projections(PPA)
  % Update_Vol_Projections()
  % get unprocessed volume projections and slices
  % those could be clahe filtered depending on GUI stetings
  %
  % see also Apply_Image_Processing_Simple()
  try
    % PPA.Start_Wait_Bar(PPA.LoadGUI, 'test')
    PPA.Start_Wait_Bar(PPA.VolGUI, 'Updating volume projections...')

    % set all new projections
    PPA.procVolProj = PPA.Get_Volume_Projections(PPA.procVol, 3); %% xy projection, i.e. normal MIP
    PPA.xzProc = PPA.Get_Volume_Projections(PPA.procVol, 2);
    PPA.yzProc = PPA.Get_Volume_Projections(PPA.procVol, 1);
    PPA.Update_Slice_Lines();

    % also update info on Volume size
    PPA.Handle_Master_Gui_State('vol_processing_complete');

    PPA.Stop_Wait_Bar();
  catch ME
    PPA.Stop_Wait_Bar();
    rethrow(ME);
  end

end
