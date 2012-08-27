% Sets the Z bounds 
%
%  handles = setBounds(handles, bounds)
%       handles     the handles to the figure
%       bounds      a 4-element vector [minZ maxZ]
%
% Note: you need to use guidata to actually modify the figure's values
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function handles = setZbounds(handles, bounds)
data = get(handles.tParameters,'Data');
a = get(handles.tParameters,'RowName');
varsZ = get(handles.pZAxis,'String');
varz=varsZ{get(handles.pZAxis,'Value')};
data{cellfun(@(x) strcmp(x,varz),a),1} = bounds(1);
data{cellfun(@(x) strcmp(x,varz),a),2} = bounds(2);
set(handles.tParameters,'Data',data);

