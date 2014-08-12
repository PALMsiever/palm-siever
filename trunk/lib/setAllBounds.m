%set the bounds for all variables 
function setAllBounds(handles,bounds)
data = get(handles.tParameters,'Data');
data(:,1:2)=bounds;
set(handles.tParameters,'Data',data);
