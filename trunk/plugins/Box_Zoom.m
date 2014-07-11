% Allows the user to zoom into a region specified with a box. Double-click on the border to accept the zoom-box.
function Box_Zoom(handles)

h = imrect(handles.axes1);
pos = wait(h);

if ~isempty(pos)
    setBounds(handles,[pos(1) pos(1)+pos(3) pos(2) pos(2)+pos(3)]);
end

