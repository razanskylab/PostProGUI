function PostVesselZoomCallback(hObject, eventdata)
    ax = eventdata.Axes; % handle to axis that was zoomed
    PPA = hObject.UserData; % Post pro backend
    PPA.VesselFigs.InPlot.XLim = ax.XLim;
    PPA.VesselFigs.InPlot.YLim = ax.YLim;

    PPA.VesselFigs.BinPlot.XLim = ax.XLim;
    PPA.VesselFigs.BinPlot.YLim = ax.YLim;

    PPA.VesselFigs.BinCleanPlot.XLim = ax.XLim;
    PPA.VesselFigs.BinCleanPlot.YLim = ax.YLim;

    % TODO add other handles here as needed
    % PPA.VesselFigs.InPlot.XLim = ax.XLim;
    % PPA.VesselFigs.InPlot.YLim = ax.YLim;
end

