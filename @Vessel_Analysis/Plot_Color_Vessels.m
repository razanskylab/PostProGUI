function Plot_Color_Vessels(AVA)
  figure();
  plotLines = false;
  % turn xy map into rgb image and display that
  nColors = 255;
  cMap = AVA.colorMap;
  plotImage = normalize(adapthisteq(AVA.xy,'ClipLimit',0.02));
  indexImage = gray2ind(plotImage,nColors);
  rgbImage = ind2rgb(indexImage,cMap);
  imagesc(rgbImage); axis image; title('combined');

  % now we can display whatever colorbar we want, it will not affect the xy map
  C = Colors;
  vesselColormap = C.greenToRed;


  colormap(gca,vesselColormap);
  c = colorbar;
  if plotLines
    % plot vessels as line width widht and color depending on vessel diameter
    maxLineWidth = 6; %maximum width to be used for largest vessels during plotting
    % don't make it to large, as this will cause plotting artifacts
    [vesDiameters] = plot_vessel_diameters_lines(AVA.Data.vessel_list,vesselColormap,maxLineWidth);
  else
    % plot vessels as dots width area and color depending on vessel diameter
    % much faster and kinda looks cooler I think...
    areaScaling = 0.1;
    [vesDiameters] = plot_vessel_diameters(AVA.Data.vessel_list,vesselColormap,areaScaling);
  end
  vesDiameters = vesDiameters*AVA.dR*1e3;
  % change colorbar labels to indicate vessel sizes
  c.Ticks = [0 0.5 1];
  halfDia = (min(vesDiameters)+max(vesDiameters))/2;
  labels{1} = [num2str(min(vesDiameters),'%2.0f'),' um'];
  labels{2} = [num2str(halfDia,'%2.0f'),' um'];
  labels{3} = ['>= ' num2str(max(vesDiameters),'%2.0f'),' um'];
  c.TickLabels = labels;

  title('Color-Coded Vessel Size');
  axis off;

end
