function nBins= freedmanDiaconis(data)
%	1 Use Freedman-Diaconis' choice (1981)doi:10.1007/BF01025868
% 	to calculate the common bin width, h
n = numel(data);
h1 = 2*myIQR(data)/n^(1/3);
%	2. caclulate the vector of bin centres from h
nBins = (max(data)-min(data))/h1;

%------------------------------------------------------------------------------
function [result, q1, q3] = myIQR(xData)
% function [result, q1, q3] = myIQR(xData)
%	return the interquartile range of data - not 
% stats toolbox so dont run out of licenses

xSorted = sort(xData);
n = numel(xSorted);

q1 = xSorted(round(0.25*n));
q3 = xSorted(round(0.75*n));

result = abs(q3-q1); %probably have to be careful with complex numbers here

