function Update_Map_Projections(PPA, newProj)
  % Update_Map_Projections()
  %
  % see also Apply_Image_Processing()
  try
    if isempty(PPA.MapFig)
      PPA.Setup_Map_Figure();
    end
    figure(PPA.MapFig.MainFig);

    set(PPA.MapFig.MapIm, 'cdata', newProj);
    set(PPA.MapFig.MapIm, 'ydata', PPA.xPlot);
    set(PPA.MapFig.MapIm, 'xdata', PPA.yPlot);
    PPA.MapFig.MapAx.CLim = minmax(newProj); % update colorbar limits
    
    if ~isempty(PPA.depthInfo)
      PPA.Update_Depth_Map();
    end
    PPA.ProgBar = [];
  catch ME
    PPA.Stop_Wait_Bar();
    rethrow(ME);
  end

end
