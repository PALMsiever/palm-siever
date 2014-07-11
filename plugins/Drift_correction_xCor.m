% Opens the GUI to perform drift correction with cross-correlation. See the corresponding documentation for details.
function varargout = Drift_correction_xCor(varargin)
% DRIFT_CORRECTION_XCOR MATLAB code for Drift_correction_xCor.fig
%      DRIFT_CORRECTION_XCOR, by itself, creates a new DRIFT_CORRECTION_XCOR or raises the existing
%      singleton*.
%
%      H = DRIFT_CORRECTION_XCOR returns the handle to a new DRIFT_CORRECTION_XCOR or the handle to
%      the existing singleton*.
%
%      DRIFT_CORRECTION_XCOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRIFT_CORRECTION_XCOR.M with the given input arguments.
%
%      DRIFT_CORRECTION_XCOR('Property','Value',...) creates a new DRIFT_CORRECTION_XCOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Drift_correction_xCor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Drift_correction_xCor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Drift_correction_xCor

% Last Modified by GUIDE v2.5 01-Aug-2013 17:33:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Drift_correction_xCor_OpeningFcn, ...
                   'gui_OutputFcn',  @Drift_correction_xCor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Drift_correction_xCor is made visible.
function Drift_correction_xCor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Drift_correction_xCor (see VARARGIN)

% Choose default command line output for Drift_correction_xCor
handles.output = hObject;

%get the PALM_Siever_handles
handlesPsvGui = varargin{1};
handles.handlesPsvGui = handlesPsvGui;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Drift_correction_xCor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Drift_correction_xCor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox_correctZDrift.
function checkbox_correctZDrift_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_correctZDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_correctZDrift


% --- Executes on button press in checkbox_showDriftGraph.
function checkbox_showDriftGraph_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_showDriftGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_showDriftGraph


% --- Executes on button press in pushbutton_doDriftCorrection.
function pushbutton_doDriftCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_doDriftCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(handles.output);
handles.handlesPsvGui = guidata(handles.handlesPsvGui.output);

isWriteToCurrentVars = get(handles.radiobutton_useExistingVars, 'Value');
varSuffix = get(handles.edit_newVarSuffix,'String');
minPtsArea = str2num(get(handles.edit_minPts,'String'));
minFrame = str2num(get(handles.edit_minFrame,'String'));
xCorPixSz = str2num(get(handles.edit_xCorPixSz,'String'));
fitWindowSz = str2num(get(handles.edit_fitWindowSz,'String'));

isCorrectZ = get(handles.checkbox_correctZDrift,'Value');
isShowDriftGraph = get(handles.checkbox_showDriftGraph,'Value');

XPosition=evalin('base',handles.handlesPsvGui.settings.varx);
YPosition=evalin('base',handles.handlesPsvGui.settings.vary);
Frame = evalin('base',handles.handlesPsvGui.settings.varFrame);
if ~isCorrectZ
   stormData = [Frame,XPosition,YPosition];
   [xc,yc,handles.tDrift,handles.xDrift,handles.yDrift] = crossCorrect3D(stormData, minPtsArea,minFrame,xCorPixSz,fitWindowSz,isShowDriftGraph);
   guidata(handles.output,handles);
   assignVars(handles,xc,yc);
else
   ZPosition=evalin('base',handles.handlesPsvGui.settings.varz);
   stormData = [Frame,XPosition,YPosition,ZPosition];
   [xc,yc,handles.tDrift,handles.xDrift,handles.yDrift, zc, handles.zDrift] = crossCorrect3D(stormData, minPtsArea,minFrame,xCorPixSz,fitWindowSz,isShowDriftGraph);
   guidata(handles.output,handles);
   assignVars(handles,xc,yc,zc);
end







function edit_minPts_Callback(hObject, eventdata, handles)
% hObject    handle to edit_minPts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_minPts as text
%        str2double(get(hObject,'String')) returns contents of edit_minPts as a double


% --- Executes during object creation, after setting all properties.
function edit_minPts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_minPts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_minFrame_Callback(hObject, eventdata, handles)
% hObject    handle to edit_minFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_minFrame as text
%        str2double(get(hObject,'String')) returns contents of edit_minFrame as a double


% --- Executes during object creation, after setting all properties.
function edit_minFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_minFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_xCorPixSz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xCorPixSz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xCorPixSz as text
%        str2double(get(hObject,'String')) returns contents of edit_xCorPixSz as a double


% --- Executes during object creation, after setting all properties.
function edit_xCorPixSz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xCorPixSz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_newVarSuffix_Callback(hObject, eventdata, handles)
% hObject    handle to edit_newVarSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_newVarSuffix as text
%        str2double(get(hObject,'String')) returns contents of edit_newVarSuffix as a double


% --- Executes during object creation, after setting all properties.
function edit_newVarSuffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_newVarSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_fitWindowSz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fitWindowSz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fitWindowSz as text
%        str2double(get(hObject,'String')) returns contents of edit_fitWindowSz as a double


% --- Executes during object creation, after setting all properties.
function edit_fitWindowSz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fitWindowSz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-----------------------------------------------------------------------------------------------
% Helper functions----------------------
%-----------------------------------------------------------------------------------------------
function assignVars(handles,xc,yc,zc)
handles = guidata(handles.output);
isWriteToCurrentVars = get(handles.radiobutton_useExistingVars, 'Value');
varSuffix = get(handles.edit_newVarSuffix,'String');
isCorrectZ = get(handles.checkbox_correctZDrift,'Value');

xName = handles.handlesPsvGui.settings.varx;
yName = handles.handlesPsvGui.settings.vary;
if isCorrectZ
   zName = handles.handlesPsvGui.settings.varz
end

if ~isWriteToCurrentVars
   xName = [xName,varSuffix];
   yName = [yName,varSuffix];
   if isCorrectZ
      zName = [zName,varSuffix];
   end
end

assignin('base',xName,xc);
handles.handlesPsvGui.settings.varx = xName;
assignin('base',yName,yc);
handles.handlesPsvGui.settings.vary = yName;
if isCorrectZ
   assignin('base',zName,zc);
   handles.handlesPsvGui.settings.varz = zName;
end
%update palmsiever handles
guidata(handles.handlesPsvGui.output,handles.handlesPsvGui);
PALMsiever('reloadData',(handles.handlesPsvGui));
handles.handlesPsvGui = guidata(handles.handlesPsvGui.output);
rows2 = get(handles.handlesPsvGui.pXAxis,'String');
ix = find(cellfun(@(x) strcmp(x,handles.handlesPsvGui.settings.varx),rows2),1); set(handles.handlesPsvGui.pXAxis,'Value',ix);
iy = find(cellfun(@(y) strcmp(y,handles.handlesPsvGui.settings.vary),rows2),1); set(handles.handlesPsvGui.pYAxis,'Value',iy);
iz = find(cellfun(@(z) strcmp(z,handles.handlesPsvGui.settings.varz),rows2),1); set(handles.handlesPsvGui.pZAxis,'Value',iz);
guidata(handles.handlesPsvGui.output,handles.handlesPsvGui);
PALMsiever('redraw',(handles.handlesPsvGui));
