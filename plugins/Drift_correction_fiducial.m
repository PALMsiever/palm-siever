function varargout = Drift_correction_fiducial(varargin)
% DRIFT_CORRECTION_FIDUCIAL MATLAB code for Drift_correction_fiducial.fig
%      DRIFT_CORRECTION_FIDUCIAL, by itself, creates a new DRIFT_CORRECTION_FIDUCIAL or raises the existing
%      singleton*.
%
%      H = DRIFT_CORRECTION_FIDUCIAL returns the handle to a new DRIFT_CORRECTION_FIDUCIAL or the handle to
%      the existing singleton*.
%
%      DRIFT_CORRECTION_FIDUCIAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRIFT_CORRECTION_FIDUCIAL.M with the given input arguments.
%
%      DRIFT_CORRECTION_FIDUCIAL('Property','Value',...) creates a new DRIFT_CORRECTION_FIDUCIAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Drift_correction_fiducial_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Drift_correction_fiducial_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Drift_correction_fiducial

% Last Modified by GUIDE v2.5 03-Dec-2012 17:35:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Drift_correction_fiducial_OpeningFcn, ...
                   'gui_OutputFcn',  @Drift_correction_fiducial_OutputFcn, ...
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


% --- Executes just before Drift_correction_fiducial is made visible.
function Drift_correction_fiducial_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Drift_correction_fiducial (see VARARGIN)

% Choose default command line output for Drift_correction_fiducial
handles.output = hObject;


%get the PALM_Siever_handles
handlesPsvGui = varargin{1};
handles.handlesPsvGui = handlesPsvGui;

handles.roiList = {};
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Drift_correction_fiducial wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Drift_correction_fiducial_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_frameSmoothingWindow_Callback(hObject, eventdata, handles)
% hObject    handle to edit_frameSmoothingWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_frameSmoothingWindow as text
%        str2double(get(hObject,'String')) returns contents of edit_frameSmoothingWindow as a double


% --- Executes during object creation, after setting all properties.
function edit_frameSmoothingWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_frameSmoothingWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on button press in pushbutton_addFiducial.
function pushbutton_addFiducial_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addFiducial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(handles.output);
roiHandle = imrect(handles.handlesPsvGui.axes1);
handles.roiList = {handles.roiList{:}, roiHandle};
guidata(handles.output,handles);


% --- Executes on button press in pushbutton_deleteAllFiducial.
function pushbutton_deleteAllFiducial_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_deleteAllFiducial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(handles.output);
for ii = 1:numel(handles.roiList)
   delete(handles.roiList{ii});
end
handles.roiList={};
guidata(handles.output,handles);



% --- Executes on button press in pushbutton_doDriftCorrection.
function pushbutton_doDriftCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_doDriftCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(handles.output);

isWriteToCurrentVars = get(handles.radiobutton_useExistingVars, 'Value');
varSuffix = get(handles.edit_newVarSuffix,'String');
frameSmoothWindow = str2num(get(handles.edit_frameSmoothingWindow,'String'));
isCorrectZ = get(handles.checkbox_correctZDrift,'Value');
isShowDriftGraph = get(handles.checkbox_showDriftGraph,'Value');

handles.driftTracks = getDriftTracks(handles);
guidata(handles.output,handles);

XPosition=evalin('base',handles.handlesPsvGui.settings.varx);
YPosition=evalin('base',handles.handlesPsvGui.settings.vary);
Frame = evalin('base',handles.handlesPsvGui.settings.varFrame);
if ~isCorrectZ
    [xc,yc,handles.tDrift,handles.xDrift,handles.yDrift] = correctDrift(handles.driftTracks,frameSmoothWindow,Frame, XPosition,YPosition);
   guidata(handles.output,handles);
   assignVars(handles,xc,yc);
else
   ZPosition=evalin('base',handles.handlesPsvGui.settings.varz);
    [xc,yc,handles.tDrift,handles.xDrift,handles.yDrift,zc,handles.zDrift]  = correctDrift(handles.driftTracks,frameSmoothWindow,Frame, XPosition,YPosition,ZPosition);
   guidata(handles.output,handles);
   assignVars(handles,xc,yc,zc);
end


if isShowDriftGraph
   plotDriftGraph(handles);
end

%pushbutton_deleteAllFiducial_Callback(hObject, eventdata, handles)


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

%-----------------------------------------------------------------------
%--GUI HELPER FUNCTIONS -------------------------------------------------
%-----------------------------------------------------------------------
function driftTracks = getDriftTracks(handles)
handles=guidata(handles.output);

isCorrectZ = get(handles.checkbox_correctZDrift,'Value');

nTrack = numel(handles.roiList);
driftTracks = cell(nTrack,1);
for ii = 1:nTrack
   xyLim = getPosition(handles.roiList{ii});
   driftTracks{ii} = getTrack(handles, xyLim,isCorrectZ);
end

function driftTrack = getTrack(handles,xyLim,isCorrectZ);
handles=guidata(handles.output);

xmin = xyLim(1);
ymin = xyLim(2);
width = xyLim(3);
height = xyLim(4);
xmax = xmin + width;
ymax = ymin + height;

XPosition=evalin('base',handles.handlesPsvGui.settings.varx);
YPosition=evalin('base',handles.handlesPsvGui.settings.vary);
Frame = evalin('base',handles.handlesPsvGui.settings.varFrame);

isTrack = XPosition>xmin & XPosition<xmax & YPosition>ymin & YPosition<ymax;
driftTrack.x = XPosition(isTrack);
driftTrack.y = YPosition(isTrack);
driftTrack.t = Frame(isTrack);

if isCorrectZ
   ZPosition=evalin('base',handles.handlesPsvGui.settings.varz);
   driftTrack.z = ZPosition(isTrack);
end

%need to make tracks single valued otherwise smoothing etc wont work
driftTrack = makeSingleValued(driftTrack);

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
PALMsiever('redraw',(handles.handlesPsvGui));
      
function plotDriftGraph(handles)
handles = guidata(handles.output);
if isfield(handles,'hDriftPlot')
   figure(handles.hDriftPlot);
   clf(handles.hDriftPlot);
else
   handles.hDriftPlot = figure;
   set(handles.hDriftPlot,'Name','Drift plot');
end

nSmooth = str2num(get(handles.edit_frameSmoothingWindow,'String'));
isCorrectZ = get(handles.checkbox_correctZDrift,'Value');
tr = handles.driftTracks;

legendCell={};
hold all;
for ii =1: numel(tr)
   iiStr = num2str(ii);
   %X
   plot(tr{ii}.t,tr{ii}.x-tr{ii}.x(1),'-');
   legendCell = {legendCell{:},['X ',iiStr]};
   %Y
   plot(tr{ii}.t,tr{ii}.y-tr{ii}.y(1),'-');
   legendCell = {legendCell{:},['Y ',iiStr]};
   if isCorrectZ
      %z
      plot(tr{ii}.t,tr{ii}.z-tr{ii}.z(1),'-');
      legendCell = {legendCell{:},['Z ',iiStr]};
   end
end

plot(handles.tDrift,handles.xDrift);
plot(handles.tDrift,handles.yDrift);
legendCell = {legendCell{:},'X drift calculated','Y drift calculated'};
if isCorrectZ
   plot(handles.tDrift,handles.zDrift);
   legendCell = {legendCell{:},'Z drift calculated'};
end

legend(legendCell);
xlabel('Time');
ylabel('Drift');
guidata(handles.output,handles);


%-----------------------------------------------------------------------
%--FIDUCIAL ANALYSIS FUNCTIONs-------------------------------------------------
%-----------------------------------------------------------------------
function driftTrackSV = makeSingleValued(driftTrack)
%delete frames with multiple values
if isfield(driftTrack,'z')
   isCorrectZ = true;
else
   isCorrectZ = false;
end

isBadRow =zeros(size(driftTrack.t));
tUn = unique(driftTrack.t);
for ii = 1:numel(tUn)
   isCurFrame = (driftTrack.t==tUn(ii));
   if sum(isCurFrame)>1
      isBadRow(isCurFrame) = 1;
   end
end

driftTrackSV.x = driftTrack.x(~isBadRow);
driftTrackSV.y = driftTrack.y(~isBadRow);
driftTrackSV.t = driftTrack.t(~isBadRow);
if isCorrectZ 
   driftTrackSV.z = driftTrack.z(~isBadRow);
end

function [xc,yc,tDrift,xDrift,yDrift,zc,zDrift]  = correctDrift(driftTracks,nSmooth,t, x,y, z)
if isfield(driftTracks{1},'z')
   isCorrectZ = true;
else
   isCorrectZ = false;
end

tUn = unique(t);
tDrift=tUn;

%get cell of driftTracks from driftTracks
if ~isCorrectZ
   [xTr, yTr,tTr] = getTrackCell(driftTracks);
else
   [xTr, yTr,tTr,zTr] = getTrackCell(driftTracks);
end

%for each axis
xDrift = getDrift(xTr,tTr,tUn,nSmooth);
xc = removeAxisDrift(x,t,xDrift,tUn);
yDrift = getDrift(yTr,tTr,tUn,nSmooth);
yc = removeAxisDrift(y,t,yDrift,tUn);
if isCorrectZ
   zDrift = getDrift(zTr,tTr,tUn,nSmooth);
   zc = removeAxisDrift(z,t,zDrift,tUn);
end

function xDrift = getDrift(xTr,tTr,tUn,nSmooth)
nPts = numel(xTr);
nFrame = numel(tUn);
xAll = zeros(nFrame,nPts);
for ii = 1:numel(xTr)
   xAll(:,ii) = interp1(tTr{ii},xTr{ii},tUn);
   % if xTr is not long enough then interp1 returns NaN - change these to first and last value of fcn
   xAll(tUn<tTr{ii}(1),ii) = xTr{ii}(1);
   xAll(tUn>tTr{ii}(end),ii) = xTr{ii}(end);
end
xAll = moving(xAll,nSmooth);%smoothing
xDrift = mean(xAll,2);
xDrift = xDrift - xDrift(1);


function xc = removeAxisDrift(x,t,xDrift,tUn);
xc =x;
for ii = 1:tUn
   xc(t==tUn) = x(t==tUn) - xDrift(ii);
end

function [xTr, yTr,tTr,zTr] = getTrackCell(driftTracks)

for ii = 1:numel(driftTracks)
   xTr{ii} = driftTracks{ii}.x;
   yTr{ii} = driftTracks{ii}.y;
   tTr{ii} = driftTracks{ii}.t;
   if isfield(driftTracks{ii},'z')
      zTr{ii} = driftTracks{ii}.z;
   end
end

function [y]=moving(x,m,fun)
%MOVING will compute moving averages of order n (best taken as odd)
%
%Usage: y=moving(x,n[,fun])
%where x 	is the input vector (or matrix) to be smoothed. 
%      m 	is number of points to average over (best odd, but even works)
%      y 	is output vector of same length as x
%      fun  (optional) is a custom function rather than moving averages
%
% Note:if x is a matrix then the smoothing will be done 'vertically'.
% 
%
% Example:
%
% x=randn(300,1);
% plot(x,'g.'); 
% hold on;
% plot(moving(x,7),'k'); 
% plot(moving(x,7,'median'),'r');
% plot(moving(x,7,@(x)max(x)),'b'); 
% legend('x','7pt moving mean','7pt moving median','7pt moving max','location','best')
%
% optimized Aslak Grinsted jan2004
% enhanced Aslak Grinsted Apr2007


if m==1
    y=x;
    return
end
if size(x,1)==1
    x=x';
end

if nargin<3
    fun=[];
elseif ischar(fun)
    fun=eval(['@(x)' fun '(x)']);
end

if isempty(fun)

    f=zeros(m,1)+1/m;
    n=size(x,1);
    isodd=bitand(m,1);
    m2=floor(m/2);


    if (size(x,2)==1)
        y=filter(f,1,x);
        y=y([zeros(1,m2-1+isodd)+m,m:n,zeros(1,m2)+n]);
    else
        y=filter2(f,x);
        y(1:(m2-~isodd),:)=y(m2+isodd+zeros(m2-~isodd,1),:);
        y((n-m2+1):end,:)=y(n-m2+zeros(m2,1),:);
    end

else
    y=zeros(size(x));
    sx=size(x,2);
    x=[nan(floor(m*.5),sx);x;nan(floor(m*.5),sx)];
    m1=m-1;
    for ii=1:size(y,1);
        y(ii,:)=fun(x(ii+(0:m1),:));
    end
    
end

return
