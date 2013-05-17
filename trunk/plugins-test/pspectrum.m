% Power spectrum of the current rendering
function pspectrum(handles)

X = getX(handles); 
Y = getY(handles); 
subset = getSubset(handles);
X = X(subset); 
Y = Y(subset); 

[minX maxX minY maxY] = getBounds(handles);

X = X-(maxX+minX)/2;
Y = Y-(maxY+minY)/2;

n = getRes(handles);

if maxX-minX > maxY-minY
    pxSize = (maxX-minX)/n;
    maxY = (maxY+minY)/2 + pxSize * n/2;
    minY = (maxY+minY)/2 - pxSize * n/2;
else
    pxSize = (maxY-minY)/n;
    maxX = (maxX+minX)/2 + pxSize * n/2;
    minX = (maxX+minX)/2 - pxSize * n/2;
end

[ PR PRx ] = radialSpectrum(X,Y,pxSize,n);
[ nPR nPRx ] = radialSpectrum(...
    (rand(size(X))-.5)*(maxX-minX),...
    (rand(size(Y))-.5)*(maxY-minY),pxSize,n);

figure; 

subplot(2,2,1); loglog(PRx, PR); hold; loglog(nPRx, nPR, 'g');
title('Radial power spectrum');
xlabel('Frequency [units^{-1}]');
ylabel('Power');
legend('Signal','Uniform noise')
grid on
grid minor
axis tight

subplot(2,2,2); loglog(PRx,PR./nPR,'r');
title('Signal to noise ratio');
xlabel('Frequency [units^{-1}]');
ylabel('SNR');
grid on
grid minor
axis tight

subplot(2,2,3); loglog(1./PRx, PR); hold; loglog(1./nPRx, nPR, 'g');
title('Radial power spectrum');
xlabel('1/Frequency [units]');
ylabel('Power');
legend('Signal','Uniform noise')
grid on
grid minor
axis tight

subplot(2,2,4); loglog(1./PRx,PR./nPR,'r');
title('Signal to noise ratio');
xlabel('1/Frequency [units]');
ylabel('SNR');
grid on
grid minor
axis tight


