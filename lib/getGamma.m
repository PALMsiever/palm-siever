% Get the current gamma
function gamma = getGamma(handles);

try
    gamma=str2double(get(handles.tGamma,'String'));
catch
    warning('Unreadable gamma value, defaulting to 1')
    gamma=1;
end
