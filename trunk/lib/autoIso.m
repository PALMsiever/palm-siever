% Automatic calculation of iso-surface value for volumetric data using Otsu's method
function isoVal = autoIso(vol)

vol= double(vol);
%nBins = freedmanDiaconis(vol(:)); this gives ridiculous nBins for large datasets
nBins = sqrt(numel(vol(:))); % Sturges' formula - seems to work reliably

%from the multiOtsu m-file
[histo,pixval] = hist(vol(:),nBins);
P = histo/sum(histo);

%% Zeroth- and first-order cumulative moments
w = cumsum(P);
mu = cumsum((1:nBins).*P);

%% Maximal sigmaB^2 and Segmented image
sigma2B =...
    (mu(end)*w(2:end-1)-mu(2:end-1)).^2./w(2:end-1)./(1-w(2:end-1));
[maxsig,k] = max(sigma2B);

isoVal = pixval(k+1);
