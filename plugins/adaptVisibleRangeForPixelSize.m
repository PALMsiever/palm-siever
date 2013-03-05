% Plugin to set the limits for the size manually
%
%  setLimitsForPixelSize(handles)
%
%   The plugin asks for a target pixel size, in the same units as the data.
%  Then, it asks how you wish to modify the visible range for that. You can
%  keep the current upper-left corner fixed, the center fixed, or fix the 
%  upper left corner to (0,0).
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function setLimitsForPixelSize(handles)

npx = inputdlg('Please enter desired pixel size (same units as the data)');
if isempty(npx)
    return
end

button = questdlg(...
    'How would you like to modify the visible range?',...
    'How to zoom','Upper left fixed','Center fixed',...
    'Upper left to (0,0)','Upper left to (0,0)');

npx = str2double(npx{1});
res = getRes(handles);
[minX, maxX, minY, maxY] = getBounds(handles);

ccX = (minX+maxX)/2;
ccY = (minY+maxY)/2;

switch button
    case 'Center fixed'
        nmaxX = ccX + npx*res/2;
        nminX = ccX - npx*res/2;
        nmaxY = ccY + npx*res/2;
        nminY = ccY - npx*res/2;
    case 'Upper left to (0,0)'
        nminX = 0;
        nmaxX = res*npx;
        nminY = 0; 
        nmaxY = res*npx;
    case 'Upper left fixed'
        nminX = minX;
        nmaxX = minX+res*npx;
        nminY = minY; 
        nmaxY = minY+res*npx;
end        

handles = setBounds(handles, [nminX nmaxX nminY nmaxY]);

guidata(gcf,handles)




