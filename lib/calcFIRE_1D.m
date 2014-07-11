% Calculate a variation of the FIRE for 1-dimensional data
function [ FIRE se frcprofile frcprofile_f F frcprofile_est fSNR fSNR_RES] = calcFIRE_1D(X, res, minX, maxX, nTrials)
frcprofile_f = linspace(0,res/(maxX-minX)/2,res/2)';
frcprofile = zeros(res/2,1);

iss0 = randperm(length(X));
for trials=1:nTrials
    d = max(floor(length(X)/nTrials),1);
    i0 = (trials-1)*d+1; i1 = min(trials*d,length(X));
    iss1 = iss0(i0:i1);
    D1 = hist(X(iss1), linspace(minX, maxX, res));
    fD1 = fft(D1);
    F(trials, :) = fD1(1:end/2); % Being real, it's symmetric
end

% Calculate fSNR and 't' threshold
tSNR = 3;
fSNR = 10*log10(mean(abs(F)).^2./var(F))';
f = @(x) sum(fSNR(frcprofile_f>x & isfinite(fSNR))-tSNR)-sum(fSNR(frcprofile_f<x & isfinite(fSNR))-tSNR);
fSNR_RES = 1/fminbnd(f,min(frcprofile_f),max(frcprofile_f));

for fn=1:size(F,2)
    a = F(1:end/2,fn);
    b = F((end/2+1):end,fn);
    if all(a==b)
        cc=1;
    else
        %cc=corrcoef(a,b); cc=cc(1,2);
        cc = abs(sum(a.*conj(b))./sqrt(sum(abs(a).^2).*sum(abs(b).^2)));
    end
    frcprofile(fn)=cc;
end

fX = frcprofile_f;
fY = frcprofile;

% Estimate 1/7 threshold
%f = @(x) sum(fY(fX>x)-1/7)-sum(fY(fX<x)-1/7);
%FIRE_ = fminbnd(f,min(fX),max(fX));

% Gaussian spectrum fit method..
 fYest = @(a) exp(-a*fX.^2);
 f = @(a) sum( abs(fYest(a)-fY).^2 );
 a = fminbnd(f,0,2*log(7)/fX(2).^2);
 FIRE_ = sqrt(log(7)/a);
 frcprofile_est = fYest(a);

if sum(fX>FIRE_)<5 % We require at least 5 curve points to the right of the crossing point
    logger('The resolution threshold of 1/7 was not attained. You can probably use a finer grid to bin your data.');
    FIRE_ = fX(end);
end

FIRE = 1/FIRE_;
se = 0;

