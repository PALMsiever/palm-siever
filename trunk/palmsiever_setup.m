% SETUP SCRIPT FOR PALM-siever
% ============================
% Author:   Thomas Pengo
% Web:      http://code.google.com/p/palm-siever
% Licence:  GPL-v.3

usediplib = false;

% Find out where we are
palm_siever = fileparts(which('palmsiever_setup'));

if usediplib
  % Initialize Dipimage
  diplib_directory = 'C:\Program Files\Dipimage 2.3'; % Change me if necess.
  addpath(diplib_directory); dipstart
end

setappdata(0,'usediplib',usediplib)


% Setup path
addpath(palm_siever)
addpath(fullfile(palm_siever,'lib'))
javaaddpath(fullfile(palm_siever,'lib','utils.jar'))
javaaddpath(fullfile(palm_siever,'lib'))

setappdata(0,'usediblib',false)

