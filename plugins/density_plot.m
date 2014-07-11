% Performs a density plot around a specified position, across the spread of the point distribution.
function density_plot(handles)

axes(handles.axes1)

[x,y,button] = ginput(1);

if button==27
    return
end

subset = getSubset(handles);
X=getX(handles); X=X(subset)-x;
Y=getY(handles); Y=Y(subset)-y;
r = str2double(get(handles.radius,'String'));
l = str2double(get(handles.length,'String'));
s = str2double(get(handles.sigma,'String'));

subset0 = X.^2 + Y.^2 < r*r;

if sum(subset0)<5
    errordlg('Not enough points. Try enlarging the radius and the length for example.')
end

ss = [X(subset0) Y(subset0)];
[v d] = eig(cov(ss)); 
dir = v(:,2);
dirM = [dir [-dir(2);dir(1)]];

sscp = [X Y]*dirM;
sscp_ok = sscp(:,2)<r & sscp(:,2)>-r ...
    & sscp(:,1)<l & sscp(:,1)>-l;
sscp = sscp(sscp_ok,:);

%subset0 = sscp( + Y.^2 < r*r;
%ss = [X(subset0) Y(subset0)];

xl = x-dirM(1,2)*r; xr = x+dirM(1,2)*r;
yl = y-dirM(2,2)*r; yr = y+dirM(2,2)*r;
xd = x-dirM(1,1)*l; xu = x+dirM(1,1)*l;
yd = y-dirM(2,1)*l; yu = y+dirM(2,1)*l;
line([xl xr],[yl yr])
line([xd xu],[yd yu],'Color','g')
% line([xl xr],[yu yu])
% line([xl xr],[yd yd])
% line([xl xl],[yl yu],'Color','g')
% line([xr xr],[yl yu],'Color','g')

%[h b h2] = jhist(sscp(:,2),linspace(min(sscp(:,2)),max(sscp(:,2)),nbins)',amount,1);
X = sort(sscp(:,2));

dX = diff(X);
%k = [1     8    28    56    70    56    28     8     1]/256;
k = exp(-linspace(-3,3,s*6/mean(dX)).^2); k = k/sum(k);
dX = conv(dX, k,'same');

figure; plot(X(1:end-1),1./dX/2/l)
xlabel('Distance from cursor')
ylabel('Average #points per unit')


