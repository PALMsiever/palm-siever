function [density X Y] = getDensity(handles)

D = getappdata(0,'KDE');

if ~isempty(D)
    X = D{1};
    Y = D{2};
    density = D{3};
end


