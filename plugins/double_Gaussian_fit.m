% Perform a double Gaussian fit and plot the results
function double_Gaussian_fit(handles)

uiwait(msgbox('Select the center of the region where to perform the fit','Fit double Gaussian','modal'));

[x y] = ginput(1);

subset = getSubset(handles);
X=getX(handles); X=X(subset)-x;
Y=getY(handles); Y=Y(subset)-y;
r=getRadius(handles); l=getLength(handles);
nbins = str2double(get(handles.tBins,'String'));

subset0 = X.^2 + Y.^2 < r*r;
ss = [X(subset0) Y(subset0)];
if isempty(ss)
    msgbox(['No points within the specified radius: ' num2str(r)]);
    return
end
[v d] = eig(cov(ss)); 
dir = v(:,2);
dirM = [dir [-dir(2);dir(1)]];

sscp = [X Y]*dirM;
sscp_ok = sscp(:,2)<r & sscp(:,2)>-r ...
    & sscp(:,1)<l & sscp(:,1)>-l;
sscp = sscp(sscp_ok,:);

line([x-dirM(1,2)*r x+dirM(1,2)*r],[y-dirM(2,2)*r y+dirM(2,2)*r])
line([x-dirM(1,1)*l x+dirM(1,1)*l],[y-dirM(2,1)*l y+dirM(2,1)*l],'Color','g')

if nbins==0
    nbins = ceil(log(sum(subset0))/log(2)+1)*2;
end

[h b] = hist(sscp(:,2),linspace(min(sscp(:,2)),max(sscp(:,2)),nbins)');

double_gaussian_fit_1D_plot(b,h);

