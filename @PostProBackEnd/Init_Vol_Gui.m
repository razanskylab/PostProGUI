function Init_Vol_Gui(PPA)
  % Init_Vol_Gui()
  % called after Gui app is loaded, sets limits etc. based on
  % specific volume currently handeled by PPA
  try
    % check if we actually have data
    if isempty(PPA.rawVol)
      % uialert(PPA.VolGUI.UIFigure, 'We have no volume data!', ...
      %   'We have no volume data!');
      notUsed = uiconfirm(PPA.VolGUI.UIFigure, 'We have no volume data!', 'We have no volume data!', ...
        'Icon', 'warning', 'Options', {'Ok I guess...'}); %#ok<NASGU>
      PPA.VolGUI.UIFigure.Visible = 'off'; % make it dissapear!
      return;
    end

    PPA.Start_Wait_Bar(PPA.VolGUI, 'Initializing Volume Gui...')
    maxZ = size(PPA.rawVol, 1);
    PPA.VolGUI.zCropLowEdit.Limits = [1 maxZ];
    PPA.VolGUI.zCropHighEdit.Limits = [1 maxZ];
    % ensure we get no images smaller than 50x50
    PPA.VolGUI.DwnSplFactorEdit.Limits = [1 round(min([PPA.nX PPA.nY]) ./ 50)];

    % now start the actual volume processing based on cascading set/get
    % functions, which all utilize the abortset property
    PPA.processingEnabled = true;
    PPA.Down_Sample_Volume(); % starts the set/get processing cascade

    % put line in the x-y center
    PPA.lineCtr = PPA.centers(1:2);
    PPA.Update_Slice_Lines();
    PPA.Stop_Wait_Bar();
  catch ME
    PPA.Stop_Wait_Bar();
    rethrow(ME);
  end

end
