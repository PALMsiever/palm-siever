function setPSVar(handles, varAssignment)
% function setVar(handles, varAssignment)
% varAssignment:
%  cell containing 
%     {'x',xColName,
%      'y',yColName,
%      'z',zColName, (optional)
%      'id',idColName, (optional)
%      'frame',frameColName, (optional)}

%VARLIST={'x','y','z','frame','id'};

for jj = 1:numel(varAssignment)
   if strcmp('x',varAssignment{jj}{1})
      set(handles.pXAxis,'Value',find(strcmp(get(handles.pXAxis,'String'),varAssignment{jj}{2})));
      handles.settings.varx = varAssignment{jj}{2};
   elseif strcmp('y',varAssignment{jj}{1})
      set(handles.pYAxis,'Value',find(strcmp(get(handles.pXAxis,'String'),varAssignment{jj}{2})));
      handles.settings.vary = varAssignment{jj}{2};
   elseif strcmp('z',varAssignment{jj}{1})
      set(handles.pZAxis,'Value',find(strcmp(get(handles.pXAxis,'String'),varAssignment{jj}{2})));
      handles.settings.varz = varAssignment{jj}{2};
   elseif strcmp('frame',varAssignment{jj}{1})
      %DO NOTHING (for now...)
   elseif strcmp('id',varAssignment{jj}{1})
      set(handles.pID,'Value',find(strcmp(get(handles.pXAxis,'String'),varAssignment{jj}{2})));
      set(handles.pID,'String',varAssignment{jj}{2});
   end
end
guidata(handles.output, handles);

