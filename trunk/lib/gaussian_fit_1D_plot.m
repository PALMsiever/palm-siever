% Plots a gaussian fit for datapoints (xs,ys) in a new figure and returns
% the handle
%
% Thomas Pengo, 2013
%
function f=gaussian_fit_1D_plot(xs,ys);
xs=xs(:);ys=ys(:);

f=figure;
    [mu sigma gof fits] = gaussian_fit_1D(xs,ys);

    stem(xs,ys);
    hold;
    plot(xs,fits,'r');
    
    set(f, 'PaperUnits', 'inches');
    set(f, 'PaperPosition', [0 0 2.5 2.5]);   
    
    text(interp1(1:length(xs),xs,length(xs)*3/4),max(ys)*3/4,sprintf('mu = %.2f\nsigma = %.2f',mu,sigma));
