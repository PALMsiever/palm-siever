% This function gets the chosen image size in the resolution box
% 
% Note: this function is quite tied to the GUI, so only change it if you
% know what you're doing.
%
% Author: Thomas Pengo
% GPL-3
function res = getRes(handles);
res = 2^(get(handles.pResolution,'Value')+7); %CAREFUL CHANGING VALS IN CTRL!!!

