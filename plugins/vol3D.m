% Creates a 3D volume from the data. Please use the Render_3DVol plugin.
function vol3D(handles)

X = getX(handles);
Y = getY(handles);
Z = getZ(handles);

subset = getSubset(handles);

X=X(subset);
Y=Y(subset);
Z=Z(subset);

res = getRes(handles);
resZ = 128;

[minX maxX minY maxY] = getBounds(handles);
[minZ maxZ] = getZbounds(handles);
sigma = str2double(get(handles.sigma,'String'));
sX = res/(maxX-minX)*sigma;
sY = res/(maxY-minY)*sigma;
sZ = resZ/(maxZ-minZ)*sigma*1.5;


XI = floor( (X-minX)/(maxX-minX)*res );
YI = floor( (Y-minY)/(maxY-minY)*res );
ZI = floor( (Z-minZ)/(maxZ-minZ)*resZ );

XI(XI<1) = 1; XI(XI>res) = res;
YI(YI<1) = 1; YI(YI>res) = res;
ZI(ZI<1) = 1; ZI(ZI>resZ) = resZ;

VOL = accumarray([XI YI ZI],1,[res res resZ]);
VOL = extend(VOL,round(size(VOL)*1.5));
VOLs = gaussf(VOL,[sX sY sZ]);
%VOLs = gaussf(VOL,[5 5 .8*50/(1000/resZ)]);
%VOLs = gaussf(VOL,[5 5 .8*50/(1000/256)]);
%xR = [1:256];yR=xR;zR=xR;
%sliceomatic(double(VOLs),xR,yR,zR)
%dipshow(gaussf(VOL,[5 5 .8*50/(1000/256)]))
%isosurfaceplot(gaussf(VOL,[5 5 .8*50/(1000/256)]),1e-4)

h1 = figure;
set(0,'CurrentFigure',h1);
fv = isosurface(double(VOLs),1e-4); 
p = patch(fv);
set(p,'FaceColor','green','EdgeColor','none');
camlight 
view(3)




