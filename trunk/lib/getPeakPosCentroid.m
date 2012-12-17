function [pos amplitude]= getPeakPosCentroid(im, posGuess, windowRadius)
% crop small subimage around each im
% get centroid of each sub image


[windowLim] = getSubWindow(im,posGuess,windowRadius);
xLim  = windowLim(1:2);
yLim  = windowLim(3:4);

subIm = im(yLim(1):yLim(2),xLim(1):xLim(2));

posGuessSubIm = [posGuess(1) - xLim(1), posGuess(2)-yLim(1)];
[posSubIm, amplitude] = getCentroid(subIm);

pos = posSubIm + [xLim(1),yLim(1)]-[1,1];

%hold off;
%imagesc(subIm);
%hold all;
%plot(posGuessSubIm(:,1),posGuessSubIm(:,2),'kx');
%plot(posSubIm(:,1),posSubIm(:,2),'mx');
%pause
%
%hold off;
%imagesc(im);
%hold all;
%plot(posGuess(:,1),posGuess(:,2),'kx');
%plot(pos(:,1),pos(:,2),'gx');
%keyboard

%--------------------------------------------------
function [windowLim posGuessSubIm] = getSubWindow(im,posGuess,windowRadius);

[sizey sizex] = size(im);
X0=posGuess(1);
Y0=posGuess(2);

%round X0, Y0 to use as matrix locations
X0_int = round(X0); 
Y0_int = round(Y0);
windowRadius = round(windowRadius); %radius should already be an integer anyway

% setup the limits of the cropped image
xstart =  X0_int-windowRadius;
xfinish = X0_int+windowRadius;
ystart =  Y0_int-windowRadius;
yfinish = Y0_int+windowRadius;
% check if any of the limits are out of bounds - if so, skip that point
if (xstart<1)
  xstart=1;
end
%if (xstart > sizex)
%if (xfinish<1) 
if (xfinish > sizex)
  xfinish=sizex;
end
if (ystart<1)
  ystart=1; 
end
%if (ystart > sizey)
%if (yfinish<1)
if (yfinish > sizey) 
  yfinish = sizey;
end
windowLim = [xstart, xfinish,ystart,yfinish];
%---------------------------------------------
function [pos, amplitude] = getCentroid(im);

[sizey sizex] = size(im);
totalIntensity = sum(im(:));
posx = sum(sum(im,1).*[1:sizex]) ./ totalIntensity;
posy = sum(sum(im,2).*[1:sizey]') ./ totalIntensity;

pos = [posx,posy];
amplitude = im(round(posy),round(posx));
