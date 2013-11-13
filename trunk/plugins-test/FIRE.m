function FIRE(handles)

X=getX(handles);
Y=getY(handles);
ss=subset(handles);
[minx maxx]= getBounds(handles);
pxx = (maxx-minx)/getRes(handles);

[fire_value, ~, fireH, fireL] = postoresolution([X(ss) Y(ss)], pxx, superzoom); % in super-resolution pixels
logger(sprintf('FIRE value %2.1f +- %2.2f [px]\n', fire_value, (fireL-fireH)/2));
logger(sprintf('FIRE value %2.1f +- %2.2f [nm]\n', fire_value*pixelsize/superzoom, (fireL-fireH)/2*pixelsize/superzoom));
