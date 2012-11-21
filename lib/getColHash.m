function varargout = getColHash(varargin)
% GETCOLHASH MATLAB code for getColHash.fig
%      GETCOLHASH, by itself, creates a new GETCOLHASH or raises the existing
%      singleton*.
%
%      H = GETCOLHASH returns the handle to a new GETCOLHASH or the handle to
%      the existing singleton*.
%
%      GETCOLHASH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETCOLHASH.M with the given input arguments.
%
%      GETCOLHASH('Property','Value',...) creates a new GETCOLHASH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before getColHash_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to getColHash_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help getColHash

% Last Modified by GUIDE v2.5 21-Nov-2012 16:38:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @getColHash_OpeningFcn, ...
                   'gui_OutputFcn',  @getColHash_OutputFcn, ...
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


% --- Executes just before getColHash is made visible.
function getColHash_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to getColHash (see VARARGIN)

% Choose default command line output for getColHash
handles.output = hObject;

handles.data={};%default - same as if cancelled
handles.isCancelled= true;
% Update handles structure
guidata(hObject, handles);

% modify the close function so that it calls the cancel callback
%set(hObject,'CloseRequestFcn',@(varargin) pushbuttonCloseReq_Callback(varargin{:}) );

varNameFile = varargin{1};
varNameGui = varargin{2};
setupTable(handles,varNameFile,varNameGui)
% UIWAIT makes getColHash wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = getColHash_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles)
   varargout{1} =handles.data;
   varargout{2} = handles.isCancelled;
   close(handles.figure1);
else
   isCancelled = true;
   varargout{1} = {};
   varargout{2} = isCancelled;
end


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data = stripEmptyRows(get(handles.uitableVarNames,'Data'));
handles.isCancelled= false;
guidata(handles.output,handles);
uiresume(handles.figure1);



% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data = {};
handles.isCancelled= true;
guidata(handles.output,handles);
uiresume(handles.figure1);


%----------------------------------------------------
function setupTable(handles,varNameFile,varNameGui)

varOptions = ['-',varNameGui(:)'];
nRow = numel(varNameFile);

data = [varNameFile(:),repmat({'-'},nRow,1)];
columneditable =  [false true]; 
set(handles.uitableVarNames,'Data',data);
set(handles.uitableVarNames,'ColumnFormat',{'char',varOptions});
set(handles.uitableVarNames,'ColumnEditable',columneditable);
set(handles.uitableVarNames,'RowName',[]);

%----------------------------------------------------
function colHashOut = stripEmptyRows(colHashIn)

emptyMarker = '-';
colHashOut = colHashIn(~strcmp(colHashIn(:,2),emptyMarker),:);

