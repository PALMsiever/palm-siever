function [drift corAmplitude ] = getStormDrift3(stormData,minImPointPerArea,minFrame,stormPixSize,SccfWindowArea,imSize)
% [drift corAmplitude correctedStormData correctedStormImage  oldStormImage h] = getStormDrift2(stormData,minImPointPerArea,stormPixSize,SccfWindowArea,imSize)
% [drift corAmplitude correctedStormData correctedStormImage  oldStormImage] = getStormDrift(stormData,minImPointPerArea,stormPixSize,SccfWindowArea,imSize)
%    Author: SJ Holden, EPFL
%    Written: 110323
%    Last update: 130801
%    Email: seamus.holden@epfl.ch
%    Copyright (C) 2013, EPFL
%
% PURPOSE:
%  Extract and correct for drift in SR localization data using image cross correlation spectroscopy, (roughly) as per Huang 2008, Science, and using the formalism of Srivastava and Petersen, Methods in cell science, 1996.
%
%  NB: If there are not enough datapoints in each batch of frames used to do the ICCS, the correlation calculation will fail (due to no clear peak in the correlation function), and drift calculations will be unreliable. Therefore, for every drift calculation, inspect the correlation amplitude timetrace to check for large variation "spikes" - this indicates unreliable results. In this case, increase 'minImPointPerArea' until there are enough datapoints to give you significant cross correlation, no "spikes", and reliable results. Around 5 points/um^2 seems to be a good threshold for reliability (corresponding to ~5e-2 points/ pixel for typical pixel size)
%  Further subtleties/potential extensions
%   1) Huang et al advocate calculating drift between start of movie and lots of subsequent points (this is what I have implemented). Amongst other things this creates an overlarge dependence on the start of the movie having decent data; I suspect a better implentation would be to calculate drift between adjacent blocks and to string them all together at the end (although this creates its own problems with error propogation). This would be for "future work" however.
%  Requires the stats toolbox, and optimization toolbox (these dependencies could be quite easily avoided if necessary by some updating of the code)
%
% OUTPUTS
%   drift 
%     [time, xDrift, yDrift]
%     Drift in detected image, for each frame
%   corAmplitude 
%     [time, correlationAmplitude]
%     Correlation amplitude for each ICCS calculation. Large variations in correlation amplitude indicate failure of the 
%   correctedStormData
%     [time, xPos, yPos]
%     Drift corrected SR coordinate list
%   correctedStormImage  
%     Drift corrected SR image (uint16)
%   oldStormImage 
%     Uncorrected SR image (uint16)
%   h
%     Handle to plot of x,y drift and correlation amplitude
%
% INPUTS
% stormData
%  [time, x, y]
% minImPointPerArea
%   A list of localizations are built up from multiple frames until the list is long enough that there are > the threshold point density in the image used for drift correction. 10 points/um^2 works well.
% stormPixSize (optional, default = 0.2)
%   pixel size of storm image (in the units supplied from stormData). 
%   If stormData is in microns, you want ~0.02. If stormData is units of pixels, with ~100nm pix size you want ~0.2.
% SccfWindowArea (optional, default =5)
%   To calculate the drift the SCCF image is cropped to a small region centred around the position of the initial guess for SCCF peak centre (zero). This specifies size of square window; ie cropped image is centre+/-SccfWindowSize. Total length of square therefore 2*SccfWindowSize. SccfWindowArea is in distance units; this is converted to storm image pixel units via conversion
% imSize (optional, default = max and min of all SR coordinates)
%   {[xmin,xmax],[ymin,ymax]}
%   Max and min coordinates for calculation of storm image
%
% EXAMPLE:
%   >> [drift corAmplitude correctedStormData correctedStormImage] = srDriftCorrectBielfeldData2(stormData,1e-1,1,5);

if ~exist('stormPixSize','var')
  stormPixSize= 0.2;
end

if ~exist('imSize','var')
  xmin = min(stormData(:,2));
  xmax = max(stormData(:,2));
  ymin = min(stormData(:,3));
  ymax = max(stormData(:,3));

  xLim = [xmin:stormPixSize:xmax];
  yLim = [ymin:stormPixSize:ymax];
else
  xmin = imSize{1}(1);
  xmax = imSize{1}(2);
  ymin = imSize{2}(1);
  ymax = imSize{2}(2);

  xLim = [xmin:stormPixSize:xmax];
  yLim = [ymin:stormPixSize:ymax];
end

if ~exist('SccfWindowArea','var')
  SccfWindowArea = 5;
end
SccfWindowSize = round(SccfWindowArea/stormPixSize);


%initialise drift mat output
frameList = unique(stormData(:,1));
nFrame= size(frameList,1);
nPoint = size(stormData,1);
pointLeft = nPoint;

drift = NaN.*ones(nFrame,3);
corAmplitude   = NaN.*ones(nFrame,2);
drift(:,1) = frameList;
corAmplitude(:,1) = frameList;

%convert minImPointPerArea to minImPointImage
imArea = (xmax-xmin)*(ymax-ymin);
minImPointImage = imArea*minImPointPerArea;

%initialize impointlist
imPointList = zeros(nPoint,3);
imPointRow = 1;
nImPoint = 0;

isFirstImage=true;
if nPoint > 2*minImPointImage %ie if theres enough to do one image correlation
  %for each frame
  i = 1;
  frameSinceLast =0;
  while i <= nFrame
    currentFrame = frameList(i);
    currentFrameData = stormData(find(stormData(:,1)==currentFrame),:);
    nCurrentPoint = size(currentFrameData,1);
        
    %grow a list of points until theres enough points to generate an image
    imPointList(nImPoint+1: nImPoint+nCurrentPoint,:) = currentFrameData;
    nImPoint = nImPoint + nCurrentPoint;
    pointLeft = pointLeft - nCurrentPoint;
  
    if nImPoint >= minImPointImage  &frameSinceLast>minFrame %once we have enough points, go ahead and form the image

      if pointLeft < minImPointImage %if there are only a few leftover points, add these to the current list as well
         leftOverFrame = frameList(i+1:end);
         leftOverFrameData = stormData(find(ismember(stormData(:,1),leftOverFrame)),:);
         nLeftoverFrame = size(leftOverFrameData,1);
         imPointList(nImPoint+1:nImPoint+nLeftoverFrame,:) = leftOverFrameData;

         nImPoint = nImPoint + nLeftoverFrame;
         pointLeft = pointLeft - nLeftoverFrame;
         i = i + nLeftoverFrame; %ie no more iterations left
      end

      %form the image
      yxData = imPointList(1:nImPoint,[3,2]); %matlabs stupid (i,j) vs (y,x) convention!
      stormIm = hist3([yxData],{yLim, xLim});

      if isFirstImage == true %first image; save it
         im1 = stormIm;
         isFirstImage = false;

         imFrame = unique(imPointList(1:nImPoint,1));
         % OPTIONAL:step function drift correction	
         %matchRow = ismember(drift(:,1),imFrame);
         %drift(matchRow,2)= [driftN(1)];
         %drift(matchRow,3)= [driftN(2)];
         %corAmplitude(matchRow,2)= corAmplitudeN;

         %DEFAULT: interpolated drift correction
         %only assign the midpoint frame so we can interpolate instead of using step functions
         midFrame = nearestpoint(median(imFrame),imFrame);
         matchRow = find(drift(:,1)==midFrame);
         drift(matchRow,2)= [0];
         drift(matchRow,3)= [0];
         corAmplitude(matchRow,2)= Inf;

      else %subsequent images; do iccs on this image with the first image
         imN = stormIm;
         [driftN, corAmplitudeN] = getImDrift(im1,imN,  SccfWindowSize);
         %DONT FORGET we just looked at a nSubPixel upscaled image!! Need to rescale!
         driftN = driftN*stormPixSize;
         % and need to rescale correlation amplitude 
         % correlation amplitute has units of (particles/(subpixel))^-1
         corAmplitudeN = corAmplitudeN/stormPixSize^2;
         
         imFrame = unique(imPointList(1:nImPoint,1));
         % OPTIONAL:step function drift correction	
         %step function drift correction	
         %matchRow = ismember(drift(:,1),imFrame);
         %drift(matchRow,2)= [driftN(1)];
         %drift(matchRow,3)= [driftN(2)];
         %corAmplitude(matchRow,2)= corAmplitudeN;

         %DEFAULT: interpolated drift correction
         %only assign the midpoint frame so we can interpolate instead of using step functions
         midFrame = nearestpoint(median(imFrame),imFrame);
         matchRow = find(drift(:,1)==midFrame);
         drift(matchRow,2)= [driftN(1)];
         drift(matchRow,3)= [driftN(2)];
         corAmplitude(matchRow,2)= corAmplitudeN;
         

      end
      %reset the drift correction image
      nImPoint =0;
      imPointList = imPointList.*0;
      frameSinceLast=0;
    end
    i = i+1;
    frameSinceLast = frameSinceLast+1;
  end

  %apply interpolation between drift corrected data points
  correctedFrameRow = find(~isnan(drift(:,2)));
  %driftX
  t =  [drift(1,1); drift(correctedFrameRow,1);drift(end,1)];
  y =  [0;	    drift(correctedFrameRow,2);drift(correctedFrameRow(end),2)];
  ti = drift(:,1);
  yi = interp1(t,y,ti);
  drift(:,2) = yi;
  %drifty
  t =  [drift(1,1);drift(correctedFrameRow,1);drift(end,1)];
  y =  [0;drift(correctedFrameRow,3);drift(correctedFrameRow(end),3)];
  ti = drift(:,1);
  yi = interp1(t,y,ti);
  drift(:,3) = yi;
  %corAmplitude
  t =  [corAmplitude(1,1);corAmplitude(correctedFrameRow,1);corAmplitude(end,1)];
  y =  [Inf;corAmplitude(correctedFrameRow,2);corAmplitude(correctedFrameRow(end),2)];
  ti = corAmplitude(:,1);
  yi = interp1(t,y,ti);
  corAmplitude(:,2) = yi;

  %apply drift correction to the data
  %[correctedStormData correctedStormImage oldStormImage] = applyDriftCorrection(stormData,xLim,yLim,drift);
  %% show the drift plot
  %h=figure;
  %ax(1)=subplot(2,1,1);
  %plot(drift(:,1),drift(:,2));
  %hold all;
  %plot(drift(:,1),drift(:,3));
  %legend('x drift','y drift');
  %ylabel('drift');
  %ax(2)=subplot(2,1,2);
  %plot(corAmplitude(:,1),corAmplitude(:,2));
  %ylabel('Cross correlation amplitude (unit area)');
  %xlabel('time');
  %linkaxes(ax,'x');
  %%set(ax(1),'Title', text('String',['delta frame =',num2str(deltaFrame)]));
  %axes(ax(1));
  %title(['\rho_{min} =',num2str(minImPointPerArea)]);
else 
  error('Not enough localizations to form at least 2 images!');
end

%--------------------------------------------
function [drift, corAmplitude] = getImDrift(templateIm,featureIm, windowSize)
% spatial cross correlation function = SCCF
if ~exist('windowSize','var')
  windowSize= 10; %seems like a pretty reasonable number
end

%calculate the correlation function
% C is the image of the correlation function. 
%zeroCoord is the [i,j] coordinate corresponding to zero displacement in
% the correlation function 
[C,zeroCoord] = corrfunc(templateIm,featureIm);



% extract the drift by fitting a gaussian to the SCCF
% careful with (i,j) vs (x,y)!!

[corrMaxPos corAmplitude] =   getPeakPosGauss2d(C,zeroCoord,windowSize);
%[corrMaxPos corAmplitude] =   getPeakPosCentroid(C,zeroCoord,windowSize); %this does not seem sufficiently accurate!
drift = zeroCoord  - corrMaxPos;

%OPTIONAL PLOTTING OF THE CORRELATION IMAGES
%global I;
%I=I+1
%subplot(3,1,1)
%imagesc(templateIm);
%subplot(3,1,2)
%imagesc(featureIm);
%subplot(3,1,3)
%imagesc(C);
%pause

%%-------------------------------
%
%-------------------------------------------------------------
%function [G,zeroCoord] = getImDrift(template,feature)
function [G,zeroCoord] = corrfunc(template,feature)
% July 9, 2003
% David Kolin
% 18/03/11
% Seamus Holden
% 1)Minor modification 2011 SH to output zeroCoordinate in ICS image
% 2) 110318 Now a very heavily modified version of original function. Does cross not auto correlation
% NB:template and feature should be same size
% zeroCoord is (x,y) coordinates, not (i,j)!
template=double(template);
feature=double(feature); 

% Calculates 2D correlation functions for each z slice of a given 3D matrix (imgser)
% Output as a 3D matrix with same dimensions as imgser
G = zeros(size(template)); % Preallocates matrix

% Calculates corr func
%autocorrelation:
%%G = (fftshift(real(ifft2(fft2(template).*conj(fft2(template)))))) ...
%%        /(mean(template(:))^2*size(template,1)*size(template,2) ) ...
%%      -1;

%cross correlation
G = (fftshift(real(ifft2(fft2(template).*conj(fft2(feature))))))/...
		( (mean(template(:))*mean(feature(:))) * size(template,1)*size(template,2) ) ...
		- 1;
% SH mod
% make sure that you know where the zero coordinate is from the DFT
% so that we can calculate absolute drift
imsize = size(template);
zeroCoordX = (floor(imsize(2)/2)+1);
zeroCoordY = (floor(imsize(1)/2)+1);
zeroCoord = [ zeroCoordX,zeroCoordY];

%----------------------------------------------------------------------------------------------
function [correctedStormData correctedStormImage oldStormImage] = applyDriftCorrection(stormData,xLim,yLim,drift);

correctedStormData = stormData;
%apply drift correction
nFrame = size(drift,1);
for i = 1:nFrame
  currentFrame = drift(i,1);
  matchRow = find(correctedStormData(:,1)==currentFrame);

  %applyXcorrection
  correctedStormData(matchRow,2) = correctedStormData(matchRow,2)-drift(i,2);
  %applyYcorrection
  correctedStormData(matchRow,3) = correctedStormData(matchRow,3)-drift(i,3);
end

%calculate old storm image
yxData = stormData(:,[3,2]); %matlabs stupid (i,j) vs (y,x) convention!
oldStormImage= cast(hist3([yxData],{yLim, xLim}),'uint16');
%imwrite(oldStormImage,'test1.tif','tif','Compression','none');

%calculate new storm image
yxData = correctedStormData(:,[3,2]); %matlabs stupid (i,j) vs (y,x) convention!
correctedStormImage= cast(hist3([yxData],{yLim, xLim}),'uint16');
%imwrite(correctedStormImage,'test2.tif','tif','Compression','none');
%-------------------------------------------------------------------------------------------
function [value, idx]= nearestpoint(x,A);
%find the nearest index and value to x in A 
tmp = abs(A-x);
[dum idx] = min(tmp); %index of nearest point
value = A(idx);

