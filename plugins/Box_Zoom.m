% Box zoom
function Box_Zoom(handles)

h = imrect(handles.axes1);
pos = wait(h);

if ~isempty(pos)
    setBounds(handles,[pos(1) pos(1)+pos(3) pos(2) pos(2)+pos(3)]);
end

