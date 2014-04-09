function [ frcprofile linx ] = calcFIREh(handles, nTrials)
X = getX(handles); Y = getY(handles);
ss0=getSubset(handles); res = getRes(handles);
[minX maxX minY maxY] = getBounds(handles);
[ frcprofile linx ] = calcFIRE(X(ss0), Y(ss0), res, minX, maxX, minY, maxY, nTrials);
