% make sure we have all folders and subfolders added to matlab path
scriptPath = mfilename('fullpath');
folderPath = fileparts(scriptPath);
addpath(genpath(folderPath));

% remove git folder if one exists...
if isfolder('.git')
  rmpath('.git');
end

% get default figure background to be white, have decent default fontsize
% as well
set(0,'DefaultAxesFontSize',12);
set(0,'DefaultTextFontSize',12);
set(0,'DefaultLineLinewidth',1.5);
format compact;
set(0,'defaultfigurecolor',[1 1 1]);

% start actual GUI
MasterGui();