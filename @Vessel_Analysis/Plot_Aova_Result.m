function Plot_Aova_Result(AVA)

  branchColor = Colors.DarkPurple;
  branchMarkerSize = 40;
  centerColor = Colors.DarkOrange;

  figure();
  imagescj(normalize(adapthisteq(AVA.xy,'ClipLimit',0.02)),'gray'); colorbar('off'); axis('off');
  hold on;
  title('AOVA Results');
  if ~isempty(AVA.Data.branchCenters)
      scatter(AVA.Data.branchCenters(:,1),AVA.Data.branchCenters(:,2),...
        branchMarkerSize,'filled','MarkerFaceColor',branchColor);
  end

  plot_vessel_centerlines(AVA.Data.vessel_list,centerColor,2);
  plot_vessel_edges(AVA.Data.vessel_list,centerColor,1);

  legend({'Branch Points','Centerlines','Edges'});

end
