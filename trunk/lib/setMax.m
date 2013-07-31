% Set maximum for a specified variable
function setMax(handles, variable, maximum)

data = get(handles.tParameters,'Data');
a = get(handles.tParameters,'RowName');
data{cellfun(@(x) strcmp(x,variable),a),2} = maximum;
set(handles.tParameters,'Data',data);

