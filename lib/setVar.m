function handles = setVar(handles, varName, varAssignment)
%function setVar(handles, var, varAssignment)
% varAssignment: 'x','y','z','frame','id';

if strcmp('x',varAssignment)
   set(handles.pXAxis,'Value',find(strcmp(get(handles.pXAxis,'String'),varName)));
   handles.settings.varx = varName;
elseif strcmp('y',varAssignment)
   set(handles.pYAxis,'Value',find(strcmp(get(handles.pXAxis,'String'),varName)));
   handles.settings.vary = varName;
elseif strcmp('z',varAssignment)
   set(handles.pZAxis,'Value',find(strcmp(get(handles.pXAxis,'String'),varName)));
   handles.settings.varz = varName;
elseif strcmp('frame',varAssignment)
   set(handles.pFrame,'Value',find(strcmp(get(handles.pXAxis,'String'),varName)));
   handles.settings.varFrame= varName;
elseif strcmp('id',varAssignment)
   set(handles.pID,'Value',find(strcmp(get(handles.pXAxis,'String'),varName)));
   handles.settings.varID = varName;
end

guidata(handles.output, handles);
