% AVA Class - Autoamtic Vessel Analysis

classdef Vessel_Analysis < handle
  properties (Constant = true)
  end

  % normal properties (not private, not hidden etc) ----------------------------
  properties
    verbosePlotting = 0;
    verboseOutput = 0;
    C = Colors();

    xy;% maps to be stored and plotted / calculated
    x; y; z; % plot vectors with units (mm)
    area;

    bin; % store binarized image

    % Binarization Options  ----------------------------------------------------
    binWhat = 0; % Which image should I use as basis for binarization?
    %                 0 - Frangi filtered image
    %                 1 - based on AVA.xy
    %                 2 - signal map

    % Vessel statisitics Options
    AviaSettings =  Vessel_Analysis.Get_Default_Avia_Settings;
    Stats; % stats calculates using Get_Vessel_Stats()
    Data; % stats calculates using Get_Vessel_Stats()

    % plotting options ---------------------------------------------------------
    newFigPlotting = 1; % default open all plots in new figure
    useUnits = true; % plot using units not index if possbile
    noAxis = true;
    noColorBar = true;
    colorMap = 'gray';
  end

  properties (SetAccess = private)
    % step sizes, calculated automatically from x,y,z using get methods, can't be set!
    dX; dY;
    dR; % average x-y pixels size
  end


  % Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    % class constructor - needs to be in here!
    function newAva = Vessel_Analysis(varargin)
      className = class(newAva);
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
            newAva.(props{i}) = oldMap.(props{i});
          end
          warning(preWarnSettings);
        elseif isa(varargin{1},'Maps') % construct from Maps class info
          MapsClass = varargin{1};
          newAva.x = MapsClass.x;
          newAva.y = MapsClass.y;
          newAva.xy = MapsClass.xy;
          newAva.verboseOutput = MapsClass.verboseOutput;
        elseif isnumeric(varargin{1}) % 2d array
          newAva.xy = varargin{1};
          % assign vectors as well if provided
          if nargin == 3
            newAva.x = varargin{2};
            newAva.y = varargin{3};
          end
        end
      end
    end

    function saveAVA = saveobj(AVA)
      % don't save empty objects...
      if isempty(AVA.xy)
        saveAVA = [];
      else
        saveAVA = AVA;
      end
    end

  end



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % small/short methods not worth putting in extra file %%%%%%%%%%%%%%%%%%%%%%%%
  methods
    function [AVA] = Full_Analysis(AVA)
      AVA.Get_Data;
      AVA.Get_Stats;
      if AVA.verbosePlotting
        % plot different important things
        AVA.Plot_Aova_Result();
      end
    end
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % XY and related set/get functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    % get position vectos, always return as double! ----------------------------
    function x = get.x(AVA)
      %Note: type conversion is very very fast in Matlab, especially if the
      % type of the variable is already correct (i.e. single(singleVar))
      % takes basically NO time and it takes longer to check first using isa
      if isempty(AVA.xy) && isempty(AVA.x)
        warning('No image or x data given!');
      elseif isempty(AVA.x)
        nX = size(AVA.xy,2);
        x = 1:nX;
      else
        x = double(AVA.x);
      end
    end

    function y = get.y(AVA)
      %Note: type conversion is very very fast in Matlab, especially if the
      % type of the variable is already correct (i.e. single(singleVar))
      % takes basically NO time and it takes longer to check first using isa
      if isempty(AVA.xy) && isempty(AVA.y)
        warning('No image or x data given!');
      elseif isempty(AVA.y)
        nY = size(AVA.xy,1);
        y = 1:nY;
      else
        y = double(AVA.y);
      end
    end

    % calculate step sizes based on x and y vectors ----------------------------
    function dX = get.dX(AVA)
      if isempty(AVA.x)
        short_warn('Need to define x-vector (AVA.x) before I can calulate the step size!');
      else
        dX = mean(diff(AVA.x));
      end
    end

    function dY = get.dY(AVA)
      if isempty(AVA.x)
        short_warn('Need to define x-vector (AVA.y) before I can calulate the step size!');
      else
        dY = mean(diff(AVA.y));
      end
    end

    % calculate an avearge xy step size, warn if error large -------------------
    function dR = get.dR(AVA)
        stepSize = mean([AVA.dX,AVA.dY]);
        stepSizeDiff = 100*abs(AVA.dX-AVA.dY)/stepSize; % [in % compared to avarage step size]
        allowedStepsizeDiff = 3; % [in %]
        if stepSizeDiff > allowedStepsizeDiff
          short_warn('Large difference in step size between x and y!')
        end
        dR = stepSize;
    end

    % get area of Map, it's fairly simple map ----------------------------------
    function area = get.area(M)
      %Note: see above
      lengthX = max(M.x) - min(M.x);
      legnthY = max(M.y) - min(M.y);
      area = lengthX*legnthY;
    end


  end % end of methods definition

  methods (Static)
    DefaultAviaSettings = Get_Default_Avia_Settings();
  end % end of static methods definition
  %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end % end of class definition
