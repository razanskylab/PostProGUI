% Class to perform frangi filtering, returns scales and combined frangi filtered
% images, can also generate overlay maskes of frangi scales.

classdef Frangi_Filter < handle
  properties
    x; y; % plot vectors with units (mm)
    raw; % original xy map, as first input to Maps structure
    filt; % store frangi filtered images seperate
    filtScales; % store seperate frangi scales

    % frangi filtering options
    startScale = 2;
    stopScale = 10;
    nScales = 9;
    % sensitivity used for matlab filtering
    sensitivity = 0.05; 
    % betaOne and Two used for older filtering
    betaOne = 2; % seems to have little impact for fixed betaTwo
    betaTwo = 0.11; % smaller values = more "vessels"
    showScales = false;
    invert = false;

    % output control
    verboseOutput = 0;
    showHisto = 0; % default don't show histo for xy-plots
    colorMap = 'gray'; % use for simple plotting
  end

  properties (SetAccess = private)
    % step sizes, calculated automatically from x,y,z using get methods, can't be set!
    dX; dY;
    dR; % average x-y pixels size
    allScales;
    allEffectiveScales;
  end

  properties (Hidden = true)
    % used only for CLAHE when showing frangi scales
    claheDistr  = 'exponential'; % 'uniform' 'rayleigh' 'exponential' Desired histogram shape
    claheNBins  = 256; % histogram bins used for contrast enhancing transformation
    claheLim    = 0.02; % enhancement limit, [0, 1], higher limits result in more contrast
    claheNTiles = [32 32]; % image divided into M x N tiles, 'NumTiles' = [M N]
  end

  events
    FiltUpdated; % used to update Maps class
  end


  % Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    % class constructor - needs to be in here!
    % note that if first input arg when creating new instance of class is a
    % Maps object then we will create a deep copy of the data, this is neccesary
    % because a simple copy of a handle object only creates a shallow copy
    % and if we don't make it a handle class then things lile F.Norm don't work
    % and we would have to write M = F.Norm which makes things messy again...
    function newFrangi = Frangi_Filter(varargin)
      className = class(newFrangi);
      if nargin
        if isa(varargin{1},className)
          % Construct a new object based on a deep copy of an old object
          oldMap = varargin{1}; % copy data from this "old" Map
          props = properties(oldMap); % get all properties
          % turn off warnigs during deep copy to ignore methods
          % that compalain that there is no data when queried later...
          preWarnSettings = warning();
          warning('off')
          for i = 1:length(props)
            newFrangi.(props{i}) = oldMap.(props{i});
          end
          warning(preWarnSettings);
        elseif isa(varargin{1},'Maps') % construct from Maps class
          mapClass = varargin{1};
          newFrangi.x = mapClass.x;
          newFrangi.y = mapClass.y;
          newFrangi.filt = mapClass.xy;
          newFrangi.verboseOutput = mapClass.verboseOutput;
        elseif isnumeric(varargin{1}) % 2d array
          % calculate raw MIPs directly from 3d dataset
          newFrangi.filt = varargin{1};
          % assign vectors as well if provided
          if nargin == 3
            newFrangi.x = varargin{2};
            newFrangi.y = varargin{3};
          end
        end
      end
    end

    function saveFrangi = saveobj(F)
      % don't save empty objects...
      if isempty(F.filt)
        saveFrangi = [];
      else
        saveFrangi = F;
      end
    end

    % convenience function for plotting
    function P(M,varargin)
      M.Plot(varargin{:});
    end
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % XY and related set/get functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods

    % get position vectos, always return as double! ----------------------------
    function x = get.x(F)
      %Note: type conversion is very very fast in Matlab, especially if the
      % type of the variable is already correct (i.e. single(singleVar))
      % takes basically NO time and it takes longer to check first using isa
      if isempty(F.filt) && isempty(F.x)
        warning('No image or x data given!');
      elseif isempty(F.x)
        nX = size(F.filt,2);
        x = 1:nX;
      else
        x = double(F.x);
      end
    end

    function y = get.y(F)
      %Note: type conversion is very very fast in Matlab, especially if the
      % type of the variable is already correct (i.e. single(singleVar))
      % takes basically NO time and it takes longer to check first using isa
      if isempty(F.filt) && isempty(F.y)
        warning('No image or x data given!');
      elseif isempty(F.y)
        nY = size(F.filt,1);
        y = 1:nY;
      else
        y = double(F.y);
      end
    end

    % calculate step sizes based on x and y vectors ----------------------------
    function dX = get.dX(F)
      if isempty(F.x)
        short_warn('Need to define x-vector (F.x) before I can calulate the step size!');
      else
        dX = mean(diff(F.x));
      end
    end

    function dY = get.dY(F)
      if isempty(F.x)
        short_warn('Need to define x-vector (F.y) before I can calulate the step size!');
      else
        dY = mean(diff(F.y));
      end
    end

    % calculate an avearge xy step size, warn if error large -------------------
    function dR = get.dR(F)
        stepSize = mean([F.dX,F.dY]);
        stepSizeDiff = 100*abs(F.dX-F.dY)/stepSize; % [in % compared to avarage step size]
        allowedStepsizeDiff = 10; % [in %]
        if stepSizeDiff > allowedStepsizeDiff
          fprintf('\n'); % close line
          warnMessage = sprintf(...
            'Large difference in step size between x (%2.1fum) and y (%2.1fum)!',...
            F.dX*1e3,F.dY*1e3);
          short_warn(warnMessage);
        end
        dR = stepSize;
    end

    % get all scales (these are transformed into effective scales below)
    function allScales = get.allScales(F)
      allScales =  linspace(F.startScale, F.stopScale, F.nScales);
    end
    % effective scales are scales scaled by the pixel density and then some...
    function allEffectiveScales = get.allEffectiveScales(F)
      pixelDensity = 1/F.dR*1e3;
      allEffectiveScales = F.allScales.*pixelDensity*1e-5;
    end

    function set.filt(F,map)
      % set raw map on first asginement of xy map
      if isempty(F.filt) && isempty(F.raw)
        F.raw = map;
      end
      F.filt = map;
    end
  end % end of methods definition
  %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  methods(Static)

  end % end of methods(Static)

end % end of class definition
