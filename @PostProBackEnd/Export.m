function Export(PPA)

  try
    PPA.Update_Status(); % prints hor. bar
    PPA.Start_Wait_Bar(PPA.ExportGUI,'Exporting maps...');

    % figure out what we actually should export...
    exportOverview = PPA.ExportGUI.ExpOverview.Value;
    exportNative = PPA.ExportGUI.ExpNative.Value;
    exportDepth = PPA.ExportGUI.ExpDepthMap.Value;
    doOverwrite = PPA.ExportGUI.ExpOverWrite.Value;
    expImMat = PPA.ExportGUI.ExpImMat.Value;
    exportLog = PPA.ExportGUI.ExpLogFile.Value;

    % overwrite existing files or creat new ones? ------------------------------
    if ~doOverwrite
      exportCnt = PPA.exportCounter + 1; % used to not overwrite (if checked)
      cntAppend = sprintf('_ver%03.0f', exportCnt);
    else
      cntAppend = '';
      exportCnt = PPA.exportCounter;
    end

    % handle folder and file names, create export folder if neccesary ----------
    exportFolder = PPA.ExportGUI.expFolderPath.Value;
    nameBase = [PPA.ExportGUI.expFileName.Value cntAppend];

    if ~exist(exportFolder, 'dir')
      mkdir(exportFolder);
    end

    % generate depth maps and colormaps if we want to export images ------------
    if exportOverview || exportNative
      exportMip = normalize(PPA.procProj); %normalize to be able to properly export
      exportMip = round(256 .* exportMip); % use 256 colors per default, more usually does not make sense
      eval(['mipColorMap = ' PPA.MasterGUI.cBars.Value '(256);']); % turn string to actual colormap matrix
    end

    if exportOverview
      PPA.Start_Wait_Bar(PPA.ExportGUI,'Exporting overview projections...');

      % create invisible temp figure, plot mip and depth map with colorbars and use
      % export_fig for proper exporting
      fTemp = figure('Visible', 'Off', 'Position', [100 100 2000 1000]);
      % fTemp = figure('WindowState', 'maximized');
      % plot "normal" mip
      subplot(1, 2, 1)
      imagesc(gca, PPA.xPlot, PPA.yPlot, PPA.procProj);
      axis image;
      colormap(gca, mipColorMap);
      colorbar(gca);

      % plot depth map
      subplot(1, 2, 2)
      imagesc(gca, PPA.xPlot, PPA.yPlot, PPA.depthImage);
      axis image;
      colormap(gca, PPA.maskFrontCMap);
      c = colorbar(gca);
      c.TickLength = 0;
      c.Ticks = PPA.tickLocations;
      c.TickLabels = PPA.zLabels;

      % export figures, i.e. overview figures with axis and colorbars etc------
      if PPA.ExportGUI.ExpOverJpg.Value
        exportName = fullfile(exportFolder, [nameBase '_overview.jpg']);
        export_fig(fTemp, exportName);
      end

      if PPA.ExportGUI.ExpOverTiff.Value
        exportName = fullfile(exportFolder, [nameBase '_overview.tiff']);
        export_fig(fTemp, exportName);
      end

      if PPA.ExportGUI.ExpOverPng.Value
        exportName = fullfile(exportFolder, [nameBase '_overview.png']);
        export_fig(fTemp, exportName);
      end

      if PPA.ExportGUI.ExpOverPdf.Value && doOverwrite
        exportName = fullfile(exportFolder, [nameBase '_overview.pdf']);
        export_fig(fTemp, exportName);
      end

      if PPA.ExportGUI.ExpOverPdf.Value &&~doOverwrite
        exportName = fullfile(exportFolder, [PPA.ExportGUI.expFileName.Value '_overview.pdf']);
        export_fig(fTemp, exportName, '-append');
      end

      close(fTemp);
    end

    % export native resolution images, w or w/o compression, for best image quality
    if exportNative
      PPA.Start_Wait_Bar(PPA.ExportGUI,'Exporting native projections...');

      if PPA.ExportGUI.ExpNativePng.Value
        exportName = fullfile(exportFolder, [nameBase '_map.png']);
        imwrite(exportMip, mipColorMap, exportName);
      end

      if PPA.ExportGUI.ExpNativePng.Value && exportDepth
        exportName = fullfile(exportFolder, [nameBase '_depthmap.png']);
        imwrite(PPA.depthImage, exportName);
      end

      if PPA.ExportGUI.ExpNativeJpg.Value
        exportName = fullfile(exportFolder, [nameBase '_map.jpg']);
        imwrite(exportMip, mipColorMap, exportName);
      end

      if PPA.ExportGUI.ExpNativeJpg.Value && exportDepth
        exportName = fullfile(exportFolder, [nameBase '_depthmap.jpg']);
        imwrite(PPA.depthImage, exportName);
      end

      if PPA.ExportGUI.ExpNativeTiff.Value
        exportName = fullfile(exportFolder, [nameBase '_map.tiff']);
        imwrite(double(exportMip), mipColorMap, exportName);
      end

      if PPA.ExportGUI.ExpNativeTiff.Value && exportDepth
        exportName = fullfile(exportFolder, [nameBase '_depthmap.tiff']);
        imwrite(PPA.depthImage, exportName);
      end

    end

    % currently, volume exporting is not supported as this GUI is mostly
    % aimed at getting pretty projections, but could be easily added
    % export map file
    if expImMat
      PPA.Start_Wait_Bar(PPA.ExportGUI,'Exporting mat file...');
      SaveStruct.depthMapRGB = PPA.depthImage;
      SaveStruct.depthMap = PPA.depthInfo;
      % mapRaw needed to load processed map into gui again
      SaveStruct.mapRaw = PPA.procProj;
      SaveStruct.map = PPA.procProj;
      SaveStruct.x = PPA.x;
      SaveStruct.y = PPA.y;
      exportName = fullfile(exportFolder, [nameBase '_map.mat']);
      save(exportName, '-struct', 'SaveStruct');
    end

    if exportLog
      exportName = fullfile(exportFolder, [nameBase '.txt']);
      fid = fopen(exportName, 'w+');
      fprintf(fid, '%s\n', PPA.ExportGUI.DebugText.Items{:});
      fclose(fid);
    end

    PPA.exportCounter = exportCnt;
    PPA.Stop_Wait_Bar();
  catch me
    PPA.Stop_Wait_Bar();
    rethrow(me);
  end

end
