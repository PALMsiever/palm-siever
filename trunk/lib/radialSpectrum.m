% Calculate radial spectrum
function [ PR PRx ] = radialSpectrum(X1,Y1,pxSize,imSize)
% Sampling frequency
fs = 1/pxSize; %imSize/14/s; 

% Real space
xs = linspace(-imSize/2,imSize/2,imSize)*pxSize;

% Frequency space
Fs = linspace(-fs/2,fs/2,imSize);

% Image (Histogram)
I = hist3([X1 Y1],'Edges',{xs,xs});
%I = imfilter(I,fspecial('gaussian',ceil(3*lp/pxSize),lp));
%I = I/sum(I(:)); % It's a probability distribution

[FX FY]=meshgrid(Fs,Fs);

% Radial frequency
FR = sqrt(FX.^2 + FY.^2); % For each pixel
maxFR = max(FX(:)); %max(FR(:)); %fs/2*1.5;
% Binning
nbins = imSize/2
FRi = ceil(FR(:)/maxFR*nbins+eps); % Binned index
FRq = (FRi)/nbins*maxFR; % Bin location

% Based on PS
P = abs(fftshift(fft2(I))).^2;
PR = accumarray(FRi,P(:))./accumarray(FRi,1); % Average PS per radial bin
PRv = accumarray(FRi,P(:).^2)./accumarray(FRi,1)-PR.^2; % Var PS per radial bin
PRx = accumarray(FRi,FRq)./accumarray(FRi,1); % Average Fx per radial bin
