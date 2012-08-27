% Quantization of signal x between xmin and xmax in N segments, indexed
% from 1 to N.
%
% function [i X] = quantization(x,xmin,xmax,N)
%
%   x - the input signal (may be a vector or a matrix)
%   xmin - the minimum of the signal range
%   xmax - the maximum of the signal range
%   N - the number of segments
%
%   X - the bin centers
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function [i X] = quantization(x,xmin,xmax,N)

%x = x(x>=xmin & x<=xmax);

i=zeros(size(x));
i(x==xmin)=0;
i(x~=xmin)=ceil((x(x~=xmin)-xmin)/(xmax-xmin)*N);

X = linspace(xmin,xmax,N);