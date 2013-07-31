function FIRE(handles)

X=getX(handles);
Y=getY(handles);
ss=getSubset(handles);
res = getRes(handles);

r = inputdlg('Original image size (pixels) ');
imgSize = str2double(r{1});

[fire_value, ~, fireH, fireL] = postoresolution([X(ss) Y(ss)],res,res/imgSize);
logger(sprintf('FIRE value %2.1f +- %2.2f [px]\n', fire_value, (fireL-fireH)/2));

