function varargout = Z_cross_section(varargin)
% Z_CROSS_SECTION MATLAB code for Z_cross_section.fig
%      Z_CROSS_SECTION, by itself, creates a new Z_CROSS_SECTION or raises the existing
%      singleton*.
%
%      H = Z_CROSS_SECTION returns the handle to a new Z_CROSS_SECTION or the handle to
%      the existing singleton*.
%
%      Z_CROSS_SECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Z_CROSS_SECTION.M with the given input arguments.
%
%      Z_CROSS_SECTION('Property','Value',...) creates a new Z_CROSS_SECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Z_cross_section_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Z_cross_section_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Z_cross_section

% Last Modified by GUIDE v2.5 11-Aug-2014 16:45:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Z_cross_section_OpeningFcn, ...
                   'gui_OutputFcn',  @Z_cross_section_OutputFcn, ...
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


% --- Executes just before Z_cross_section is made visible.
function Z_cross_section_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Z_cross_section (see VARARGIN)

% Choose default command line output for Z_cross_section
handles.output = hObject;

%get the PALM_Siever_handles
handlesPsvGui = varargin{1};
handles.handlesPsvGui = handlesPsvGui;
handles.lineStart=[];
handles.lineEnd=[];
handles.lineWidth=200;
handles.crossSectionIsDisplayed = 0;
handles.lineHandle=[];
handles.linePos=[];
handles.startSettings = getCurrentView(handlesPsvGui);

%assign default values to gui components
set(handles.edit_LineThickness1,'String',num2str(handles.lineWidth));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Z_cross_section wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Z_cross_section_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit_LineThickness1_Callback(hObject, eventdata, handles)


function edit_LineThickness1_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_selectLine_Callback(hObject, eventdata, handles)
if handles.crossSectionIsDisplayed %cant select profiles in cross-section mode
   warndlg('Already in cross-section mode, cannot select cross-section!');
else
   if ~isempty(handles.lineHandle)
      delete(handles.lineHandle);
      handles.lineHandle=[];
   end 
   handles.lineHandle = imline(handles.handlesPsvGui.axes1);
   guidata(hObject, handles);
end

function pushbutton_resetView_Callback(hObject, eventdata, handles)
if handles.crossSectionIsDisplayed 
   resetToXyView(handles);
   handles.crossSectionIsDisplayed =0;
   guidata(hObject, handles);
end
%-------------------------------------------------
%-------------------------------------------------
function startSettings = getCurrentView(handlesPsvGui)
startSettings.xName =handlesPsvGui.settings.varx;
startSettings.yName =handlesPsvGui.settings.vary;
startSettings.zName =handlesPsvGui.settings.varz;


%-------------------------------------------------
%-------------------------------------------------
function pushbutton_crossSectionView_Callback(hObject, eventdata, handles)
if ~handles.crossSectionIsDisplayed 
   if isempty(handles.lineHandle)
      warndlg('No cross-section region selected, cannot plot cross-section.');
   else
      handles.linePos = getPosition(handles.lineHandle);
      %get rid of the line
      delete(handles.lineHandle);
      handles.lineHandle=[];
      %get the crossSection thickness
      handles.lineWidth = str2num(get(handles.edit_LineThickness1,'String'));
      %save the current data
      guidata(handles.output,handles);
      handles.handlesPsvGui=guidata(handles.handlesPsvGui.output);%update the PS handles
      handles.startSettings = getCurrentView(handles.handlesPsvGui);
      %switch to cross section view
      transformToCrossSectionView(handles);
      handles.crossSectionIsDisplayed =1;
      guidata(hObject, handles);
   end
end

%-------------------------------------------------
%-------------------------------------------------
function pushbutton_clearSelection_Callback(hObject, eventdata, handles)
if ~isempty(handles.lineHandle)
   delete(handles.lineHandle);
   handles.lineHandle=[];
end 
guidata(hObject, handles);
%-------------------------------------------------
%-------------------------------------------------
function transformToCrossSectionView(handles)
%update handlesPsvGui
handlesPsvGui = guidata(handles.handlesPsvGui.output);

xyPos = handles.linePos;
lineWidth = handles.lineWidth;

Dx = (xyPos(2,1)-xyPos(1,1));
Dy = (xyPos(2,2)-xyPos(1,2));
X0 = [xyPos(1,1),xyPos(1,2)];
lineLength = sqrt(Dx^2+Dy^2);
lineAngle = atan2(Dy,Dx); %in radians

%get the current xyz data
varNames = get(handlesPsvGui.tParameters,'RowName');
xName =handlesPsvGui.settings.varx;
yName =handlesPsvGui.settings.vary;
zName =handlesPsvGui.settings.varz;

x = getX(handlesPsvGui);
y = getY(handlesPsvGui);
z = getZ(handlesPsvGui);

%rotate the data parallel to x axis
R = [cos(-lineAngle),-sin(-lineAngle);...
      sin(-lineAngle),cos(-lineAngle)];

[XYRot]=R*[x';y'];
X0Rot = R*X0';
xRot = XYRot(1,:)' -X0Rot(1) ;
yRot = XYRot(2,:)' - X0Rot(2);
% then flip z & y ax s.t. y'=z & z'=-y. 
along_crossSec= xRot;
across_crossSec =-yRot;
z_crossSec  = -z ;
%update the xyz data
assignin('base','along_crossSec',along_crossSec);
assignin('base','across_crossSec',across_crossSec);
assignin('base','z_crossSec',z_crossSec);

PALMsiever('reloadData',handlesPsvGui);
%update handlesPsvGui
handlesPsvGui = guidata(handles.handlesPsvGui.output);

handlesPsvGui = setVar(handlesPsvGui,'along_crossSec','x');
handlesPsvGui = setVar(handlesPsvGui,'z_crossSec','y');
handlesPsvGui = setVar(handlesPsvGui,'across_crossSec','z');

% apply the filter
alongMin = 0; alongMax = lineLength;
acrossMin = -lineWidth/2; acrossMax = +lineWidth/2;
handlesPsvGui = setXbounds(handlesPsvGui,[alongMin,alongMax]);
handlesPsvGui = setZbounds(handlesPsvGui,[acrossMin,acrossMax]);

PALMsiever('redraw',handlesPsvGui);
handlesPsvGui = guidata(handles.handlesPsvGui.output);
PALMsiever('resizeX1to1',handlesPsvGui);
handlesPsvGui = guidata(handles.handlesPsvGui.output);
PALMsiever('updateAutoMax',handlesPsvGui);
handlesPsvGui = guidata(handles.handlesPsvGui.output);
guidata(handlesPsvGui.output,handlesPsvGui);

%-------------------------------------------------
%-------------------------------------------------
function  resetToXyView(handles)
startSettings = handles.startSettings;
handlesPsvGui=guidata(handles.handlesPsvGui.output);

%reset the limits of the data
varNames = get(handlesPsvGui.tParameters,'RowName');
along_crossSecName =handlesPsvGui.settings.varx;
across_crossSecName =handlesPsvGui.settings.vary;
z_crossSecName =handlesPsvGui.settings.varz;
along_crossSec = getX(handlesPsvGui);
z_crossSec= getY(handlesPsvGui);
across_crossSec = getZ(handlesPsvGui);
alongMin = min(along_crossSec);
alongMax = max(along_crossSec);
acrossMin = min(across_crossSec);
acrossMax = max(across_crossSec);

handlesPsvGui = setXbounds(handlesPsvGui,[alongMin,alongMax]);
handlesPsvGui = setZbounds(handlesPsvGui,[acrossMin,acrossMax]);

%switch the plotted variables back to the xy view
handlesPsvGui = setVar(handlesPsvGui,startSettings.xName,'x');
handlesPsvGui = setVar(handlesPsvGui,startSettings.yName,'y');
handlesPsvGui = setVar(handlesPsvGui,startSettings.zName,'z');

PALMsiever('redraw',handlesPsvGui);
handlesPsvGui = guidata(handles.handlesPsvGui.output);
PALMsiever('resizeX1to1',handlesPsvGui);
handlesPsvGui = guidata(handles.handlesPsvGui.output);
PALMsiever('updateAutoMax',handlesPsvGui);
handlesPsvGui = guidata(handles.handlesPsvGui.output);
guidata(handlesPsvGui.output,handlesPsvGui);

