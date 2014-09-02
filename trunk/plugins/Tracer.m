function varargout = Tracer(varargin)
% TRACER MATLAB code for Tracer.fig
%      TRACER, by itself, creates a new TRACER or raises the existing
%      singleton*.
%
%      H = TRACER returns the handle to a new TRACER or the handle to
%      the existing singleton*.
%
%      TRACER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACER.M with the given input arguments.
%
%      TRACER('Property','Value',...) creates a new TRACER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Tracer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Tracer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Tracer

% Last Modified by GUIDE v2.5 18-Aug-2014 17:59:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Tracer_OpeningFcn, ...
                   'gui_OutputFcn',  @Tracer_OutputFcn, ...
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


% --- Executes just before Tracer is made visible.
function Tracer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Tracer (see VARARGIN)

% Choose default command line output for Tracer
handles.output = hObject;

% Add the handles of PS
if numel(varargin)<1
    error('Tracer can only be used as a plugin to PALMsiever')
end

handles.PSG = varargin{1};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Tracer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Tracer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbShowTrace.
function pbShowTrace_Callback(hObject, eventdata, handles)
% hObject    handle to pbShowTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
showTrace(handles.PSG);


% --- Executes on button press in pbTrace.
function pbTrace_Callback(hObject, eventdata, handles)
% hObject    handle to pbTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

subset = getSubset(handles.PSG);
X = getX(handles.PSG);
Y = getY(handles.PSG);

r0 = str2double(get(handles.eRadius,'String'));
step = str2double(get(handles.eStep,'String'));

f0 = gcf;
set(0,'CurrentFigure',getParentFigure(handles.PSG.axes1))

%% Choose starting point and first waypoint for initial direction
P0 = ginput(1);
P1 = ginput(1); 
set(0,'CurrentFigure',f0);

%% Tracing
dir0 = (P1-P0)'; dir0 = dir0/sqrt(sumsqr(dir0));

Trace = trace(X,Y,P0,dir0,r0,step);

assignin('base','Trace',Trace)

showTrace(handles.PSG)



% --- Executes on button press in pbSaveTrace.
function pbSaveTrace_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename path]=uiputfile('*.mat');
Trace = evalin('base','Trace');
if filename
    save(fullfile(path,filename),'Trace');
end

% --- Executes on button press in pbLoadTrace.
function pbLoadTrace_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename path]=uigetfile('*.mat');
if filename
    S=load(fullfile(path,filename),'Trace');
    assignin('base','Trace',S.Trace);
    showTrace(handles.PSG)
end

% --- Executes on button press in pbHistogram.
function pbHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to pbHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Trace = evalin('base','Trace');
subset = evalin('base','subset');
X=evalin('base',handles.PSG.settings.varx); X=X(subset);
Y=evalin('base',handles.PSG.settings.vary); Y=Y(subset);
nbins = str2double(get(handles.eBins,'String'));
r = str2double(get(handles.eRadius,'String'));

fit_id = get(handles.pmFitFunction,'Value');

[ C b ] = trace_histogram(Trace,X,Y,r,nbins);
a = sum(C); % Get the total histogram

switch fit_id
    case 1
        Trace_Histogram.C = C;
        Trace_Histogram.centers = b;
        assignin('base','Trace_Histogram',Trace_Histogram);

        figure;
            h = bar(b,a,1,'EdgeColor','none','FaceColor',[.8 .8 .8]); 
    case 2
        figure;
            h = bar(b,a,1,'EdgeColor','none','FaceColor',[.8 .8 .8]);
            hold;
            fit = sg_fit(b',a'); for s = strsplit(evalc('fit'),char(10)); logger(s{1}); end
            plot(fit); legend off;

    case 3
        figure;
            h = bar(b,a,1,'EdgeColor','none','FaceColor',[.8 .8 .8]); 
            hold;
            fit = dg_fit(b',a'); for s = strsplit(evalc('fit'),char(10)); logger(s{1}); end
            plot(fit); legend off;
end
xlabel('Distance from center line');
ylabel('Points per segment'); 
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0 0 2.5 2.5]);   


% --- Executes on selection change in pmFitFunction.
function pmFitFunction_Callback(hObject, eventdata, handles)
% hObject    handle to pmFitFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmFitFunction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmFitFunction


% --- Executes during object creation, after setting all properties.
function pmFitFunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmFitFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function showTrace(handles)

Trace = evalin('base','Trace');

if numel(Trace)<2
    msgbox('No trace found. Try increasing the radius or the length.','modal')
    return
end

set(0,'CurrentFigure',getParentFigure(handles.axes1));
set(getParentFigure(handles.axes1),'CurrentAxes',handles.axes1);
%hold on;
line(Trace(:,1)',Trace(:,2)','Marker','+','Color','g');

function fig = getParentFigure(fig)
% if the object is a figure or figure descendent, return the
% figure. Otherwise return [].
while ~isempty(fig) & ~strcmp('figure', get(fig,'type'))
  fig = get(fig,'parent');
end



function eRadius_Callback(hObject, eventdata, handles)
% hObject    handle to eRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eRadius as text
%        str2double(get(hObject,'String')) returns contents of eRadius as a double


% --- Executes during object creation, after setting all properties.
function eRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eStep_Callback(hObject, eventdata, handles)
% hObject    handle to eStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eStep as text
%        str2double(get(hObject,'String')) returns contents of eStep as a double


% --- Executes during object creation, after setting all properties.
function eStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eBins_Callback(hObject, eventdata, handles)
% hObject    handle to eBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eBins as text
%        str2double(get(hObject,'String')) returns contents of eBins as a double


% --- Executes during object creation, after setting all properties.
function eBins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbCropTrace.
function pbCropTrace_Callback(hObject, eventdata, handles)
% hObject    handle to pbCropTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

r = str2double(get(handles.PSG.radius,'String'));

f0 = gcf;
set(0,'CurrentFigure',getParentFigure(handles.PSG.axes1))
P0 = ginput(1);
set(0,'CurrentFigure',f0);

Trace0 = evalin('base','Trace');
Trace = Trace0;

% Find the closest trace point to the cursor and crop until there
iLast = find((Trace(:,1)-P0(1)).^2+(Trace(:,2)-P0(2)).^2<r*r);
assignin('base','Trace',Trace(1:iLast,:));

% Draw the cropped trace
PALMsiever('redraw',handles.PSG);
PALMsiever('miShowTrace_Callback',handles.PSG,[],[]);

ButtonName = questdlg('Do you confirm this crop?', ...
                     'Crop confirm', ...
                     'OK','Cancel','Cancel');
switch ButtonName,
    case 'Cancel',
        % Revert
        assignin('base','Trace',Trace0);
        
        PALMsiever('redraw',handles.PSG);
        PALMsiever('miShowTrace_Callback',handles.PSG,[],[]);
end
