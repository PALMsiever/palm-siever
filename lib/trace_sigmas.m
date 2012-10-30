% Calculate sigmas along trace
%
%  [ sigmas means gofs ] = trace_sigmas(A, centers)
%    A          a Nx2 matrix of points
%    centers    
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function [ sigmas means gofs ] = trace_sigmas(A, centers)

% Gaussian
fun = @(x,xdata) x(1)*exp(-((xdata-x(2))/x(3)).^2);

N = size(A,1);

means = zeros(N,1);
sigmas = zeros(N,1);
gofs = zeros(N,1);

for i = 1:N
    [fitresult, gof] = lsqcurvefit( fun, [max(A(i,:)) mean(abs(centers)) std(abs(centers))], centers', A(i,:)');
    means(i) = fitresult(2);
    sigmas(i) = fitresult(3);
    gofs(i) = gof;
end
