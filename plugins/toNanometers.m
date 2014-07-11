% Converts the XYZ data from generic units to nanometers.
function toNanometers(handles)

if isnumeric(handles)
    pixelSize = handles;
else
    pixelSizeS = inputdlg('Pixel size (nm/pixel)'); % nm/pixel
    pixelSize = str2double(pixelSizeS);
end

xname = handles.settings.varx;
yname = handles.settings.vary;

assignin('base',xname,fetch(xname) * pixelSize);
assignin('base',yname,fetch(yname) * pixelSize);

[minX, maxX, minY, maxY] = getBounds(handles);
handles = setBounds(handles,[minX, maxX, minY, maxY]*pixelSize);

guidata(gcf,handles);

% Legacy
% assignin('base','Sigma_X_Pos_Full',evalin('base','Sigma_X_Pos_Full') * pixelSize);
% assignin('base','Sigma_Y_Pos_Full',evalin('base','Sigma_Y_Pos_Full') * pixelSize);
% assignin('base','Group_X_Position',evalin('base','Group_X_Position') * pixelSize);
% assignin('base','Group_Y_Position',evalin('base','Group_Y_Position') * pixelSize);
% assignin('base','Group_Sigma_X_Pos',evalin('base','Group_Sigma_X_Pos') * pixelSize);
% assignin('base','Group_Sigma_Y_Pos',evalin('base','Group_Sigma_Y_Pos') * pixelSize);



