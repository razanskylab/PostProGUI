function Update_Map_Projections(PPA, newProj)
  % Update_Map_Projections()
  %
  % see also Apply_Image_Processing()
  try

    plotAx = PPA.MapGUI.imFiltDisp.Children(1);
    set(plotAx, 'cdata', newProj);
    set(plotAx, 'ydata', PPA.xPlot);
    set(plotAx, 'xdata', PPA.yPlot);
    PPA.MapGUI.imFiltDisp.CLim = minmax(newProj); % update colorbar limits

    PPA.Update_Depth_Map();
  catch ME
    PPA.Stop_Wait_Bar();
    rethrow(ME);
  end

end
