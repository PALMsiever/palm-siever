% Adding a scalebar
function mask = add_scalebar(handles,img)

[minX, maxX, minY, maxY] = getBounds(handles);

dl_x = (maxX-minX);
dl_y = (maxY-minY);

h_units = dl_y / 128;
w_units = 10^round(log(2*dl_x / 8)/log(10))/2;

if nargin>1
    res = getRes(handles);
    px_x = dl_x/res;
    h_px = res/128;
    w_px = round(w_units/px_x);

    x0 = res-w_px-7*h_px;
    y0 = res-h_px-3*h_px;

    mask = zeros(size(img'));
    mask(y0+(1:h_px),x0+(1:w_px))=1;
else    
    x0 = maxX-w_units-7*h_units;
    y0 = maxY-h_units-3*h_units;
    line([x0 x0+w_units],[y0 y0],'Color','white','LineWidth',5);
    text(x0+w_units/2,y0-3*h_units,num2str(w_units),'Color','white','HorizontalAlignment','center');
end

