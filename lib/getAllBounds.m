%get the bounds for all variables 
function [bounds rowName]= getAllBounds(handles)

rowName = get(handles.tParameters,'RowName');
data = get(handles.tParameters,'Data');
bounds = data(:,1:2);

