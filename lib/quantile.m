% QUANTILE
function q = quantile(data,quantiles)

% Linearize
data = data(:);

d = sort(data);
q = (1:length(d))/length(d);

[d1 id1f] = unique(d,'first');
[d2 id2l] = unique(d,'last');

q = q(id1f)*.5+q(id2l)*.5;

if length(q)>1
    q = interp1(q,d1,quantiles,'spline','extrap');
else
    q = repmat(q,size(quantiles));
end

