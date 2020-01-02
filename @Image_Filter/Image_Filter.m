% Class to perform frangi filtering, returns scales and combined frangi filtered
% images, can also generate overlay maskes of frangi scales.

classdef Image_Filter < BaseClass

  properties
    % should not matter in most cases but still not bad to have
    x, y;
    % store frangi filtered images seperate
    filt;
    % original xy map, as first input to Maps structure
    raw;

    % default don't show histo for xy-plots
    showHisto = 0;

    % general settings --------------------------------------------------------------
    % more detailed output to workspace...
    verboseOutput(1, 1) {mustBeNumericOrLogical} = false;
    % more figures...
    verbosePlotting(1, 1) {mustBeNumericOrLogical} = false;

    % interpolation --------------------------------------------------------------
    interpFactor = 2;
    interpMethod = 'linear';
    % can be 'linear' | 'nearest' | 'cubic' | 'spline' | 'makima'

    % spot removal
    spotLevels = 5;
    % higher values mean more aggresive spot removal

    % localtonemap --------------------------------------------------------------
    ltmContrast = 0.1; % [0-1] Amount of local contrast enhancement applied
    ltmCompression = 0.1; % [0-1] Amount of compression applied to the dynamic range of the HDR image

    % localcontrast - Apply_LC
    lcEdgeThres = 0.3; % Amplitude of strong edges to leave intact, [0,1],
    lcAmount = 0.25; % Amount of enhancement or smoothing, [-1,1], -1 = smooting

    % locallapfilt - Apply_LLF
    llfSigma = 0.1; % Amplitude of edges, [0,1] for normalized images,
    llfAlpha = 2; % Smoothing of details, typical [0.01, 10],
    % llfAlpha < 1 - increase the details of the input image
    % llfAlpha > 1 - smooths details while preserving crisp edges
    % llfAlpha = 1 - details of the input image are left unchanged
    llfBeta = 1; % smoothing of details,
    % llfBeta < 1 - reduce amp. of edges, compressing dynamic range without affecting details.
    % llfBeta > 1 -	expand the dynamic range of the image
    % llfBeta = 1 -	Dynamic range of the image is left unchanged.

    % adapthisteq  - Apply_CLAHE
    claheDistr = 'exponential'; % 'uniform''rayleigh''exponential' Desired histogram shape
    claheNBins = 256; % histogram bins used for contrast enhancing transformation
    claheLim = 0.02; % enhancement limit, [0, 1], higher limits result in more contrast
    claheNTiles = [32 32]; % image divided into M x N tiles, 'NumTiles' = [M N]

    % imadjust - Adjust
    imadLimIn = [0 1];
    imadLimOut = [0 1];
    imadGamme = 1;
    imadAuto = 1;

    % Sharpen
    % Standard deviation of the Gaussian lowpass filter
    sharpRadius(1, 1) double {mustBeNumeric, mustBeFinite} = 5;
    % Strength of the sharpening effect, typical range [0 2]
    sharpAmout(1, 1) double {mustBeNumeric, mustBeFinite} = 0.5;
    % contrast required to be an edge, [0 1]
    sharpThresh(1, 1) double {mustBeNumeric, mustBeFinite} = 0.9;

    % wiener
    nWienerPixel(1, 1) uint16 {mustBeNumeric, mustBeFinite} = 3;

    % image guided filter
    imGuideNhoodSize(1, 1) uint16 {mustBeNumeric, mustBeFinite} = 3;
    imGuideSmoothValue(1, 1) double {mustBeNumeric, mustBeFinite} = 0.1;
  end

  properties (SetAccess = private)
    % step sizes, calculated automatically from x,y,z using get methods, can't be set!
    dX; dY;
    dR; % average x-y pixels size
  end

  properties (Hidden = true)

  end

  events
    FiltUpdated;
  end

  % Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods

    function newImFilt = Image_Filter(varargin)
      className = class(newImFilt);

      if nargin

        if isa(varargin{1}, className)
          % note that if first input arg when creating new instance of class is a
          % Maps object then we will create a deep copy of the data, this is neccesary
          % because a simple copy of a handle object only creates a shallow copy
          % and if we don't make it a handle class then things lile F.Norm don't work
          % and we would have to write M = F.Norm which makes things messy again...
          % Construct a new object based on a deep copy of an old object
          oldMap = varargin{1}; % copy data from this "old" Map
          props = properties(oldMap); % get all properties
          % turn off warnigs during deep copy to ignore methods
          % that compalain that there is no data when queried later...
          preWarnSettings = warning();
          warning('off')

          for i = 1:length(props)
            newImFilt.(props{i}) = oldMap.(props{i});
          end

          warning(preWarnSettings);
        elseif isa(varargin{1}, 'Maps')% construct from Maps class info
          MapsClass = varargin{1};
          newImFilt.x = MapsClass.x;
          newImFilt.y = MapsClass.y;
          newImFilt.filt = MapsClass.xy;
          newImFilt.verboseOutput = MapsClass.verboseOutput;
        elseif isnumeric(varargin{1})% 2d array
          newImFilt.filt = varargin{1};
          newImFilt.raw = varargin{1};
          % assign vectors as well if provided
          if nargin == 3
            newImFilt.x = varargin{2};
            newImFilt.y = varargin{3};
          end

        end

      end

    end

    function saveFilter = saveobj(IMF)
      % don't save empty objects...
      if isempty(IMF.filt)
        saveFilter = [];
      else
        saveFilter = IMF;
      end

    end

    % convenience function for plotting
    function P(IMF, varargin)
      IMF.Plot(varargin{:});
    end

    % localtonemap -------------------------------------------------------------
    function [filt] = Apply_LTM(IMF)
      % NOTE works but increases noise a LOT as well
      tic;

      if IMF.verboseOutput
        fprintf('[localtonemap] Compressing dynamic range...')
      end

      filt = IMF.filt;

      if IMF.autoPreNorm
        filt = normalize(filt);
      end

      % perform actual filtering
      filt = double(localtonemap(single(filt), 'RangeCompression', ...
        IMF.ltmCompression, 'EnhanceContrast', IMF.ltmContrast));

      if IMF.autoPostNorm
        filt = normalize(filt);
      end

      if IMF.verboseOutput
        done(toc);
      end

      IMF.filt = filt;
    end

    % localcontrast ------------------------------------------------------------
    function [filt] = Apply_LC(IMF)
      % Edge-aware local contrast manipulation of images
      if IMF.verboseOutput
        jprintf('[localcontrast] Edge-aware local contrast enhancement...')
      end

      filt = IMF.filt;

      if IMF.autoPreNorm
        filt = normalize(filt);
      end

      filt = double(localcontrast(single(filt), IMF.lcEdgeThres, IMF.lcAmount));

      if IMF.autoPostNorm
        filt = normalize(filt);
      end

      if IMF.verboseOutput
        done(toc);
      end

      IMF.filt = filt;
      notify(IMF, 'FiltUpdated'); % FIXME needs to be added everywhere!
    end

    % locallapfilt -------------------------------------------------------------
    function [filt] = Apply_LLF(IMF)
      % filters the image A with an edge-aware, fast local Laplacian filter.
      % sigma characterizes the amplitude of edges in A. alpha controls smoothing of details.
      if IMF.verboseOutput
        jprintf('[locallapfilt] Local laplacian filtering...')
      end

      filt = IMF.filt;

      if IMF.autoPreNorm
        filt = normalize(filt);
      end

      filt = double(locallapfilt(single(filt), IMF.llfSigma, IMF.llfAlpha, IMF.llfBeta));

      if IMF.autoPostNorm
        filt = normalize(filt);
      end

      if IMF.verboseOutput
        done(toc);
      end

      IMF.filt = filt;
      notify(IMF, 'FiltUpdated'); % FIXME needs to be added everywhere!
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % All Filters using the Apply_Image_Filter function
    function [filtImage] = Guided_Filtering(IMF, inputIm)
      if nargin == 2
        filtImage = IMF.Apply_Image_Filter('Guided_Filtering', inputIm);
      else
        filtImage = IMF.Apply_Image_Filter('Guided_Filtering');
      end
    end

    function [filtImage] = Apply_Wiener(IMF)
      if nargout
        filtImage = IMF.Apply_Image_Filter('Apply_Wiener');
      else
        IMF.Apply_Image_Filter('Apply_Wiener');
      end
    end

    function [filtImage] = Apply_CLAHE(IMF)
      if nargout
        filtImage = IMF.Apply_Image_Filter('Apply_CLAHE');
      else
        IMF.Apply_Image_Filter('Apply_CLAHE');
      end
    end

    function [filtImage] = Adjust_Contrast(IMF)
      if nargout
        filtImage = IMF.Apply_Image_Filter('Adjust_Contrast');
      else
        IMF.Apply_Image_Filter('Adjust_Contrast');
      end
    end

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % set/get methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    % get position vectos, always return as double! ----------------------------
    % suppress the get methods should not acces other prop. warnings...
    %#ok<*MCSUP>
    function x = get.x(IMF)

      if isempty(IMF.filt) && isempty(IMF.x)
        warning('No image or x data given!');
      elseif isempty(IMF.x)
        nX = size(IMF.filt, 2);
        x = 1:nX;
      else
        x = double(IMF.x);
      end

    end

    function y = get.y(IMF)

      if isempty(IMF.filt) && isempty(IMF.y)
        warning('No image or y data given!');
      elseif isempty(IMF.y)
        nY = size(IMF.filt, 1);
        y = 1:nY;
      else
        y = double(IMF.y);
      end

    end

    % calculate step sizes based on x and y vectors ----------------------------
    function dX = get.dX(IMF)

      if isempty(IMF.x)
        short_warn('Need to define x-vector (F.x) before I can calulate the step size!');
      else
        dX = mean(diff(IMF.x));
      end

    end

    function dY = get.dY(IMF)

      if isempty(IMF.y)
        short_warn('Need to define x-vector (F.y) before I can calulate the step size!');
      else
        dY = mean(diff(IMF.y));
      end

    end

    % calculate an avearge xy step size, warn if error large -------------------
    function dR = get.dR(IMF)
      stepSize = mean([IMF.dX, IMF.dY]);
      stepSizeDiff = 100 * abs(IMF.dX - IMF.dY) / stepSize; % [in% compared to avarage step size]
      allowedStepsizeDiff = 3; % [in%]

      if stepSizeDiff > allowedStepsizeDiff
        short_warn('Large difference in step size between x and y!')
      end

      dR = stepSize;
    end

    % calculate an avearge xy step size, warn if error large -------------------
    function set.filt(IMF, filt)
      % set raw image when first defining filt map
      if isempty(IMF.filt)
        IMF.raw = filt;
      end

      IMF.filt = filt;
    end

  end % end of methods definition

  %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end % end of class definition
