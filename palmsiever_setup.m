% SETUP SCRIPT FOR PALM-siever
% ============================
% Author:   Thomas Pengo
% Web:      http://code.google.com/palm-siever
%

% Find out where we are
palm_siever = fileparts(which('palmsiever_setup'));

% Initialize Dipimage
diplib_directory = 'C:\Program Files\Dipimage 2.3'; % Change me if necess.
addpath(diplib_directory); dipstart

% Setup path
addpath(palm_siever)
addpath(fullfile(palm_siever,'lib'))
javaaddpath(fullfile(palm_siever,'lib','utils.jar'))
javaaddpath(fullfile(palm_siever,'lib'))

