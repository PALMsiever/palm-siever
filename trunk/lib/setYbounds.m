% Sets the Y bounds 
%
%  handles = setYBounds(handles, bounds)
%       handles     the handles to the figure
%       bounds      a 2-element vector [minY maxY]
%
% Note: you need to use guidata to actually modify the figure's values
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function handles = setYbounds(handles, bounds)
data = get(handles.tParameters,'Data');
a = get(handles.tParameters,'RowName');
varsY = get(handles.pYAxis,'String');
vary=varsY{get(handles.pYAxis,'Value')};
data{cellfun(@(x) strcmp(x,vary),a),1} = bounds(1);
data{cellfun(@(x) strcmp(x,vary),a),2} = bounds(2);
set(handles.tParameters,'Data',data);
guidata(handles.output, handles);

