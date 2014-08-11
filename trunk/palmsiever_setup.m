% SETUP SCRIPT FOR PALM-siever
% ============================
% Author:   Thomas Pengo
% Web:      http://code.google.com/p/palm-siever
% Licence:  GPL-v.3

usediplib = ~isdeployed;

% Find out where we are
palm_siever = fileparts(which('palmsiever_setup'));

if usediplib && ~isdeployed
  % Initialize Dipimage
  diplib_directory = 'C:\Program Files\DIPimage 2.4.1'; % Change me if necess.
  addpath(diplib_directory); 
end

if usediplib
    dipstart
end

setappdata(0,'usediplib',usediplib)


% Setup path
if ~isdeployed
    addpath(palm_siever)
    addpath(fullfile(palm_siever,'lib'))
end

javaaddpath(fullfile(palm_siever,'lib','utils.jar'))
javaaddpath(fullfile(palm_siever,'lib'))

setappdata(0,'usediblib',usediplib)

setappdata(0,'ps_initialized',true)

