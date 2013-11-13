function [mu sigma gof fits] = gaussian_fit_1D (xs,ys)

% Gaussian
fun = @(x,xdata) x(1)*exp(-((xdata-x(2)).^2/2/x(3).^2));

% Cost function
ofun = @(x) sum( (fun(x,xs)-ys).^2 );

[x, gof] = fminsearch( ofun, [max(ys) mean(abs(xs)) std(abs(xs))]);

% Output
mu = x(2); 
sigma = abs(x(3));
fits = fun(x,xs);
