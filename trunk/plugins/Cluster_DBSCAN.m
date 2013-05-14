function varargout = Cluster_DBSCAN(varargin)
% CLUSTER_DBSCAN MATLAB code for Cluster_DBSCAN.fig
%      CLUSTER_DBSCAN, by itself, creates a new CLUSTER_DBSCAN or raises the existing
%      singleton*.
%
%      H = CLUSTER_DBSCAN returns the handle to a new CLUSTER_DBSCAN or the handle to
%      the existing singleton*.
%
%      CLUSTER_DBSCAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLUSTER_DBSCAN.M with the given input arguments.
%
%      CLUSTER_DBSCAN('Property','Value',...) creates a new CLUSTER_DBSCAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Cluster_DBSCAN_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Cluster_DBSCAN_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Cluster_DBSCAN

% Last Modified by GUIDE v2.5 14-May-2013 14:49:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Cluster_DBSCAN_OpeningFcn, ...
                   'gui_OutputFcn',  @Cluster_DBSCAN_OutputFcn, ...
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


% --- Executes just before Cluster_DBSCAN is made visible.
function Cluster_DBSCAN_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Cluster_DBSCAN (see VARARGIN)

% Choose default command line output for Cluster_DBSCAN
handles.output = hObject;


%get the PALM_Siever_handles
handlesPsvGui = varargin{1};
handles.handlesPsvGui = handlesPsvGui;
handles.eps = 10;
handles.minPts=10;
handles.useZ = 0;

%assign defaults to checkboxes
set(handles.editMinPts,'String',num2str(handles.minPts));
set(handles.editEps,'String',num2str(handles.eps));
set(handles.checkboxIncludeZ,'Value',handles.useZ);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Cluster_DBSCAN wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Cluster_DBSCAN_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editMinPts_Callback(hObject, eventdata, handles)
% hObject    handle to editMinPts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMinPts as text
%        str2double(get(hObject,'String')) returns contents of editMinPts as a double


% --- Executes during object creation, after setting all properties.
function editMinPts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMinPts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEps_Callback(hObject, eventdata, handles)
% hObject    handle to editEps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEps as text
%        str2double(get(hObject,'String')) returns contents of editEps as a double


% --- Executes during object creation, after setting all properties.
function editEps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxIncludeZ.
function checkboxIncludeZ_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxIncludeZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxIncludeZ


% --- Executes on button press in pushbuttonRunDBSCAN.
function pushbuttonRunDBSCAN_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRunDBSCAN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.output);

%get current input settings
minPts  = str2double(get(handles.editMinPts,'String'));
eps     = str2double(get(handles.editEps,'String'));
useZ = get(handles.checkboxIncludeZ,'Value');

XPos=evalin('base',handles.handlesPsvGui.settings.varx);
YPos=evalin('base',handles.handlesPsvGui.settings.vary);

varDim = size(XPos);


if ~useZ
   X = [XPos(:),YPos(:)];
else
   ZPos=evalin('base',handles.handlesPsvGui.settings.varz);
   X = [XPos(:),YPos(:),ZPos(:)];
end


[dbscan_id,dbscan_type]=dbscan(X,minPts,eps);
dbscan_id = reshape(dbscan_id,varDim(1),varDim(2));
dbscan_type = reshape(dbscan_type,varDim(1),varDim(2));

idName = 'dbscan_id';
typeName = 'dbscan_type';
%export the results to workspace
assignin('base', idName,dbscan_id);
assignin('base', typeName,dbscan_type);

%set the ID column
handles.handlesPsvGui.settings.varID=idName;
guidata(handles.handlesPsvGui.output,handles.handlesPsvGui);
PALMsiever('reloadData',(handles.handlesPsvGui));
handles.handlesPsvGui = guidata(handles.handlesPsvGui.output);
rows2 = get(handles.handlesPsvGui.pID,'String');
iId = find(cellfun(@(z) strcmp(z,handles.handlesPsvGui.settings.varID),rows2),1); 
set(handles.handlesPsvGui.pID,'Value',iId);
PALMsiever('redraw',(handles.handlesPsvGui));
