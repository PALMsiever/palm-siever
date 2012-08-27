% [minZ maxZ] = getZbounds(handles)
%
%   Given the figure's handles, the function returns the minimum and
%   maximum values for the Z variable.
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function [minZ maxZ] = getZbounds(handles)
data = get(handles.tParameters,'Data');
a = get(handles.tParameters,'RowName');
varsZ = get(handles.pZAxis,'String');
varz=varsZ{get(handles.pZAxis,'Value')};
minZ = data{cellfun(@(x) strcmp(x,varz),a),1};
maxZ = data{cellfun(@(x) strcmp(x,varz),a),2};

