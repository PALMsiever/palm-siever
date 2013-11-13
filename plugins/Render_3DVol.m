function varargout = Render_3DVol(varargin)
% RENDER_3DVOL MATLAB code for Render_3DVol.fig
%      RENDER_3DVOL, by itself, creates a new RENDER_3DVOL or raises the existing
%      singleton*.
%
%      H = RENDER_3DVOL returns the handle to a new RENDER_3DVOL or the handle to
%      the existing singleton*.
%
%      RENDER_3DVOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RENDER_3DVOL.M with the given input arguments.
%
%      RENDER_3DVOL('Property','Value',...) creates a new RENDER_3DVOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Render_3DVol_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Render_3DVol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Render_3DVol

% Last Modified by GUIDE v2.5 25-Sep-2013 17:16:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Render_3DVol_OpeningFcn, ...
                   'gui_OutputFcn',  @Render_3DVol_OutputFcn, ...
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


% --- Executes just before Render_3DVol is made visible.
function Render_3DVol_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Render_3DVol (see VARARGIN)

% Choose default command line output for Render_3DVol
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


%get the PALM_Siever_handles
handlesPsvGui = varargin{1};
handles.handlesPsvGui = handlesPsvGui;
handles.sigmaXY = 15;
handles.sigmaZ = 50;

handles.voxelSzXY= 10;
handles.voxelSzZ = 25;

%assign defaults to checkboxes
set(handles.editSigmaXY,'String',num2str(handles.sigmaXY));
set(handles.editSigmaZ,'String',num2str(handles.sigmaZ));
set(handles.editVoxSzXY,'String',num2str(handles.voxelSzXY));
set(handles.editVoxSzZ,'String',num2str(handles.voxelSzZ));


% Update handles structure
guidata(hObject, handles);

updateVolData(handles);
handles = guidata(handles.output);

updateBlur(handles);
handles = guidata(handles.output);
%guess isosurface
isoVal = autoIso(handles.VOL_blur);
handles = guidata(handles.output);
setIsoVal(handles,isoVal);
handles = guidata(handles.output);

updatePlot(handles)
handles = guidata(handles.output);
% Update handles structure
set(0,'CurrentFigure',hObject);
cameratoolbar(hObject,'NoReset');
camproj('perspective')
view(3);
set(gcf,'Renderer','OpenGL')
set(gcf, 'InvertHardCopy', 'off');
set(gcf,'Color','k');
set(gca,'Color','k');
set(gca,'XColor','w');
set(gca,'YColor','w');
set(gca,'ZColor','w');
set(gca,'TickDir','out');
guidata(hObject, handles);

% UIWAIT makes Render_3DVol wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Render_3DVol_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderIsoVal_Callback(hObject, eventdata, handles)
% hObject    handle to sliderIsoVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderVal = get(hObject,'Value');
minIso = handles.minIso ;
maxIso = handles.maxIso ;

isoVal = sliderVal * (maxIso-minIso) + minIso;
setIsoVal(handles,isoVal);
handles = guidata(handles.output);

updatePlot(handles)
handles = guidata(handles.output);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderIsoVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderIsoVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editIsoVal_Callback(hObject, eventdata, handles)
% hObject    handle to editIsoVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIsoVal as text
%        str2double(get(hObject,'String')) returns contents of editIsoVal as a double
handles = guidata(handles.output);
isoVal = str2num(get(handles.editIsoVal,'String'));

minIso = handles.minIso ;
maxIso = handles.maxIso ;
if isoVal > maxIso
   isoVal = maxIso;
elseif isoVal < minIso
   isoVal = minIso;
end

setIsoVal(handles,isoVal);
handles = guidata(handles.output);

updatePlot(handles)
handles = guidata(handles.output);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editIsoVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIsoVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigmaXY_Callback(hObject, eventdata, handles)
% hObject    handle to editSigmaXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSigmaXY as text
%        str2double(get(hObject,'String')) returns contents of editSigmaXY as a double
handles = guidata(handles.output);
handles.sigmaXY = str2num(get(handles.editSigmaXY,'String'));
% Update handles structure
guidata(hObject, handles);

updateVolData(handles);
handles = guidata(handles.output);

updateBlur(handles);
handles = guidata(handles.output);
%guess isosurface
isoVal = autoIso(handles.VOL_blur);
handles = guidata(handles.output);
setIsoVal(handles,isoVal);
handles = guidata(handles.output);

updatePlot(handles);

% --- Executes during object creation, after setting all properties.
function editSigmaXY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigmaXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigmaZ_Callback(hObject, eventdata, handles)
% hObject    handle to editSigmaZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.output);
handles.sigmaZ = str2num(get(handles.editSigmaZ,'String'));
% Update handles structure
guidata(hObject, handles);

updateVolData(handles);
handles = guidata(handles.output);

updateBlur(handles);
handles = guidata(handles.output);
%guess isosurface
isoVal = autoIso(handles.VOL_blur);
handles = guidata(handles.output);
setIsoVal(handles,isoVal);
handles = guidata(handles.output);

updatePlot(handles);


% --- Executes during object creation, after setting all properties.
function editSigmaZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigmaZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editVoxSzXY_Callback(hObject, eventdata, handles)
% hObject    handle to editVoxSzXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.output);
handles.voxelSzXY= str2num(get(handles.editVoxSzXY,'String'));
% Update handles structure
guidata(hObject, handles);

updateVolData(handles);
handles = guidata(handles.output);

updateBlur(handles);
handles = guidata(handles.output);
%guess isosurface
isoVal = autoIso(handles.VOL_blur);
handles = guidata(handles.output);
setIsoVal(handles,isoVal);
handles = guidata(handles.output);

updatePlot(handles);


% --- Executes during object creation, after setting all properties.
function editVoxSzXY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVoxSzXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editVoxSzZ_Callback(hObject, eventdata, handles)
% hObject    handle to editVoxSzZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.output);
handles.voxelSzZ= str2num(get(handles.editVoxSzZ,'String'));
% Update handles structure
guidata(hObject, handles);

updateVolData(handles);
handles = guidata(handles.output);

updateBlur(handles);
handles = guidata(handles.output);
%guess isosurface
isoVal = autoIso(handles.VOL_blur);
handles = guidata(handles.output);
setIsoVal(handles,isoVal);
handles = guidata(handles.output);

updatePlot(handles);


% --- Executes during object creation, after setting all properties.
function editVoxSzZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVoxSzZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%---------------------------------------------------
% --- Executes on button press in pushbutton_autoIso.
function pushbutton_autoIso_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_autoIso (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.output);
isoVal = autoIso(handles.VOL_blur);

setIsoVal(handles,isoVal);
handles = guidata(handles.output);

updatePlot(handles)
handles = guidata(handles.output);
% Update handles structure
guidata(hObject, handles);

%-------------------------------------------------------------------
%-------------------------------------------------------------------
%helper functions
%-------------------------------------------------------------------
%-------------------------------------------------------------------
function updateVolData(handles)
handles = guidata(handles.output);
handlesPsvGui=handles.handlesPsvGui;
%load XY data

X = getX(handlesPsvGui);
Y = getY(handlesPsvGui);
Z = getZ(handlesPsvGui);

subset = getSubset(handlesPsvGui);

X=X(subset);
Y=Y(subset);
Z=Z(subset);

[minX maxX minY maxY] = getBounds(handlesPsvGui);
[minZ maxZ] = getZbounds(handlesPsvGui);


[xEdge, handles.voxelSzXY] = setEdge(minX,maxX,handles.voxelSzXY,'X');
[yEdge, voxSzY] = setEdge(minY,maxY,handles.voxelSzXY,'Y');
if voxSzY < handles.voxelSzXY
   [xEdge, handles.voxelSzXY] = setEdge(minX,maxX,voxSzY,'X');
   warning(['Resetting x voxel size to match updated y, voxSzXY=',num2str(handles.voxelSzXY)]);
end
[zEdge, handles.voxelSzZ] = setEdge(minZ,maxZ,handles.voxelSzZ,'Z'); 

nx = numel(xEdge);
ny = numel(yEdge);
nz = numel(zEdge);

xInt = interp1(xEdge,1:nx,X,'nearest');
yInt = interp1(yEdge,1:ny,Y,'nearest');
zInt = interp1(zEdge,1:nz,Z,'nearest');

%delete any nan points - indicates out of range points
nanPts = isnan(xInt) | isnan(yInt) | isnan(zInt);
xInt(nanPts) = [];
yInt(nanPts) = [];
zInt(nanPts) = [];


handles.VOL = accumarray([xInt, yInt, zInt],1,[nx,ny,nz]);
%%%
handles.xEdge=xEdge;
handles.yEdge=yEdge;
handles.zEdge=zEdge;
[handles.xGrid,handles.yGrid,handles.zGrid] = ndgrid(xEdge,yEdge,zEdge);

set(handles.editVoxSzXY,'String',num2str(handles.voxelSzXY));
set(handles.editVoxSzZ,'String',num2str(handles.voxelSzZ));
guidata(handles.output, handles);

%--------------------------------------
function updateBlur(handles)
handles = guidata(handles.output);
blurXY = handles.sigmaXY/handles.voxelSzXY;
blurZ = handles.sigmaZ/handles.voxelSzZ;
if nodiplib()
   H = fspecial('gaussian',ceil(blurXY*6)/2*2+1,blurXY);
   J = fspecial('gaussian',ceil(blurZ*6)/2*2+1,blurZ);
   VOL_blur = imfilter(handles.VOL,H);
   VOL_blur = imfilter(VOL_blur,reshape(J(round(end/2),:),[1 1 size(J,1)]));
else
   VOL_blur = gaussf(handles.VOL,[blurXY blurXY blurZ]);
end
VOL_blur(VOL_blur<0)=0; %doesn't make sense to have -ive density
handles.VOL_blur = VOL_blur;

minIso = min(handles.VOL_blur(:));
%if minIso<0
%   minIso = 0;
%end
handles.minIso = minIso;

maxIso = max(handles.VOL_blur(:));
%if maxIso<=minIso
%   maxIso=minIso;
%end
handles.maxIso = maxIso;

guidata(handles.output, handles);
%------------------------------------------------
function isoVal = guessIsoVal(VOL_blur)
%guess isosurface
minVol = min(VOL_blur(:));
maxVol = max(VOL_blur(:));
%minVol = max(min(VOL_blur(:)),0);
%maxVol = max(max(VOL_blur(:)),0);
isoVal = (maxVol+minVol)/2;
%------------------------
function setIsoVal(handles,isoVal)
handles = guidata(handles.output);

handles.isoVal = isoVal;
set(handles.editIsoVal,'String',num2str(handles.isoVal));

sliderVal = (isoVal-handles.minIso)/(handles.maxIso-handles.minIso);
set(handles.sliderIsoVal,'Value',sliderVal);
guidata(handles.output, handles);

%--------------------
function updatePlot(handles)
handles = guidata(handles.output);

if isfield(handles,'patch');
   delete(handles.patch);
end

axes(handles.axes1);
% if ~isfield(handles,'light')
%     handles.light = [pi/2 0];
% else
%     pos = get(handles.light,'Position');
%     [az el] = cart2sph(pos(1),pos(2),pos(3));
%     handles.light = [-az -el];
% end
cla
%fv = isosurface(handles.xGrid,handles.yGrid,handles.zGrid,double(handles.VOL_blur),handles.isoVal,handles.zGrid); 
%handles.patch = patch(fv);
[faces verts colors] = isosurface(handles.xGrid,handles.yGrid,handles.zGrid,double(handles.VOL_blur),handles.isoVal,-handles.zGrid); 
handles.patch = patch('Vertices', verts, 'Faces', faces, ... 
    'FaceVertexCData', colors, ... 
    'FaceColor','interp', ... 
    'edgecolor', 'interp');
axis equal;

%set(handles.patch,'FaceColor','green','EdgeColor','none');
set(handles.patch,'EdgeColor','none');
set(handles.patch,'AmbientStrength',0.2,'SpecularStrength',0.2,'DiffuseStrength',1,'SpecularExponent',20);
set(handles.patch,'BackFaceLighting','lit');
lighting gouraud
% handles.light=camlight(handles.light(1),handles.light(2)); 
%view(120, 180-130)
camlight %(90,180)
guidata(handles.output, handles);

%---------------------------------------------------
function [xEdge voxSzX] = setEdge(minX,maxX,voxSz, dimStr)

nPts = 0;
while nPts < 10
   xEdge = minX:voxSz:maxX;
   nPts = numel(xEdge);
   if nPts < 10
      voxSz = voxSz/10;
      warning(['number of points in ',dimStr,'-dimension insufficient, decreasing voxel size in ',dimStr,' to ',num2str(voxSz)]);
   end
end
voxSzX = voxSz;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miCopy_Callback(hObject, eventdata, handles)
% hObject    handle to miCopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ca = gca;
nf = figure;
copyobj(ca,nf);

ss =  get(0,'ScreenSize');
res = 1024;
while res>min(ss(ss>1))
    res = res/2;
end
set(gcf,'Position',[0 0 res res])
set(gca,'Position',[0 0 1 1])

print(nf,'-dbitmap','-noui');
close(nf);
