function vol3D(handles)

X = getX(handles);
Y = getY(handles);
Z = getZ(handles);

subset = getSubset(handles);

X=X(subset);
Y=Y(subset);
Z=Z(subset);

res = getRes(handles);

[minX maxX minY maxY] = getBounds(handles);
[minZ maxZ] = getZbounds(handles);

XI = floor( (X-minX)/(maxX-minX)*res );
YI = floor( (Y-minY)/(maxY-minY)*res );
ZI = floor( (Z-minZ)/(maxZ-minZ)*res );

XI(XI<1) = 1; XI(XI>res) = res;
YI(YI<1) = 1; YI(YI>res) = res;
ZI(ZI<1) = 1; ZI(ZI>res) = res;

VOL = accumarray([XI YI ZI],1,[res res res]);
VOLs = gaussf(VOL,[5 5 .8*50/(1000/256)]);

%dipshow(gaussf(VOL,[5 5 .8*50/(1000/256)]))
%isosurfaceplot(gaussf(VOL,[5 5 .8*50/(1000/256)]),1e-4)

figure;
fv = isosurface(double(VOLs),1e-4); 
p = patch(fv);
set(p,'FaceColor','green','EdgeColor','none');
camlight 
view(3)




