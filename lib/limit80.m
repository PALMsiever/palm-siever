% Limits to central 80% of the data
function limit80(handles, variable)

v = fetch(variable);

m = quantile(v,.1);
M = quantile(v,.9);

setMin(handles, variable, m);
setMax(handles, variable, M);

