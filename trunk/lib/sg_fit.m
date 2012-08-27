% Single Gaussian fit
%   [fitresult, gof] = sg_fit(x,y)
%
%   Needs the Curve Fitting Toolbox. Fits a Gaussian using the
%   Levenberg-Marquardt algorithm. The fitted function is of the type 
%       'a1*exp(-(x-b1).^2 / 2 /c1.^2 )'
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function [fitresult, gof] = sg_fit(x,y)

ft = fittype( 'a1*exp(-(x-b1).^2 / 2 /c1.^2 )' );
opts = fitoptions( ft );
opts.Algorithm = 'Levenberg-Marquardt';
%opts.Lower = [0 -Inf 0];
opts.StartPoint = [max(y) mean(x) std(x)];
%opts.Upper = -opts.Upper;
opts.Display = 'Off';

[fitresult, gof] = fit( x, y, ft, opts );
