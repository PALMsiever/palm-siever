% Otsu thresholding and average density calculation
function averageDensity(handles)

% D = getappdata(0,'KDE'); X = D{1}; Y = D{2}; D = dip_image(D{3});
% %m = threshold(D,'otsu');
% m = threshold(D,'isodata');
% %m = D>50;
% 
% pxArea = (X(1,2)-X(1,1))*(Y(2,1)-Y(1,1));
% 
% density=dip_image(render_histogram(handles));
% 
% dipshow(overlay(D,m))
% subset = getSubset(handles);
% avgDens = sum(subset)/sum(m*density)/pxArea;
% 
% text(20,20,['Average density is : ' num2str(avgDens) ' locs/unit^2.'], 'Color','y');
% 
% 
% % Select non-circular objects above 50 locs/unit
% l = label(m);
% M = measure(l,[],{'P2A'});
% 
% m = reshape(ismember(uint16(l(:)),find(M.P2A>2)),size(l));
% 
% dipshow(overlay(D,m))
% 
% avgDensNonRound = sum(subset)/sum(m*density)/pxArea;
% 
% text(20,20,['Average density of non-circular objects is : ' num2str(avgDensNonRound) ' locs/unit^2'], 'Color','y');
% 

