% Creates a new 3D scatterplot of the data 
function plot3D(handles)

X = getX(handles); 
Y = getY(handles);
Z = getZ(handles);
subset = getSubset(handles);

h1 = figure; plot3(X(subset), Y(subset), Z(subset), '.');
set(0,'CurrentFigure',h1);
axis equal;
