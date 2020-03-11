classdef PostProBackEnd < BaseClass
  % PostProBackEnd Post processing and visualization of 2d and 3d datasets
  %   This is the backend to the PostPro app (PostPro.mlapp)
  %   PostPro defines the GUI and controlls callbacks etc, but PostProBackEnd is
  %   doing the actual work...
  %
  %   Accepts the follwoing files / formats
  %   - custom .mat files with Map or Vol data
  %       - FIXME add specs
  %   - matfile containing VolumetricDataset (https://github.com/razanskylab/MVolume)
  %   - files to be supported in the future:
  %     - tiff stacks
  %     - have user select dataset

  properties
    doBatchProcessing(1, 1) {mustBeNumericOrLogical, mustBeFinite} = 0; % flag which causes automatic processing and blocking of
    % dialogs etc
    processingEnabled = false; % if true, enables "automatic" processing cascade
    verboseOutput = true; 
      % used when GUIs work without master to suppres workspace output 

    isVolData = 0; % true when 3D data was loaded, which has a big influence
    % on the  overall processing we are doing
    fileType(1, 1) {mustBeNumeric, mustBeFinite} = 0;
    % 0 = invalid file, 1 = mat file, 2 = mVolume file, 3 = tiff stack, 4 = image file

    % sub-classes for processing
    FraFilt = Frangi_Filter();
    FreqFilt = FilterClass();
    IMF = Image_Filter.empty; % is filled/reset during Apply_Image_Processing
    AVA = Vessel_Analysis.empty;
    % file handling
    filePath = 'C:\Data';
    exportPath = [];
    batchPath = []; % folder to search for mat files for batch processing
    % file info
    MatFileVars; %  who('-file', PPA.filePath);
    MatFile; %      matfile(PPA.filePath);
    FileContent; %  whos(PPA.MatFile);

    % x,y,z - original position and depth vectors as loaded from the mat file
    % these are only changed during load, the vectors used for plotting are depended
    x(1, :) {mustBeNumeric, mustBeFinite};
    y(1, :) {mustBeNumeric, mustBeFinite};
    z(1, :) {mustBeNumeric, mustBeFinite};

    dt(1, :) {mustBeNumeric, mustBeFinite} = 250;
    df(1, :) {mustBeNumeric, mustBeFinite};

    % stores text shown in last tab, for debugging, also exported alongside
    % images
    debugText;

    % used to draw lines on volume projection
    lineCtr(1, 2) {mustBeNumeric, mustBeFinite};

    % used for lines in volume data slice picker
    HorLine;
    VertLine;

    % properties used to store depth map data used for exporting depth map
    maskFrontCMap(:, :) {mustBeNumeric, mustBeFinite};
    zLabels;
    tickLocations;
    exportCounter(1, 1) {mustBeNumeric, mustBeFinite};

    % projections from the processed volume (procVol)
    % NOTE: do not make part of AbortSet as otherwise clahe filtering settings
    % will be ignored
    procVolProj(:, :) single {mustBeNumeric, mustBeFinite}; % untouched proj. from procVol
    xzProc(:, :) single {mustBeNumeric, mustBeFinite};
    yzProc(:, :) single {mustBeNumeric, mustBeFinite};
    xzSlice(:, :) single {mustBeNumeric, mustBeFinite};
    yzSlice(:, :) single {mustBeNumeric, mustBeFinite};
  end

  properties (AbortSet)
    % NOTE AbortSet:
    % https://ch.mathworks.com/help/matlab/matlab_oop/set-events-when-value-does-not-change.html
    % don't call set function when Property Value Is Unchanged
    depthInfo(:, :) single {mustBeNumeric, mustBeFinite};
    % peak location for each pixel
    rawDepthInfo(:, :) single {mustBeNumeric, mustBeFinite};
    % raw version of depth info, to store orig when only loading 2d data...
    depthImage(:, :, 3) {mustBeNumeric, mustBeFinite};
    % image of the depth map
    % with transparency etc. applied, i.e. ready to be used
    % define volumes (in order of processing)
    rawVol(:, :, :) single {mustBeNumeric, mustBeFinite}; % raw untouched vol
    dsVol(:, :, :) single {mustBeNumeric, mustBeFinite}; % downsampled volume...
    cropVol(:, :, :) single {mustBeNumeric, mustBeFinite}; % cropped volume
    freqVol(:, :, :) single {mustBeNumeric, mustBeFinite}; % freq. filtered volume
    filtVol(:, :, :) single {mustBeNumeric, mustBeFinite}; % median filtered volume
    procVol(:, :, :) single {mustBeNumeric, mustBeFinite};
    % processed volume, the one we get projections from
    % NOTE all volumes are updated if any of the "previous" volumes is changed
    % in the end, they are all dependet variables, but recalculating everything

    % final processed image <----
    procProj(:, :) single {mustBeNumeric, mustBeFinite};
  end

  % plot and other handles
  properties
    % handles to GUI apps
    MasterGUI = [];
    LoadGUI = []; % handle to app for loading raw files
    VolGUI = [];
    MapGUI = [];
    MapFig = []; % handles to map/depthmap figure
    VesselGUI = [];
    VesselFigs = []; % handles to figure for vessel analysis plotting
    ExportGUI = [];

    ProgBar; % storage for progress bar(s)
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  properties (Dependent = true)
    fileName;
    folderPath;
    fileExists;
    fileExt;

    nX; nY; nZ; % size of processed volume (or rawVol if procVol = [])
    nXIm; nYIm; % size of interpolated/downsampled image
    dX; dY; dZ; % resoltuion/step size of processed  volume
    dXIm; dYIm; % resoltuion/step size of processed  volume
    xPlot; yPlot; zPlot; % XYZ vectors for plotting of volume data
    xPlotIm; yPlotIm; % XYZ vectors for plotting of map data

    % re-sampled versions of orig x and y vectors
    cropRange(1, :) {mustBeNumeric, mustBeFinite};
    centers(1, 3) {mustBeNumeric, mustBeFinite};
    % calculated actual frangi scales based on start / end / nScales

    % volume processing settings, taken from GUI -------------------------------
    doVolCropping(1, 1) {mustBeNumeric, mustBeFinite};
    doVolDownSampling(1, 1) {mustBeNumeric, mustBeFinite};
    volSplFactor(1, 2) {mustBeNumeric, mustBeFinite};
    doVolMedianFilter(1, 1) {mustBeNumeric, mustBeFinite};
    volMedFilt(1, 3) {mustBeNumeric, mustBeFinite};
    doVolPolarity(1, 1) {mustBeNumeric, mustBeFinite};
    volPolarity(1, 1) {mustBeNumeric, mustBeFinite};

    % image processing settings, taken from GUI --------------------------------
    doImSpotRemoval(1, 1) {mustBeNumeric, mustBeFinite};
    imInterpFct(1, 1) {mustBeNumeric, mustBeFinite};
    doImInterpolate(1, 1) {mustBeNumeric, mustBeFinite};
    imSpotLevel(1, 1) {mustBeNumeric, mustBeFinite};
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  properties (Constant)
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    % constructor, called when class is created
    function PPA = PostProBackEnd()
    end

    function Stop_Wait_Bar(PPA)
      PPA.ProgBar = [];
    end

    function Update_Status(PPA, statusText, append)
      if nargin < 3
        append = false;
      end
      if ~isempty(PPA.MasterGUI)
        if nargin == 1
          statusText = sprintf(repmat('-', 1, 66));
        end
        
        if append
          PPA.MasterGUI.DebugText.Items{end} = [PPA.MasterGUI.DebugText.Items{end} statusText];
        else
          PPA.MasterGUI.DebugText.Items = [PPA.MasterGUI.DebugText.Items statusText];
        end
        PPA.MasterGUI.DebugText.scroll('bottom');
        
        if ~isempty(PPA.ProgBar) && (nargin == 2)
          PPA.ProgBar.Title = statusText;
        end
      else
        % when working on their own, subguis just output status to workspace
        % instead of the master gui...
        if append
          PPA.VPrintF(statusText);
        else
          PPA.VPrintF([statusText '\n']);
        end
      end
      if ~isempty(PPA.ProgBar)
        PPA.ProgBar.Message = statusText;
      end
    end

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Static)

    function newFiltValue = Get_Allowed_Med_Filt_Coeff(origFiltValue)
      % get allowed median filter value (must be odd and > 1)
      newFiltValue = round(origFiltValue); % just to be safe

      if (newFiltValue > 2) &&~rem(newFiltValue, 2)
        newFiltValue = newFiltValue - 1;
      elseif newFiltValue < 1
        newFiltValue = 1;
      end

    end

    function isVisible = Is_Visible(AppHandle)
      isVisible = ~isempty(AppHandle) && strcmp(AppHandle.UIFigure.Visible, 'on');
    end

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods % SET / GET methods

    % file handling set/get methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function fileName = get.fileName(PPA)

      if ~isempty(PPA.filePath)
        [~, fileName] = fileparts(PPA.filePath);
      else
        fileName = [];
      end

    end

    function folderPath = get.folderPath(PPA)

      if ~isempty(PPA.filePath)
        folderPath = fileparts(PPA.filePath);
      else
        folderPath = [];
      end

    end

    function fileExists = get.fileExists(PPA)

      if ~isempty(PPA.filePath)
        fileExists = (exist(PPA.filePath, 'file') == 2);
      else
        fileExists = false;
      end

    end

    function fileExt = get.fileExt(PPA)

      if ~isempty(PPA.filePath)
        [~, ~, fileExt] = fileparts(PPA.filePath);
      else
        fileExt = [];
      end

    end

    % SET functions for all volumes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % NOTE all volumes are updated if any of the "previous" volumes is changed
    % in the end, they are all dependet variables, but recal everything every
    % time is too time consuming
    % suppress the get methods should not acces other prop. warnings...
    %#ok<*MCSUP>

    % raw untouched vol
    function set.rawVol(PPA, newRawVol)
      PPA.rawVol = newRawVol;

      if ~isempty(newRawVol) && PPA.processingEnabled
        PPA.Down_Sample_Volume();
      end

    end

    % downsampled volume...
    function set.dsVol(PPA, newDsVol)
      PPA.dsVol = newDsVol;
      PPA.Crop_Volume(); % sets cropVol
    end

    % cropped volume
    function set.cropVol(PPA, newCropVol)
      PPA.cropVol = newCropVol;
      PPA.Freq_Filt_Volume(); % sets freqVol
    end

    % freq. filtered volume
    function set.freqVol(PPA, newFreqVol)
      PPA.freqVol = newFreqVol;
      PPA.Med_Filt_Volume(); % sets filtVol
    end

    % median filtered volume
    function set.filtVol(PPA, newFiltVol)
      PPA.filtVol = newFiltVol;
      PPA.Apply_Polarity_Volume(); % sets procVol
    end

    % processed volume, the one we get projections from
    % NOTE this is the final volume we get the depth information from as well
    function set.procVol(PPA, newProcVol)
      PPA.procVol = newProcVol;
      % FIXME convert depth info to actual mm
      [~, depthMap] = max(newProcVol, [], 3);
      depthMap = imrotate(depthMap, -90);
      depthMap = PPA.z(depthMap); % replace idx value with actual depth in mm
      PPA.depthInfo = single(depthMap);
      PPA.rawDepthInfo = single(depthMap);
      PPA.Update_Vol_Projections(); % set procProj and others
      PPA.Handle_Master_Gui_State('vol_processing_complete');
      PPA.Handle_Export_Controls();
    end

    % SET functions for all projections / MIPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % final processed image
    % this is the basis for the depth map and what we export
    function set.procProj(PPA, newProj)
      PPA.procProj = newProj;
      PPA.Handle_Export_Controls();
    end

    % untouched proj. from procVol NOTE this is the one we set when we only load
    % map data, as we use the "raw" map, i.e. the one without any contrast
    % enhancements etc...
    function set.procVolProj(PPA, newProj)
      PPA.procVolProj = newProj;

      % do simple clahe filtering and show image in VolGUI
      if ~isempty(PPA.procVolProj) && PPA.isVolData
        newProj = PPA.Apply_Image_Processing_Simple(newProj);
        PPA.Update_Image_Panel(PPA.VolGUI.FiltDisp, newProj, 3);
      end

      % apply image processing cascade to new projection, then updates maps
      doApplyImageProc = ~isempty(PPA.procVolProj) &&~isempty(PPA.MapGUI) && ...
        PPA.processingEnabled && strcmp(PPA.MapGUI.UIFigure.Visible, 'on');

      if doApplyImageProc
        PPA.Apply_Image_Processing(); % this sets a new procProj
      end

    end

    %---------------------------------------------------------------
    function set.xzProc(PPA, newProj)
      PPA.xzProc = newProj;

      if ~isempty(PPA.xzProc)
        newProj = PPA.Apply_Image_Processing_Simple(newProj);
        PPA.Update_Image_Panel(PPA.VolGUI.xzProjDisp, newProj, 2);
      end

    end

    %---------------------------------------------------------------
    function set.yzProc(PPA, newProj)
      PPA.yzProc = newProj;

      if ~isempty(PPA.yzProc)
        newProj = PPA.Apply_Image_Processing_Simple(newProj);
        PPA.Update_Image_Panel(PPA.VolGUI.yzProjDisp, newProj, 1);
      end

    end

    %---------------------------------------------------------------
    function set.xzSlice(PPA, newProj)
      PPA.xzSlice = newProj;

      if ~isempty(PPA.xzSlice)
        newProj = PPA.Apply_Image_Processing_Simple(newProj);
        PPA.Update_Image_Panel(PPA.VolGUI.xzSliceDisp, newProj, 2);
      end

    end

    %---------------------------------------------------------------
    function set.yzSlice(PPA, newProj)
      PPA.yzSlice = newProj;

      if ~isempty(PPA.yzSlice)
        newProj = PPA.Apply_Image_Processing_Simple(newProj);
        PPA.Update_Image_Panel(PPA.VolGUI.yzSliceDisp, newProj, 1);
      end

    end

    % set / get functions for postions etc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % nX; nY; nZ; % size of processed volume (or rawVol if procVol = [])
    % nXIm; nYIm; % size of interpolated/downsampled image
    % dX; dY; dZ; % resoltuion/step size of processed  volume
    % dXI; dYI; % resoltuion/step size of processed  volume
    % zPlot; xPlot; yPlot; % XYZ vectors for plotting of volume data
    % xPlotIm; yPlotIm; % XYZ vectors for plotting of map data

    %---------------------------------------------------------------
    %---------------------------------------------------------------
    function nX = get.nX(PPA)

      if ~isempty(PPA.procVol)
        nX = size(PPA.procVol, 1); % proc vol order [xyz]
      elseif ~isempty(PPA.rawVol)
        nX = size(PPA.rawVol, 2); % raw vol order [zxy]
      else
        nX = 0; % better return 0 than [] for most cases...
      end

    end

    %---------------------------------------------------------------
    function nXIm = get.nXIm(PPA)% size of interpolated/downsampled image
      nXIm = size(PPA.procProj, 2);
    end

    %---------------------------------------------------------------
    function xPlot = get.xPlot(PPA)

      if PPA.doVolDownSampling
        xPlot = PPA.x(1:PPA.volSplFactor(1):end);
      else
        xPlot = PPA.x;
      end

    end

    %---------------------------------------------------------------
    function xPlotIm = get.xPlotIm(PPA)

      if PPA.imInterpFct
        xPlotIm = linspace(PPA.xPlot(1), PPA.xPlot(end), PPA.nXIm);
      else
        xPlotIm = PPA.xPlot;
      end

    end

    %---------------------------------------------------------------
    function dX = get.dX(PPA)% step size of processed volume
      dX = mean(diff(PPA.xPlot));
    end

    %---------------------------------------------------------------
    function dXIm = get.dXIm(PPA)% step size of processed volume
      dXIm = mean(diff(PPA.xPlotIm));
    end

    %---------------------------------------------------------------
    %---------------------------------------------------------------
    function nY = get.nY(PPA)

      if ~isempty(PPA.procVol)
        nY = size(PPA.procVol, 2); % proc vol order [xyz]
      elseif ~isempty(PPA.rawVol)
        nY = size(PPA.rawVol, 3); % raw vol order [zxy]
      else
        nY = 0; % better return 0 than [] for most cases...
      end

    end

    %---------------------------------------------------------------
    function nYIm = get.nYIm(PPA)
      nYIm = size(PPA.procProj, 1);
    end

    %---------------------------------------------------------------
    function yPlot = get.yPlot(PPA)

      if PPA.doVolDownSampling
        yPlot = PPA.y(1:PPA.volSplFactor(1):end);
      else
        yPlot = PPA.y;
      end

    end

    %---------------------------------------------------------------
    function yPlotIm = get.yPlotIm(PPA)

      if PPA.imInterpFct
        yPlotIm = linspace(PPA.yPlot(1), PPA.yPlot(end), PPA.nYIm);
      else
        yPlotIm = PPA.yPlot;
      end

    end

    %---------------------------------------------------------------
    function dY = get.dY(PPA)% step size of processed volume
      dY = mean(diff(PPA.yPlot));
    end

    %---------------------------------------------------------------
    function dYIm = get.dYIm(PPA)% step size of processed volume
      dYIm = mean(diff(PPA.yPlotIm));
    end

    %---------------------------------------------------------------
    %---------------------------------------------------------------
    function nZ = get.nZ(PPA)

      if ~isempty(PPA.procVol)
        nZ = size(PPA.procVol, 3); % proc vol order [xyz]
      elseif ~isempty(PPA.rawVol)
        nZ = size(PPA.rawVol, 1); % raw vol order [zxy]
      else
        nZ = 0;
      end

    end

    %---------------------------------------------------------------
    function zPlot = get.zPlot(PPA)
      % check if we are downsampling in z
      if PPA.doVolDownSampling
        zPlot = PPA.z(1:PPA.volSplFactor(2):end);
      else
        zPlot = PPA.z;
      end

      % cropping ranges do not take into account downsampling
      if PPA.doVolCropping
        zPlot = zPlot(PPA.cropRange);
      end

    end

    %---------------------------------------------------------------
    function dZ = get.dZ(PPA)% step size of processed volume
      dZ = mean(diff(PPA.zPlot));
    end

    % OTHER set / get functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %---------------------------------------------------------------
    function cropRange = get.cropRange(PPA)

      if PPA.doVolCropping
        % indicies to be used to get cropped volume after a potential
        % downsampling

        % get "original" start and stop indicies e.g. 50:450
        startIdx = PPA.VolGUI.zCropLowEdit.Value;
        stopIdx = PPA.VolGUI.zCropHighEdit.Value;

        % correct for potential volumetric downsampling e.g. 50:450 -> 25:225
        if PPA.doVolDownSampling
          startIdx = ceil(startIdx ./ PPA.volSplFactor(2));
          stopIdx = floor(stopIdx ./ PPA.volSplFactor(2));
        end

        cropRange = startIdx:stopIdx;
      else
        cropRange = 1:PPA.nZ; % nZ is number of samples of proc Volume...
        % thus it takes into account downsampling already...
      end

    end

    % volume processing settings, taken from VolGUI -------------------------------
    function doVolCropping = get.doVolCropping(PPA)

      if ~isempty(PPA.VolGUI)
        doVolCropping = PPA.VolGUI.CropCheck.Value;
      else
        doVolCropping = false;
      end

    end

    %---------------------------------------------------------------
    function doVolDownSampling = get.doVolDownSampling(PPA)

      if ~isempty(PPA.VolGUI)
        doVolDownSampling = PPA.VolGUI.DwnSplCheck.Value;
      else
        doVolDownSampling = false;
      end

    end

    %---------------------------------------------------------------
    function volSplFactor = get.volSplFactor(PPA)
      volSplFactor(1) = PPA.VolGUI.DwnSplFactorEdit.Value;
      volSplFactor(2) = PPA.VolGUI.DepthDwnSplFactorEdit.Value;
    end

    %---------------------------------------------------------------
    function volMedFilt = get.volMedFilt(PPA)
      volMedFilt(1) = PPA.VolGUI.MedFiltX.Value;
      volMedFilt(2) = PPA.VolGUI.MedFiltY.Value;
      volMedFilt(3) = PPA.VolGUI.MedFiltZ.Value;
    end

    %---------------------------------------------------------------
    function doVolPolarity = get.doVolPolarity(PPA)
      doVolPolarity = PPA.VolGUI.PolarityCheck.Value;
    end

    %---------------------------------------------------------------
    function volPolarity = get.volPolarity(PPA)

      switch PPA.VolGUI.PolarityDropDown.Value
        case 'Positive'
          volPolarity = 1;
        case 'Negative'
          volPolarity = 3;
        case 'Absolute'
          volPolarity = 4;
        case 'Envelope'
          volPolarity = 2;
      end

    end

    %---------------------------------------------------------------
    function doVolMedianFilter = get.doVolMedianFilter(PPA)
      doVolMedianFilter = PPA.VolGUI.MedFiltCheck.Value;
    end

    %---------------------------------------------------------------
    function centers = get.centers(PPA)
      centers(1, 1) = mean(minmax(PPA.xPlot));
      centers(1, 2) = mean(minmax(PPA.yPlot));

      if ~isempty(PPA.zPlot)
        centers(1, 3) = mean(minmax(PPA.zPlot));
      else
        centers(1, 3) = 0;
      end

    end

    % Image processing settings from GUI ---------------------------------------
    function doImSpotRemoval = get.doImSpotRemoval(PPA)

      if ~isempty(PPA.MapGUI)
        doImSpotRemoval = PPA.MapGUI.SpotRemovalCheckBox.Value;
      else
        doImSpotRemoval = 0;
      end

    end

    function imSpotLevel = get.imSpotLevel(PPA)

      if ~isempty(PPA.MapGUI)
        imSpotLevel = PPA.MapGUI.imSpotRem.Value;
      else
        imSpotLevel = [];
      end

    end

    function doImInterpolate = get.doImInterpolate(PPA)

      if ~isempty(PPA.MapGUI) || (PPA.imInterpFct == 1)
        doImInterpolate = PPA.MapGUI.InterpolateCheckBox.Value;
      else
        doImInterpolate = 0;
      end

    end

    function imInterpFct = get.imInterpFct(PPA)

      if ~isempty(PPA.MapGUI)
        imInterpFct = PPA.MapGUI.imInterpFct.Value;
      else
        imInterpFct = 1;
      end

    end

  end

end
