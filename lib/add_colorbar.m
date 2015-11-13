% Add colorbar
function add_colorbar(handles, col)

str = getSelectedRendering(handles);

if ~is3DRendering(handles)
    axes(handles.axes1)
    colorbar('location','East','XColor',col,'YColor',col)
else
    % Draw 2D Colorbar
    % Draw box
    w = .05; margX = .025;
    h = .85; margY = .1;
    [minX, maxX, minY, maxY] = getBounds(handles);
    [minZ, maxZ] = getZbounds(handles);
    x = minX + (maxX-minX) * (1-w-margX);
    y = minY + (maxY-minY) * (1-h-margY);
    w = w * (maxX-minX);
    h = h * (maxY-minY);
    rectangle('Position',[x,y,w,h],'EdgeColor','white','FaceColor','None');
    
    % Calc z colors
    nc = 32;
    rgbc = hsv(nc*3/2);
    rgbZ = @(z) rgbc(max(1,ceil( (maxZ-z)/(maxZ-minZ)*nc )),:);
    rightC = zeros(nc,3);
    leftC = rgbZ(linspace(minZ,maxZ,nc)');
    xs = repmat([x x+w x+w x]',nc,1);
    dy = h/nc;
    ys = y+dy*[ (0:nc-1)' (0:nc-1)' (1:nc)' (1:nc)' ]'; ys=ys(:);
    fvc = zeros(nc*4,3);
    fvc(1:4:end,:) = leftC;
    fvc(2:4:end,:) = rightC;
    fvc(3:4:end,:) = rightC;
    fvc(4:4:end,:) = leftC;
    patch('Vertices',[xs ys],'Faces',reshape(1:nc*4,4,nc)','FaceVertexCData',fvc,'FaceColor','flat','EdgeColor','none');
    for i=0:nc
        text(x-w/2,y+i*h/nc,sprintf('%.2e',minZ+(nc-i)*(maxZ-minZ)/nc),'Color','white','FontSize',8,'HorizontalAlignment','right')
    end
end


