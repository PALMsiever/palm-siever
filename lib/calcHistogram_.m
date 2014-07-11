% Calculates the histogram from the two vectors, within the specified bounds and with 'res' number of bins.
function [density n m X Y] = calcHistogram_(XPosition, YPosition, res, minX, maxX, minY, maxY)
% [density n m X Y] = calcHistogram_(XPosition, YPosition, res, minX, maxX, minY, maxY)
%  or
% [density n m X Y] = calcHistogram_(XPosition, YPosition, pxSize)

if nargin == 3 % X,Y,res Note: res means pixel size
    rangeX = max(XPosition)-min(XPosition); cX = .5*(max(XPosition)+min(XPosition));
    rangeY = max(YPosition)-min(YPosition); cY = .5*(max(YPosition)+min(YPosition));
    
    if rangeY>rangeX
        N = ceil(rangeY/res/2)*2;
    else
        N = ceil(rangeX/res/2)*2;
    end
    
    dr = N/2 * res;
    
    minX = cX - dr; maxX = cX + dr;
    minY = cY - dr; maxY = cY + dr;

    n=linspace(minX,maxX,N); m=linspace(minY,maxY,N);
    res=N;
elseif nargin==7 % bounds specified Note: res means N pixels
    n=linspace(minX,maxX,res); m=linspace(minY,maxY,res);
else
    error Specify either 3 or 7 arguments
end

if ~isempty(XPosition)
    RR = round((res-1)*[...
        (XPosition-minX)/(maxX-minX) ...
        (YPosition-minY)/(maxY-minY) ])+1;
    RRok = all(RR<=res,2) & all(RR>=1,2) ;
    pxx=(maxX-minX)/res; pxy=(maxY-minY)/res;
    pxArea=pxx * pxy;
    density = accumarray(RR(RRok,:),1,[res,res])/pxArea;
    X = repmat(n,res,1); Y = repmat(m',1,res);
else
    density = zeros(res+1);
    X = repmat(n,res+1,1); Y = repmat(m',1,res+1);
end
