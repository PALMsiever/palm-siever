% Elementwise sum of squares. 
%
% function [s,n] = sumsqr(x)
%   s : sum of squares of x
%   n : number of elements of x
%
function [s,n] = sumsqr(x)

s = sum(x(:).^2);

if nargout>1
    n = numel(x);
end

