function cmap = getColormapName(handles)

cmps = get(handles.pColormap,'String');
cmpi = get(handles.pColormap,'Value');
cmap = cmps{cmpi};
