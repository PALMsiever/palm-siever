function plot3D(handles)

X = getX(handles); 
Y = getY(handles);
Z = getZ(handles);
subset = getSubset(handles);

figure; plot3(X(subset), Y(subset), Z(subset), '.')
