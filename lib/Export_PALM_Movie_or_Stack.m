function varargout = Export_PALM_Movie_or_Stack(varargin)
% EXPORT_PALM_MOVIE_OR_STACK MATLAB code for Export_PALM_Movie_or_Stack.fig
%      EXPORT_PALM_MOVIE_OR_STACK, by itself, creates a new EXPORT_PALM_MOVIE_OR_STACK or raises the existing
%      singleton*.
%
%      H = EXPORT_PALM_MOVIE_OR_STACK returns the handle to a new EXPORT_PALM_MOVIE_OR_STACK or the handle to
%      the existing singleton*.
%
%      EXPORT_PALM_MOVIE_OR_STACK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORT_PALM_MOVIE_OR_STACK.M with the given input arguments.
%
%      EXPORT_PALM_MOVIE_OR_STACK('Property','Value',...) creates a new EXPORT_PALM_MOVIE_OR_STACK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Export_PALM_Movie_or_Stack_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Export_PALM_Movie_or_Stack_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Export_PALM_Movie_or_Stack

% Last Modified by GUIDE v2.5 08-Aug-2014 15:07:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Export_PALM_Movie_or_Stack_OpeningFcn, ...
                   'gui_OutputFcn',  @Export_PALM_Movie_or_Stack_OutputFcn, ...
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


% --- Executes just before Export_PALM_Movie_or_Stack is made visible.
function Export_PALM_Movie_or_Stack_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Export_PALM_Movie_or_Stack (see VARARGIN)

% Choose default command line output for Export_PALM_Movie_or_Stack
handles.output = hObject;

%get the PALM_Siever_handles
handlesPsvGui = varargin{1};
handles.handlesPsvGui = handlesPsvGui;
handles.tAxisCell={''};
handles.tAxis= '';
handles.tStep =100;
handles.useSlideWindow = 0;
handles.slideWindowSz = 1000;

%assign defaults to checkboxes
set(handles.editTStep,'String',num2str(handles.tStep));
set(handles.editSlideWindowSz,'String',num2str(handles.slideWindowSz));
set(handles.checkbox_SmthWindow,'Value',handles.useSlideWindow);

%set the dropdown menu
[rows2 data] = getVariables(handles.handlesPsvGui,handles.handlesPsvGui.settings.N);
handles.tAxisCell=rows2;
handles.tAxis =handles.handlesPsvGui.settings.varFrame;
set(handles.axisSelect1,'String',handles.tAxisCell);
set(handles.axisSelect1,'Value',strmatch(handles.tAxis,rows2));


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Export_PALM_Movie_or_Stack wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Export_PALM_Movie_or_Stack_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbutton_ExportMovie_Callback(hObject, eventdata, handles)
handlesPsvGui = handles.handlesPsvGui;
%update params
handles = updateParams(handles);

if isPoints(handlesPsvGui)
    msgbox('Does not work with scatterplot. Try KDE or Histogram instead');
else
   [filename path]=uiputfile('*.tif');
   if filename
      density = renderExportStack(handles);

      minC = str2double(get(handlesPsvGui.minC,'String'));
      maxC = str2double(get(handlesPsvGui.maxC,'String'));

      [minX maxX minY maxY] = getBounds(handlesPsvGui);
      res = getRes(handlesPsvGui);
      
      pxx = (maxX-minX)/res; pxy = (maxY-minY)/res;

      physDims.dimensions = pxx;
      physDims.dimensionUnits = 'nm';
      
      % To 16-bits
      density = uint16((density-minC)*2^16/(maxC-minC)); 
      
      nslices = size(density,3);
      for slice = 1:size(density,3)
         if slice ==1
            writeMode = 'overwrite';
         else
            writeMode = 'append';
         end

         imwrite(squeeze(density(:,:,slice)), fullfile(path,filename),'TIFF','WriteMode',writeMode);
      end

      delete(handles.figure1);
   end
end

function axisSelect1_Callback(hObject, eventdata, handles)


function axisSelect1_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editTStep_Callback(hObject, eventdata, handles)


function editTStep_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editSlideWindowSz_Callback(hObject, eventdata, handles)


function editSlideWindowSz_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_SmthWindow_Callback(hObject, eventdata, handles)


function res = isPoints(handles)
res = strcmp(getSelectedRendering(handles),'Points');

%------------------------
%------------------------
function stack= renderExportStack(handles)
handlesPsvGui = handles.handlesPsvGui;
TData=evalin('base',handles.tAxis);

minT = min(TData);
maxT = max(TData);

tStep = handles.tStep;
if handles.useSlideWindow
   slideWindowSz = handles.slideWindowSz;
else
   slideWindowSz = 0;
end


sliceStart = minT:tStep:maxT;
nslices = numel(sliceStart);

res = PALMsiever('getRes',handlesPsvGui);
stack = zeros(res, res, nslices);

for ii=1:nslices
    from = sliceStart(ii);
    to = sliceStart(ii)+tStep+slideWindowSz;
    setMin(handlesPsvGui,handles.tAxis,from);
    setMax(handlesPsvGui,handles.tAxis,to);
    
    frame = zeros(res,res);

    PALMsiever('redraw',handlesPsvGui);
    
    if sum(getSubset(handlesPsvGui))>0
        pdf = getappdata(0,'KDE');
        frame(1:size(pdf{3},1),1:size(pdf{3},2)) = pdf{3};
    end
    
    stack(:,:,ii) = frame;
end

%-----------------------
%-----------------------
function handlesOut = updateParams(handles)
handles.tAxis= handles.tAxisCell{get(handles.axisSelect1,'Value')};
handles.tStep =str2num(get(handles.editTStep,'String'));
handles.useSlideWindow = get(handles.checkbox_SmthWindow,'Value');
handles.slideWindowSz = str2num(get(handles.editSlideWindowSz,'String'));
handlesOut = handles;

