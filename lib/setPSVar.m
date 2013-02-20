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

leftoverVar = get(handles.pXAxis,'String');
psVarUnassigned = {'x','y','z','frame','id'};

for jj = 1:numel(varAssignment)
   if strcmp('x',varAssignment{jj}{1})
      set(handles.pXAxis,'Value',find(strcmp(get(handles.pXAxis,'String'),varAssignment{jj}{2})));
      handles.settings.varx = varAssignment{jj}{2};
      leftoverVar(strcmp(leftoverVar,varAssignment{jj}{2}))=[];
      psVarUnassigned(strcmp(psVarUnassigned,'x'))=[];
   elseif strcmp('y',varAssignment{jj}{1})
      set(handles.pYAxis,'Value',find(strcmp(get(handles.pXAxis,'String'),varAssignment{jj}{2})));
      handles.settings.vary = varAssignment{jj}{2};
      leftoverVar(strcmp(leftoverVar,varAssignment{jj}{2}))=[];
      psVarUnassigned(strcmp(psVarUnassigned,'y'))=[];
   elseif strcmp('z',varAssignment{jj}{1})
      set(handles.pZAxis,'Value',find(strcmp(get(handles.pXAxis,'String'),varAssignment{jj}{2})));
      handles.settings.varz = varAssignment{jj}{2};
      leftoverVar(strcmp(leftoverVar,varAssignment{jj}{2}))=[];
      psVarUnassigned(strcmp(psVarUnassigned,'z'))=[];
   elseif strcmp('frame',varAssignment{jj}{1})
      set(handles.pFrame,'Value',find(strcmp(get(handles.pXAxis,'String'),varAssignment{jj}{2})));
      handles.settings.varFrame= varAssignment{jj}{2};
      leftoverVar(strcmp(leftoverVar,varAssignment{jj}{2}))=[];
      psVarUnassigned(strcmp(psVarUnassigned,'frame'))=[];
   elseif strcmp('id',varAssignment{jj}{1})
      set(handles.pID,'Value',find(strcmp(get(handles.pXAxis,'String'),varAssignment{jj}{2})));
      handles.settings.varID = varAssignment{jj}{2};
      leftoverVar(strcmp(leftoverVar,varAssignment{jj}{2}))=[];
      psVarUnassigned(strcmp(psVarUnassigned,'id'))=[];
   end
end

%give any unassigned psVar arbitary assignment
if ~isempty(leftoverVar)
   defaultVar = leftoverVar{1};
else
   defaultVar = get(handles.pXAxis,'Value');
end

for ii = 1:numel(psVarUnassigned)
   if strcmp('z',psVarUnassigned{ii})
      set(handles.pZAxis,'Value',find(strcmp(get(handles.pXAxis,'String'),defaultVar)));
      handles.settings.varz = defaultVar;
   elseif strcmp('frame',psVarUnassigned{ii})
      set(handles.pFrame,'Value',find(strcmp(get(handles.pXAxis,'String'),defaultVar)));
      handles.settings.varFrame=defaultVar;
   elseif strcmp('id',psVarUnassigned{ii})
      set(handles.pID,'Value',find(strcmp(get(handles.pXAxis,'String'),defaultVar)));
      handles.settings.varID = defaultVar;
   end
end

guidata(handles.output, handles);

