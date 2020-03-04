function Export(PPA)

  try

    if isempty(PPA.ExportGUI)
      short_warn('Export GUI not opened! Use MasterGUI->[Export & Batch Process]');
      return;
    end

    figure(PPA.ExportGUI.UIFigure); % bring export GUI to front

    PPA.Update_Status(); % prints hor. bar
    PPA.Start_Wait_Bar(PPA.ExportGUI, 'Exporting maps...');

    % figure out what we actually should export...
    exportOverview = PPA.ExportGUI.ExpOverview.Value;
    exportNative = PPA.ExportGUI.ExpNative.Value;
    exportDepth = PPA.ExportGUI.ExpDepthMap.Value;
    doOverwrite = PPA.ExportGUI.ExpOverWrite.Value;
    % export .mat files?
    expImMat = PPA.ExportGUI.ExpImMat.Value;
    expVolMat = PPA.ExportGUI.ExpVolMat.Value;
    compressVolMat = PPA.ExportGUI.ExpVolMatDoCmpr.Value;

    % export variables to workspace?
    expWrkIm = PPA.ExportGUI.ExpWrkIm.Value; % export map to workspace?
    expWrkVol = PPA.ExportGUI.ExpVolWrk.Value; % export map to workspace?

    % export log file?
    exportLog = PPA.ExportGUI.ExpLogFile.Value;

    % make sure we have a valid file name
    if isempty(PPA.ExportGUI.expFileName.Value)
      PPA.ExportGUI.expFileName.Value = inputdlg('Please enter file name for export!');
    end
    
    % overwrite existing files or creat new ones? ------------------------------
    if ~doOverwrite
      exportCnt = PPA.exportCounter + 1; % used to not overwrite (if checked)
      cntAppend = sprintf('_%i', exportCnt);
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
      PPA.Start_Wait_Bar(PPA.ExportGUI, 'Exporting overview projections...');

      % create invisible temp figure, plot mip and depth map with colorbars and use
      % export_fig for proper exporting
      fTemp = figure('Visible', 'Off', 'units', 'normalized', 'outerposition', [0 0 1 1]);
      % fTemp = figure('WindowState', 'maximized');
      % plot "normal" mip
      subplot(1, 2, 1)
      imagesc(gca, PPA.yPlot, PPA.xPlot, PPA.procProj);
      axis image;
      colormap(gca, mipColorMap);
      colorbar(gca,'Location', 'southoutside');

      % plot depth map
      subplot(1, 2, 2)
      imagesc(gca, PPA.yPlot, PPA.xPlot, PPA.depthImage);
      axis image;
      colormap(gca, PPA.maskFrontCMap);
      c = colorbar(gca,'Location', 'southoutside');
      c.TickLength = 0;
      c.Ticks = PPA.tickLocations;
      c.TickLabels = PPA.zLabels;
      c.Label.String = 'closer     <-     depth     ->     deeper';


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
      PPA.Start_Wait_Bar(PPA.ExportGUI, 'Exporting native projections...');

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

    % export map .mat file -----------------------------------------------------
    if expImMat
      PPA.Start_Wait_Bar(PPA.ExportGUI, 'Exporting mat files...');

      if exportDepth
        SaveStruct.depthMapRGB = PPA.depthImage;
        SaveStruct.depthMap = PPA.depthInfo;
      end

      SaveStruct.mapRaw = PPA.procProj;
      SaveStruct.map = PPA.procProj;
      SaveStruct.x = PPA.x;
      SaveStruct.y = PPA.y;
      exportName = fullfile(exportFolder, [nameBase '_mapData.mat']);
      save(exportName, '-struct', 'SaveStruct', '-v7.3', '-nocompression');
    end

    % export vol .mat file -----------------------------------------------------
    if expVolMat
      PPA.Start_Wait_Bar(PPA.ExportGUI, 'Exporting mat files...');
      SaveStruct.volData = PPA.procVol;
      SaveStruct.x = PPA.xPlot;
      SaveStruct.y = PPA.yPlot;
      SaveStruct.z = PPA.zPlot;
      exportName = fullfile(exportFolder, [nameBase '_volData.mat']);

      if compressVolMat
        save(exportName, '-struct', 'SaveStruct', '-v7.3');
      else
        save(exportName, '-struct', 'SaveStruct', '-v7.3', '-nocompression');
      end

    end

    % export map to workspace --------------------------------------------------
    if expWrkIm
      PPA.Start_Wait_Bar(PPA.ExportGUI, 'Exporting to workspace...');
      % NOTE permute and ' below to match first dim == x vector
      if exportDepth
        assignin('base', 'depthMapRGB', permute(PPA.depthImage, [2 1 3]));
        assignin('base', 'depthMap', PPA.depthInfo');
      end

      assignin('base', 'mapRaw', PPA.procProj');
      assignin('base', 'map', PPA.procProj');
      assignin('base', 'x', PPA.xPlotIm);
      assignin('base', 'y', PPA.yPlotIm);
    end

    % export volume to workspace --------------------------------------------------
    if expWrkVol
      PPA.Start_Wait_Bar(PPA.ExportGUI, 'Exporting to workspace...');
      assignin('base', 'procVol', PPA.procVol);
      assignin('base', 'x', PPA.xPlot);
      assignin('base', 'y', PPA.yPlot);
      assignin('base', 'z', PPA.zPlot);
    end

    % export log file --------------------------------------------------
    if exportLog
      exportName = fullfile(exportFolder, [nameBase '.txt']);
      fid = fopen(exportName, 'w+');
      fprintf(fid, '%s\n', PPA.MasterGUI.DebugText.Items{:});
      fclose(fid);
    end

    PPA.exportCounter = exportCnt;

    if PPA.ExportGUI.OpenFolder.Value && ~isunix
      winopen(exportFolder);
    end
    PPA.Stop_Wait_Bar();
  catch me
    PPA.Stop_Wait_Bar();
    rethrow(me);
  end

end
