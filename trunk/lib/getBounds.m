function [minX, maxX, minY, maxY] = getBounds(handles)
% [minX maxX minY maxY] = getBounds(handles)
%
%   Given the figure's handles, the function returns the minimum and
%   maximum values for the X and Y variables.
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
data = get(handles.tParameters,'Data');
a = get(handles.tParameters,'RowName');
minX = data{cellfun(@(x) strcmp(x,handles.settings.varx),a),1};
maxX = data{cellfun(@(x) strcmp(x,handles.settings.varx),a),2};
minY = data{cellfun(@(x) strcmp(x,handles.settings.vary),a),1};
maxY = data{cellfun(@(x) strcmp(x,handles.settings.vary),a),2};

