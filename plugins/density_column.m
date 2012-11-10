function density_column(handles)

XPosition = getX(handles);
YPosition = getY(handles);
subset = getSubset(handles);
[density X Y ] = getDensity(handles);

if isempty(density)
    error('First calculate the density using one of the appropriate representations (Histogram, KDE, ...)');
end

Density = zeros(length(XPosition),1);
Density(subset) = interp2(X,Y,density,XPosition(subset),YPosition(subset),'nearest',0);

assignin('base','density',Density);

