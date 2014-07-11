% Plots a gaussian fit for datapoints (xs,ys) in a new figure and returns the handle
function f=double_gaussian_fit_1D_plot(xs,ys);
%
% Thomas Pengo, 2013
%
xs=xs(:);ys=ys(:);

f=figure;
    [mu sigma w gof fits] = double_gaussian_fit_1D(xs,ys);

    stem(xs,ys);
    hold;
    plot(xs,fits,'r');
    
    set(f, 'PaperUnits', 'inches');
    set(f, 'PaperPosition', [0 0 2.5 2.5]);   
    
    text(interp1(1:length(xs),xs,length(xs)*3/4),max(ys)*3/4,sprintf('mu = %.2f\nsigma = %.2f\nw = %.2f',mu,sigma,w));
