function Update_Vol_Projections(PPA)
  % Update_Vol_Projections()
  % get unprocessed volume projections and slices
  % those could be clahe filtered depending on GUI stetings
  %
  % see also Apply_Image_Processing_Simple()
  try
    PPA.Start_Wait_Bar(PPA.VolGUI, 'Updating volume projections...')
    [procVolProj, depthMap] = PPA.Get_Volume_Projections(PPA.procVol, 3);
    
    % write depth map before procVolProj as the latter starts the map processing
    depthMap = PPA.z(depthMap); % replace idx value with actual depth in mm
    PPA.depthInfo = single(depthMap);
    PPA.rawDepthInfo = single(depthMap);
    % TODO convert depth info to actual mm

    % set all new projections
    PPA.procVolProj = procVolProj; %% xy projection, i.e. normal MIP
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
