function varargout = Drift_correction_prePostImages(varargin)
% DRIFT_CORRECTION_PREPOSTIMAGES MATLAB code for Drift_correction_prePostImages.fig
%      DRIFT_CORRECTION_PREPOSTIMAGES, by itself, creates a new DRIFT_CORRECTION_PREPOSTIMAGES or raises the existing
%      singleton*.
%
%      H = DRIFT_CORRECTION_PREPOSTIMAGES returns the handle to a new DRIFT_CORRECTION_PREPOSTIMAGES or the handle to
%      the existing singleton*.
%
%      DRIFT_CORRECTION_PREPOSTIMAGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRIFT_CORRECTION_PREPOSTIMAGES.M with the given input arguments.
%
%      DRIFT_CORRECTION_PREPOSTIMAGES('Property','Value',...) creates a new DRIFT_CORRECTION_PREPOSTIMAGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Drift_correction_prePostImages_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Drift_correction_prePostImages_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Drift_correction_prePostImages

% Last Modified by GUIDE v2.5 29-Aug-2014 16:44:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Drift_correction_prePostImages_OpeningFcn, ...
                   'gui_OutputFcn',  @Drift_correction_prePostImages_OutputFcn, ...
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


% --- Executes just before Drift_correction_prePostImages is made visible.
function Drift_correction_prePostImages_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Drift_correction_prePostImages (see VARARGIN)

% Choose default command line output for Drift_correction_prePostImages
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%get the PALM_Siever_handles
handlesPsvGui = varargin{1};
handles.handlesPsvGui = handlesPsvGui;

handles.preAcqImPath= [];
handles.postAcqImPath= [];
handles.tformPath= [];
handles.useExistingVar=true;
handles.newVarSuffix='_cor';
handles.srPixSz= [117,126];

set(handles.radiobutton_varNames_useCur,'Value',handles.useExistingVar);
set(handles.edit_varNameSuffix,'String',handles.newVarSuffix);
set(handles.edit_srPixSzX,'String',num2str(handles.srPixSz(1)));
set(handles.edit_srPixSzY,'String',num2str(handles.srPixSz(2)));

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes Drift_correction_prePostImages wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Drift_correction_prePostImages_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbutton_doDriftCorrect_Callback(hObject, eventdata, handles)
%update the parameters
handles.preAcqImPath= get(handles.edit_preAcqImPath,'String');
handles.postAcqImPath= get(handles.edit_postAcqImPath,'String');
handles.tformPath=  get(handles.edit_tformPath,'String');
handles.useExistingVar=get(handles.radiobutton_varNames_useCur,'Value');
handles.newVarSuffix=get(handles.edit_varNameSuffix,'String');
handles.srPixSz(1)=str2num(get(handles.edit_srPixSzX,'String'));
handles.srPixSz(2)=str2num(get(handles.edit_srPixSzY,'String'));

%load the tform
data = load(handles.tformPath);
tformPhToFl = data.tformAffinePhToFl;

%load the drift images
imDriftPre = imread(handles.preAcqImPath);
imDriftPost = imread(handles.postAcqImPath);

%load the xyt data
x=evalin('base',handles.handlesPsvGui.settings.varx);
y=evalin('base',handles.handlesPsvGui.settings.vary);
f= evalin('base',handles.handlesPsvGui.settings.varFrame);

%drift correct
[xC,yC, xDriftNm,yDriftNm]= driftCorrectWithPrePostImages(x,y,f,imDriftPre,imDriftPost,handles.srPixSz, tformPhToFl);

%apply correction
assignVars(handles,xC,yC);
fprintf('\nX-drift: %g, Y-drift: %g\n',xDriftNm,yDriftNm);

function edit_preAcqImPath_Callback(hObject, eventdata, handles)


function edit_preAcqImPath_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_selectPreImPath_Callback(hObject, eventdata, handles)
FilterSpec='*.tif';
DialogTitle = 'Select pre acquisition image';
[FileName,PathName] = uigetfile(FilterSpec,DialogTitle); 
if FileName~=0
   fpath = fullfile(PathName,FileName);
   handles.preAcqImPath = fpath;
   set(handles.edit_preAcqImPath,'String',handles.preAcqImPath);
end

function edit_postAcqImPath_Callback(hObject, eventdata, handles)


function edit_postAcqImPath_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_selectPostImPath_Callback(hObject, eventdata, handles)
FilterSpec='*.tif';
DialogTitle = 'Select post acquisition image';
[FileName,PathName] = uigetfile(FilterSpec,DialogTitle); 
if FileName~=0
   fpath = fullfile(PathName,FileName);
   handles.postAcqImPath = fpath;
   set(handles.edit_postAcqImPath,'String',handles.postAcqImPath);
end

function edit_tformPath_Callback(hObject, eventdata, handles)

function edit_tformPath_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_selectTformPath_Callback(hObject, eventdata, handles)
FilterSpec='*.mat';
DialogTitle = 'Select image transform file';
[FileName,PathName] = uigetfile(FilterSpec,DialogTitle); 
if FileName~=0
   fpath = fullfile(PathName,FileName);
   handles.tformPath= fpath;
   set(handles.edit_tformPath,'String',handles.tformPath);
end



function edit_varNameSuffix_Callback(hObject, eventdata, handles)


function edit_varNameSuffix_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function assignVars(handles,xc,yc)
handles = guidata(handles.output);
isWriteToCurrentVars = get(handles.radiobutton_varNames_useCur, 'Value');
varSuffix = get(handles.edit_varNameSuffix,'String');

xName = handles.handlesPsvGui.settings.varx;
yName = handles.handlesPsvGui.settings.vary;

if ~isWriteToCurrentVars
   xName = [xName,varSuffix];
   yName = [yName,varSuffix];
end

assignin('base',xName,xc);
handles.handlesPsvGui.settings.varx = xName;
assignin('base',yName,yc);
handles.handlesPsvGui.settings.vary = yName;
%update palmsiever handles
guidata(handles.handlesPsvGui.output,handles.handlesPsvGui);
PALMsiever('reloadData',(handles.handlesPsvGui));
handles.handlesPsvGui = guidata(handles.handlesPsvGui.output);
rows2 = get(handles.handlesPsvGui.pXAxis,'String');
ix = find(cellfun(@(x) strcmp(x,handles.handlesPsvGui.settings.varx),rows2),1); set(handles.handlesPsvGui.pXAxis,'Value',ix);
iy = find(cellfun(@(y) strcmp(y,handles.handlesPsvGui.settings.vary),rows2),1); set(handles.handlesPsvGui.pYAxis,'Value',iy);
guidata(handles.handlesPsvGui.output,handles.handlesPsvGui);
PALMsiever('redraw',(handles.handlesPsvGui));
  


function edit_srPixSzX_Callback(hObject, eventdata, handles)


function edit_srPixSzX_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_srPixSzY_Callback(hObject, eventdata, handles)


function edit_srPixSzY_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------
function [xC,yC, xDriftNm,yDriftNm]= driftCorrectWithPrePostImages(x,y,f,imDriftPre,imDriftPost,pixSzPALM,tformPhToFl);
% function [xC,yC, xDriftNm,yDriftNm]= driftCorrectPH(x,y,f,imDriftPre,imDriftPost,pixSzImDrift);
%linear 2D drift correction based on drift on comparison of pre and post acquistion images
% normally phase contrast images, in principle works for any input that reflects the position of the sample
% and has decent contrast
% INPUTS
% pixSzImDrift: can be either 1D pixel sz or [pixSzX, pixSzY]

%assume for simplicity that the last frame recorded is 
%approximately equal to the last frame localized
nFrameFl = max(f);

% calculate the drift 
[xPhDriftPix yPhDriftPix] = getDriftPH(imDriftPre,imDriftPost);
[xDriftNm, yDriftNm] = convertDriftToPalmCoord(tformPhToFl,xPhDriftPix,yPhDriftPix,pixSzPALM);

%apply the drift correction
frameDriftX = @(fr) fr* xDriftNm/(nFrameFl-1);
frameDriftY = @(fr) fr* yDriftNm/(nFrameFl-1);

xC = x - frameDriftX(f);
yC = y - frameDriftY(f);
%--------------------------------------------------------------------
function [xDriftNm, yDriftNm] = convertDriftToPalmCoord(tformPhToFl,xPhDriftPix,yPhDriftPix,pixSzPALM);

xIn = [0;xPhDriftPix];
yIn = [0;yPhDriftPix];
[xOut,yOut] = tformfwd(tformPhToFl,xIn,yIn);
xDriftPix = xOut(2)-xOut(1);
yDriftPix = yOut(2)-yOut(1);
xDriftNm = xDriftPix*pixSzPALM(1);
yDriftNm = yDriftPix*pixSzPALM(2);

%--------------------------------------------------------------------
function [xDriftPix yDriftPix] = getDriftPH(phPre,phPost); 
%Use image cross correlation  to get the drift between two images

phPre = double(phPre);
phPost= double(phPost);
[driftN, corAmplitudeN] = getImageDrift(phPre,phPost);
xDriftPix = driftN(1);
yDriftPix = driftN(2);
%--------------------------------------------
function [drift, corAmplitude] = getImageDrift(templateIm,featureIm, windowSize)
% spatial cross correlation function = SCCF
if ~exist('windowSize','var')
  windowSize= 10; %seems like a pretty reasonable number
end

%calculate the correlation function
% C is the image of the correlation function. 
%zeroCoord is the [i,j] coordinate corresponding to zero displacement in
% the correlation function 
[C,zeroCoord] = corrfunc(templateIm,featureIm);


% extract the drift by fitting a gaussian to the SCCF
% careful with (i,j) vs (x,y)!!

[corrMaxPos corAmplitude] =   getPosGauss2d(C,zeroCoord,windowSize);
%[corrMaxPos corAmplitude] =   getPeakPosCentroid(C,zeroCoord,windowSize); %this does not seem sufficiently accurate!
drift = zeroCoord  - corrMaxPos;

%%OPTIONAL PLOTTING OF THE CORRELATION IMAGES
%subplot(3,1,1)
%imagesc(templateIm);
%subplot(3,1,2)
%imagesc(featureIm);
%subplot(3,1,3)
%imagesc(C);

%%-------------------------------
%-------------------------------------------------------------
function [G,zeroCoord] = corrfunc(template,feature)
% July 9, 2003
% David Kolin
% 18/03/11
% Seamus Holden
% 1)Minor modification 2011 SH to output zeroCoordinate in ICS image
% 2) 110318 Now a very heavily modified version of original function. Does cross not auto correlation
% NB:template and feature should be same size
% zeroCoord is (x,y) coordinates, not (i,j)!
template=double(template);
feature=double(feature); 

% Calculates 2D correlation functions for each z slice of a given 3D matrix (imgser)
% Output as a 3D matrix with same dimensions as imgser
G = zeros(size(template)); % Preallocates matrix

% Calculates corr func
%autocorrelation:
%%G = (fftshift(real(ifft2(fft2(template).*conj(fft2(template)))))) ...
%%        /(mean(template(:))^2*size(template,1)*size(template,2) ) ...
%%      -1;

%cross correlation
G = (fftshift(real(ifft2(fft2(template).*conj(fft2(feature))))))/...
		( (mean(template(:))*mean(feature(:))) * size(template,1)*size(template,2) ) ...
		- 1;
% SH mod
% make sure that you know where the zero coordinate is from the DFT
% so that we can calculate absolute drift
imsize = size(template);
zeroCoordX = (floor(imsize(2)/2)+1);
zeroCoordY = (floor(imsize(1)/2)+1);
zeroCoord = [ zeroCoordX,zeroCoordY];

%----------------------------------------------------------------------------------------------
