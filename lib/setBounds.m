% Sets the X,Y bounds 
%
%  handles = setBounds(handles, bounds)
%       handles     the handles to the figure
%       bounds      a 4-element vector [minX maxX minY maxY]
%
% Note: you need to use guidata to actually modify the figure's values
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function handles = setBounds(handles, bounds)
data = get(handles.tParameters,'Data');
a = get(handles.tParameters,'RowName');
data{cellfun(@(x) strcmp(x,handles.settings.varx),a),1} = bounds(1);
data{cellfun(@(x) strcmp(x,handles.settings.varx),a),2} = bounds(2);
data{cellfun(@(x) strcmp(x,handles.settings.vary),a),1} = bounds(3);
data{cellfun(@(x) strcmp(x,handles.settings.vary),a),2} = bounds(4);
%data=updateTable(handles,data)
set(handles.tParameters,'Data',data);

