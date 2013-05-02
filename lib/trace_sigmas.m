% Calculate sigmas along trace
%
%  [ sigmas means gofs ns sigmas_outliers] = trace_sigmas(A, centers)
%    A          a Nx2 matrix of points
%    centers    
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function [ sigmas means gofs ns sigmas_outliers] = trace_sigmas(A, centers)

% Gaussian
fun = @(x,xdata) x(1)*exp(-((xdata-x(2)).^2/2/x(3).^2));

N = size(A,1);

means = zeros(N,1);
sigmas = zeros(N,1);
gofs = zeros(N,1);
ns = zeros(N,1);

for i = 1:N
%     % Needs curve fitting tool.
%     [fitresult, gof] = lsqcurvefit( fun, [max(A(i,:)) mean(abs(centers)) std(abs(centers))], centers', A(i,:)');
%     means(i) = fitresult(2);
%     sigmas(i) = fitresult(3);
%     gofs(i) = gof;
    ofun = @(x) sumsqr(fun(x,centers')-A(i,:)');
    [x, gof] = fminsearch( ofun, [max(A(i,:)) mean(abs(centers)) std(abs(centers))]);
    means(i) = x(2);
    sigmas(i) = x(3);
    gofs(i) = gof;
    ns(i) = sum(A(i,:));
end

sigmas_outliers = sigmas > 2*median(sigmas) | 2*sigmas < median(sigmas);
sigmas(sigmas_outliers) = mean(sigmas(~sigmas_outliers));
