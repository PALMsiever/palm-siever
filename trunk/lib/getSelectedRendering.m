function str = getSelectedRendering(handles)
strs = get(handles.pShow,'String');
str = strs{get(handles.pShow,'Value')};
