% Calculate histogram
function [density n m X Y] = calcHistogram(handles)

res = getRes(handles);
X = getX(handles);
Y = getY(handles);

[minX, maxX, minY, maxY] = getBounds(handles);

subset = getSubset(handles);

[density n m X Y] = calcHistogram_(X(subset), Y(subset), res, minX, maxX, minY, maxY);

