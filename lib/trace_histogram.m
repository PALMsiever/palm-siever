% Calculate the histogram along a trace
%
%  [ A centersY visited centersX  ]= trace_histogram(Trace,X,Y,r,nbins,overlap)
%
%    Trace      the trace to be straightened
%    X,Y        the data points
%    r          the waist of the trace
%    nbins      the number of bins in the histogram
%    overlap    how much should the steps of the trace overlap
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function [ A centersY visited centersX  ]= trace_histogram(Trace,X,Y,r,nbins,overlap)

visited = zeros(size(X,1),1);

if nargin<6
    overlap = 1;
end

centersX = zeros(size(Trace,1)-1,1);
centersY = linspace(-r,r,nbins);
A = []; cumL = 0;

for i=2:size(Trace,1)
    dTrace = Trace(i,1:2)-Trace(i-1,1:2);
    l = sqrt(sumsqr(dTrace)); cumL = cumL+l;
    dTrace = dTrace/l;
    
    nTrace = [-dTrace(2) dTrace(1)]; nTrace = nTrace/sqrt(sumsqr(nTrace));
    
    ctr = .5*Trace(i,1:2)+.5*Trace(i-1,1:2);
    
    pX = [X-ctr(1) Y-ctr(2)]*dTrace';
    pY = [X-ctr(1) Y-ctr(2)]*nTrace';
    
    subset = pX <= l/2*(1+overlap) & pX > -l/2*(1+overlap) & pY <= r & pY > -r;
    
    visited = visited + subset;
    centersX(i-1) = cumL;
    
    h = hist(pY(subset),centersY);
    A = [A; h];
end

