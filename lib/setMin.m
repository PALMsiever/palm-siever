% Set minimum for a specified variable
function setMin(handles, variable, minimum)

data = get(handles.tParameters,'Data');
a = get(handles.tParameters,'RowName');
data{cellfun(@(x) strcmp(x,variable),a),1} = minimum;
set(handles.tParameters,'Data',data);

