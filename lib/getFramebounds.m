% [minFrame maxFrame] = getFramebounds(handles)
%
%   Given the figure's handles, the function returns the minimum and
%   maximum values for the Frame variable.
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function [minFrame maxFrame] = getFramebounds(handles)
data = get(handles.tParameters,'Data');
a = get(handles.tParameters,'RowName');
varsFrame = get(handles.pFrame,'String');
varF=varsFrame{get(handles.pFrame,'Value')};
minFrame = data{cellfun(@(x) strcmp(x,varF),a),1};
maxFrame = data{cellfun(@(x) strcmp(x,varF),a),2};

