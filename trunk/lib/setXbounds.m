% Sets the X bounds 
%
%  handles = setXBounds(handles, bounds)
%       handles     the handles to the figure
%       bounds      a 2-element vector [minX maxX]
%
% Note: you need to use guidata to actually modify the figure's values
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function handles = setXbounds(handles, bounds)
data = get(handles.tParameters,'Data');
a = get(handles.tParameters,'RowName');
varsX = get(handles.pXAxis,'String');
varx=varsX{get(handles.pXAxis,'Value')};
data{cellfun(@(x) strcmp(x,varx),a),1} = bounds(1);
data{cellfun(@(x) strcmp(x,varx),a),2} = bounds(2);
set(handles.tParameters,'Data',data);
guidata(handles.output, handles);

