% Sets the Frame bounds 
%
%  handles = setFrameBounds(handles, bounds)
%       handles     the handles to the figure
%       bounds      a 2-element vector [minFrame maxFrame]
%
% Note: you need to use guidata to actually modify the figure's values
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function handles = setFramebounds(handles, bounds)
data = get(handles.tParameters,'Data');
a = get(handles.tParameters,'RowName');
varsFrame = get(handles.pFrame,'String');
varFrame=varsFrame{get(handles.pFrame,'Value')};
data{cellfun(@(x) strcmp(x,varFrame),a),1} = bounds(1);
data{cellfun(@(x) strcmp(x,varFrame),a),2} = bounds(2);
set(handles.tParameters,'Data',data);

