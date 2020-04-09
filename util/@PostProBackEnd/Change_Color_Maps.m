function Change_Color_Maps(PPA)
  % Change_ColorMaps()
  % what is this function doing?
  try
    % PPA.Start_Wait_Bar(PPA.LoadGUI, 'test')
    % PPA.Start_Wait_Bar(PPA.App, 'test')
    % TODO
    % check in Map figure exists
    % colormap(app.PPA.VolGui.FiltDisp,app.cBars.Value);
    % TODO change volume colormaps as well
    if ~isempty(PPA.MapFig)
      colormap(PPA.MapFig.MapAx, PPA.MasterGUI.cBars.Value);
    end
    % don't change vessel analysis plots, as different colormaps will
    % probably not work well and gray looks good...
      % get to colorbar to use
    % if isempty(PPA.MasterGUI)
    %   VesselFigs.cbar = gray(256);
    % else
    %   VesselFigs.cbar = PPA.MasterGUI.cBars.Value;
    %   eval(['VesselFigs.cbar = ' VesselFigs.cbar '(256);']); % turn string to actual colormap matrix
    % end
  catch ME
    % PPA.Stop_Wait_Bar();
    rethrow(ME);
  end

end