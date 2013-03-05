% Calculate histogram
function [density n m X Y] = calcHistogram(handles)

res = getRes(handles);
XPosition = getX(handles);
YPosition = getY(handles);

[minX, maxX, minY, maxY] = getBounds(handles);

subset = getSubset(handles);
NP = sum(subset);

n=linspace(minX,maxX,res); m=linspace(minY,maxY,res);

if NP>0
    RR = round((res-1)*[...
        (XPosition(subset)-minX)/(maxX-minX) ...
        (YPosition(subset)-minY)/(maxY-minY) ])+1;
    RRok = all(RR<=res,2) & all(RR>=1,2) ;
    pxx=(maxX-minX)/res; pxy=(maxY-minY)/res;
    pxArea=pxx * pxy;
    density = accumarray(RR(RRok,:),1,[res,res])/pxArea;
    X = repmat(n,res,1); Y = repmat(m',1,res);
else
    density = zeros(res+1);
    X = repmat(n,res+1,1); Y = repmat(m',1,res+1);
end
