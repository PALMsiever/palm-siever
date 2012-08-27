pixelSizeS = inputdlg('Pixel size (nm/pixel)'); % nm/pixel

if ~isempty(pixelSizeS)
    pixelSize = str2double(pixelSizeS);

    X_Position = X_Position * pixelSize;
    Y_Position = Y_Position * pixelSize;
    Sigma_X_Pos_Full = Sigma_X_Pos_Full * pixelSize;
    Sigma_Y_Pos_Full = Sigma_Y_Pos_Full * pixelSize;

    Group_X_Position = Group_X_Position * pixelSize;
    Group_Y_Position = Group_Y_Position * pixelSize;
    Group_Sigma_X_Pos = Group_Sigma_X_Pos * pixelSize;
    Group_Sigma_Y_Pos = Group_Sigma_Y_Pos * pixelSize;
    
end


