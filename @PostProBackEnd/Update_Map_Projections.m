function Update_Map_Projections(PPA, newProj)
  % Update_Map_Projections()
  %
  % see also Apply_Image_Processing()
  try
    % PPA.Start_Wait_Bar(PPA.LoadGUI, 'test')
    PPA.Start_Wait_Bar(PPA.MapGUI, 'Updating map projections...')

    plotAx = PPA.MapGUI.imFiltDisp.Children(1);
    set(plotAx, 'cdata', newProj);
    set(plotAx, 'xdata', PPA.xPlot);
    set(plotAx, 'ydata', PPA.yPlot);
    PPA.MapGUI.imFiltDisp.CLim = minmax(newProj); % update colorbar limits

    PPA.Update_Depth_Map(PPA.MapGUI.imDepthDisp);
    
    PPA.Stop_Wait_Bar();
  catch ME
    PPA.Stop_Wait_Bar();
    rethrow(ME);
  end

end