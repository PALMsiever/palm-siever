% Jittered histogram
%  [H b H2]= jhist(data,nbins,amount,N)
%  
%   data    the vector to be analyzed
%   nbins   the number of bins in the histogram
%   amount  amount of jittering, expressed as the sigma of a zero-mean
%           Gaussian
%   N       number of averages
%   
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function [H b H2]= jhist(data,nbins,amount,N)

if numel(nbins)>1
    b = nbins;
    nbins = numel(nbins);
else
    b = linspace(min(data),max(data),nbins);
end

H = zeros(1,nbins);
H2 = zeros(1,nbins);
for i=1:N
    jdata = data+randn(size(data)).*amount;
    if i==1
        [h b] = hist(jdata,b);
    else
        h = hist(jdata,b);
    end
    H = H + h;
    H2 = H2 + h.^2;
end
H = H/N;
H2 = sqrt(H2/N - H.^2);
