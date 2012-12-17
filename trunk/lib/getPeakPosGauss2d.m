function [pos amplitude]= getPeakPosGauss2d(im, zeroCoord,  windowSize)
% extract the  centre of the correlation funtion peak by fitting a gaussian to SCCF
% careful with (i,j) vs (x,y)!!

% initial estimate for position of im maximum is zero drift
posGuess = zeroCoord;

% setup some limits
posThresh = NaN; %limits turned off in freePosEllipseGaussFit_matlab
initguess = []; %no initial guess (ie freeGaussFitEllipse to calculate it
sigmaLim = [NaN NaN];% limits turned off in freePosEllipseGaussFit_matlab

%do the fit
% a: (A, sigma_x, sigma_y, b, Xo, Yo, theta )
[phot_count, a, normChi2, pos, eccentricity] = freeGaussFitEllipse( im, posGuess, windowSize,posThresh, sigmaLim, initguess);
amplitude = a(1);

%-------------------------------------------------------------------------------------------
function [phot_count a normChi2 pos eccentricity ] = freeGaussFitEllipse( im, point_pos, windowSize,posLim, sigmaLim, initguess,varargin)
% function [phot_count pos normChi2 eccentricity a ] = freeGaussFitEllipse( im, point_pos, windowSize,posLim, sigmaLim, initguess)
% fit single 2d gaussian with fixed x, y position. wrapper to gauss fit tools function gaussfit_free_elliptical.cpp
%
% Inputs: 
%   im - fit image should be of type double
%   point_pos - initial estimate of position
%   windowSize  - size of subimage to crop 
%   posLim    - radius to allow shift from initial fit position
%   sigmaLim - [minwidth maxwidth]  - fit limits of psf width
%   initguess - [amplitude widthguess background X_POSim Y_POSim ];
% Outputs:
%   phot_count - volume of psf
%   a -  fit parameters, ie  [A, sigma_x, sigma_y, b, X, Y, theta ];
%    sigma_y is always the width along the major axis and theta is angle from y axis to the major axis
%
% NB ONLY ALLOWS SQUARE SUBIMAGES OTHERWISE RETURN 0
%
% Elliptical gaussian from cpp function:
%    xprime = (X-Xo)*cos(theta) - (Y-Yo)*sin(theta);
%    yprime = (X-Xo)*sin(theta) + (Y-Yo)*cos(theta);
%    e = exp((-(pow(xprime/xdenom,2)))-(pow(yprime/ydenom,2)));
%
%    x[element] = (A * e) + b;
% 
% Twotone TIRF-FRET image analysis software.
% Version 3.1.0 Alpha, released 101115
% Authors: Seamus J Holden, Stephan Uphoff
% Email: s.holden1@physics.ox.ac.uk
% Copyright (C) 2010, Isis Innovation Limited.
% All rights reserved.
% TwoTone is released under an “academic use only” license; for details please see the accompanying ‘TWOTONE_LICENSE.doc’. Usage of the software requires acceptance of this license
%
n = numel(varargin);
i = 1;
%defaults:
useCPPfit = false;
useAutoDetTol = false;
while i <= n
  if strcmp(varargin{i},'autoDetect')
    useAutoDetTol = true;
    i = i+1;
  elseif strcmp(varargin{i},'useMatlabFit')
    useCPPfit = false;
    i = i+1;
  else
    error('Unrecognised argument');
  end
end

if useAutoDetTol == false
  % default convergence tolerances
  verbose = false;
  epsilon1 =  10^-7; %gradient on lsq -
  epsilon2 =  10^-9; %gradient on fitParam - the most important
  epsilon3 = 0;  %absoluteValueLSQ - problem dependent - usually ~10^3 - NEVER USE IT!
  maxIter  = 100; %how fast it is in the absence of signal
else
  % for autodetection, convergence tolerances can be reduced (sub nanometre localization not required ofr accurate photon count
  % default convergence tolerances
  verbose = false;
  epsilon1 =  10^-2; %gradient on lsq -
  epsilon2 =  10^-2; %gradient on fitParam - the most important
  epsilon3 = 0;  %absoluteValueLSQ - problem dependent - usually ~10^3 - NEVER USE IT!
  maxIter  = 20; %how fast it is in the absence of signal
end

[sizey sizex] = size(im);
X0=point_pos(1);
Y0=point_pos(2);

%round X0, Y0 to use as matrix locations
X0_int = round(X0); 
Y0_int = round(Y0);
windowSize = round(windowSize); %radius should already be an integer anyway

% setup the limits of the cropped image
xstart =  max(1,X0_int-windowSize);
xfinish = min(sizex,X0_int+windowSize);
ystart =  max(1,Y0_int-windowSize);
yfinish = min(sizey,Y0_int+windowSize);

%crop to a small area around the point
fitIm = im( ystart:yfinish, xstart:xfinish);
[sizeyFit sizexFit] = size(fitIm);
% set up the point location in the cropped image coords
X_POSim = X0-xstart+1;
Y_POSim = Y0-ystart+1;

%set up the XY Lims
xLim = [(X_POSim - posLim) (X_POSim + posLim)];
yLim = [(Y_POSim - posLim) (Y_POSim + posLim)];
minwidth = sigmaLim(1);
maxwidth = sigmaLim(2);
%if an intial guess is not supplied, calculate it
if all(initguess==0)
  background = min(fitIm(:));
  amplitude = max(fitIm(:));
  widthguess = widthEstimate(fitIm)/2;
  if widthguess < minwidth
    widthguess = minwidth;
  elseif widthguess > maxwidth
    widthguess = maxwidth;
  end
    
  initguess = [amplitude widthguess background X_POSim Y_POSim ];
end
%do the fit 
curvefitoptions = optimset( 'lsqcurvefit');
curvefitoptions = optimset( curvefitoptions,'Jacobian' ,'on','Display', 'off',  'TolX', epsilon2, 'TolFun', epsilon1,'MaxPCGIter',1,'MaxIter',maxIter);
[a, normChi2] =freePosEllipseGaussFit_matlab(fitIm,initguess ,xLim,yLim, sigmaLim,curvefitoptions);

% a: (A, sigma_x, sigma_y, b, Xo, Yo, theta )
I0 = a(1);
stdX = a(2);
stdY = a(3);
BG0 = a(4);
pos = [(a(5)+xstart-1) (a(6)+ystart-1)];
theta = a(7);
eccentricity = sqrt( 1 - (min(stdX,stdY)/max(stdX,stdY) )^2);
phot_count = 2*pi*stdX*stdY*I0;

%----------------------------------------------------------------------------------------------
function [fitParam, normChi2] = freePosEllipseGaussFit_matlab(inputIm,initguess ,xLim,yLim, sigmaLim,curvefitoptions);
% fits point spread function, 
% F = (fitParam(1)*exp(    -(xprime).^2/(2*fitParam(2)^2)+(yprime).^2) /(2*fitParam(3)^2)   ) + fitParam(4))
%        
%           xprime = (X-Xo)*cos(theta) - (Y-Yo)*sin(theta);
%           yprime = (X-Xo)*sin(theta) + (Y-Yo)*cos(theta);
%
% extra fit params fitParam(7) = theta, X0 and Y0 are fitParam(5) and (6)
%

A0start = initguess(1);
BGstart = initguess(3);
widthStart = initguess(2);
xStart = initguess(4);
yStart = initguess(5);
xMin = xLim(1);
xMax = xLim(2);
yMin = yLim(1);
yMax = yLim(2);
sigmaMin = sigmaLim(1);
sigmaMax = sigmaLim(2);

%set up the mesh, size of the input image for use in fitting
[sizey sizex] = size(inputIm);
num_pixels = sizey*sizex;
[X,Y]= meshgrid(1:sizex,1:sizey);
grid = [X Y];

AMPSCALEFACTOR =max(inputIm(:))/100;
if AMPSCALEFACTOR <= 0 
  AMPSCALEFACTOR = 1;
end
%rescale the variables - to make magnitude of amplitude, background and width similar
inputIm = inputIm./AMPSCALEFACTOR;

% initguess input is  [amplitude widthguess background X_POSim Y_POSim ]
% initGuess7Vector output is [amplitude sx sy background X_POSim Y_POSim theta]
A0start = A0start./AMPSCALEFACTOR; %amplitude
BGstart = BGstart./AMPSCALEFACTOR; %backgound
if ( (initguess(2) < sigmaMin) || (initguess(2) > sigmaMax))%if given an out of bounds generate a
  initguess(2) = (sigmaMax+sigmaMin)/2; %sensible one- careful this isnt too close to true val tho
end
thetaStart = 0; 
initGuess7Vector = [A0start widthStart widthStart BGstart xStart yStart thetaStart];
% A, sigma_x, sigma_y, b, Xo, Yo, theta 

% Set fit limits on [amplitude widthx widthy background theta]
% dont set limits on theta but convert it to range 0->2pi afterwards
%MODIFIED to get rid of limits for SCCF calculation;110317SH
%lb = [0 sigmaMin sigmaMin 0 xMin yMin -inf];
%ub = [65535 sigmaMax sigmaMax 65535  xMax yMax inf];
lb = [];
ub = [];
%keyboard
%do the fit
try
  [fitParam, res] = ...
    lsqcurvefit(@(x, xdata) gauss2dw(x, xdata), ...
     initGuess7Vector ,grid ,inputIm ,...
      lb,ub,curvefitoptions);    
catch ME
  if strcmp(ME.identifier,'optim:snls:InvalidUserFunction') % supplied absolutely empty image!
    fitParam = [0 0 0 0 0 0 0];
    res = 0;
  else
    rethrow(ME);
  end
end

%MODIFIED FOR SCCF CALCULATION! 110317SH
% modify fitParam to fit with "fitParam" output syntax from twotoneMain 
% fitParam = (A, sigma_x, sigma_y, b, Xo, Yo, theta )
%if fitParam(1)< 0 %We know that negative amplitude values are patently unphysical so ignore them
%  fitParam(1) = 0;
%end

fitParam(1) = fitParam(1).*AMPSCALEFACTOR;%amplitude
fitParam(4) = fitParam(4).*AMPSCALEFACTOR;%background

fitParam(7) = mod(fitParam(7),2*pi);% transform theta onto the interval 0->2*pi
normChi2 = res/num_pixels;     
%-------------------------------------------------------------------------
%---------------------Fitting Subfunctions--------------------------------
%-------------------------------------------------------------------------

function [F J] = gauss2dw(a, data)
% Used by the curve fitter to calculate values for a 2d gaussian
% with the x & y standard deviations equal
% and with fixed positions
% a(1) - A0
% a(2) - sX
% a(3) - sY
% a(4) - B
% a(5) - Xpos
% a(6) - Ypos
% a(7) - theta

%Initialise everything
[sizey sizex] = size(data);
sizex = sizex/2;

F = zeros(sizey, sizex);
X = F;
Y = F;

X = data(:,1:sizex);
Y = data(:,sizex+1:end);

xprime = (X-a(5))*cos(a(7)) - (Y-a(6))*sin(a(7));
yprime = (X-a(5))*sin(a(7)) + (Y-a(6))*cos(a(7));

% Only evaluate the exponential once:
expPart = exp( - ((xprime).^2 /(2*a(2)^2) + (yprime).^2 /(2*a(3)^2) ));

F = a(1)*expPart + a(4);

% compute the jacobian

% initialise everything
n = numel(F);
J = zeros(n,3); % initialise J
Ga1F = zeros(sizey, sizex);% dF/da(1)
Ga2F = Ga1F;% dF/da(2)
Ga3F = Ga1F;% dF/da(3)
Ga4F = Ga1F;% dF/da(4)
Ga5F = Ga1F;% dF/da(7)

% Calculate the grad_a1(F),  grad_a2(F), etc

Ga1F = expPart;

Ga2F = a(1).* expPart .*xprime.^2 .*a(2).^-3;% (A * e) * (pow(xprime,2) * pow(sigma_x,-3)); //dF/dsigma_x
Ga3F = a(1).* expPart .*yprime.^2 .*a(3).^-3;% (A * e) * (pow(yprime,2) * pow(sigma_y,-3)); //dF/dsigma_y

Ga4F = ones(size(X));
%dF/dX0 and dF/dY0 in cpp notation
%   jac[j++] = (A * e) * ( (xprime*cos(theta)*pow(sigma_x,-2)) + (yprime*sin(theta)*pow(sigma_y,-2)) ); //dF/dXo
%           jac[j++] = (A * e) * ( (yprime*cos(theta)*pow(sigma_y,-2)) - (xprime*sin(theta)*pow(sigma_x,-2)) ); //dF/dYo
Ga5F = a(1).* expPart .* ...
      (  xprime.*a(2).^(-2).*cos(a(7)) + yprime.*a(3).^(-2)*sin(a(7)) );
Ga6F = a(1).* expPart .* ...
      ( -xprime.*a(2).^(-2).*sin(a(7)) + yprime.*a(3).^(-2)*cos(a(7)) );

%dF/da(7) in c++ notation:
% (-A * e) *( (-xprime * pow(sigma_x,-2)) * ((X-Xo)*sin(theta) + (Y-Yo)*cos(theta)) + (yprime*pow(sigma_y,-2))*((X-Xo)*cos(theta) - (Y-Yo)*sin(theta)) );
Ga7F = -a(1).* expPart.* ...
      (  (-xprime).*a(2).^(-2).*((X-a(5))*sin(a(7))+ (Y-a(6))*cos(a(7))) ... 
        + (yprime).*a(3).^(-2).*((X-a(5))*cos(a(7))- (Y-a(6))*sin(a(7))) );

% Form the jacobian, see the printed notes on getGaussFit for derivation
J = [Ga1F(:) Ga2F(:) Ga3F(:) Ga4F(:) Ga5F(:) Ga6F(:) Ga7F(:)];

%----------------------------------------------------------------------------------------------
function widthEst = widthEstimate(m)
%function to better estimate width for initial guess
[sizey sizex] = size(m);
vx = sum(m);
vy = sum(m');

vx = vx.*(vx>0);
vy = vy.*(vy>0);

x = [1:sizex];
y = [1:sizey];

cx = sum(vx.*x)/sum(vx);
cy = sum(vy.*y)/sum(vy);

sx = sqrt(sum(vx.*(abs(x-cx).^2))/sum(vx));
sy = sqrt(sum(vy.*(abs(y-cy).^2))/sum(vy));

widthEst = 0.5*(sx + sy) ;

