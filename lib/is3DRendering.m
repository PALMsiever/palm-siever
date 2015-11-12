function isit = is3DRendering(handles)

str = getSelectedRendering(handles);

isit = strcmp('3D Hue-opacity',str) || strcmp('3D Hue',str);
