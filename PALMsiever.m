%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
%
function varargout = PALMsiever(varargin)
% PALMSIEVER M-file for PALMsiever.fig
%      PALMSIEVER, by itself, creates a new PALMSIEVER or raises the existing
%      singleton*.
%
%      H = PALMSIEVER returns the handle to a new PALMSIEVER or the handle to
%      the existing singleton*.
%
%      PALMSIEVER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PALMSIEVER.M with the given input
%      arguments.
%
%      PALMSIEVER('Property','Value',...) creates a new PALMSIEVER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PALMsiever_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PALMsiever_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%   Author:     Thomas Pengo, 2012
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PALMsiever

if ~isappdata(0,'ps_initialized') || ~getappdata(0,'ps_initialized')
    evalin('base','palmsiever_setup');
end

% Last Modified by GUIDE v2.5 27-Aug-2015 18:46:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PALMsiever_OpeningFcn, ...
                   'gui_OutputFcn',  @PALMsiever_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

try
    %watch_on
    if nargout
        try
            javaaddpath(fileparts(which('AreaAnalysis')));
            ImageSelection([])
        catch err
            errordlg(['Could not load ImageSelection class. No ''Copy''. Please put '...
                'ImageSelection.class in the same directory as the AreaAnalysis'])
        end

        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    %watch_off
catch myerr
    %watch_off
    errordlg(myerr.message);
    rethrow(myerr)
end
% End initialization code - DO NOT EDIT

function watch_on
if isappdata(0,'self')
    set(getappdata(0,'self'),'Pointer','watch');
    drawnow
end

function watch_off
if isappdata(0,'self')
    set(getappdata(0,'self'),'Pointer','arrow');
    drawnow
end


% --- Executes just before PALMsiever is made visible.
function PALMsiever_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PALMsiever (see VARARGIN)
assignin('base','PS_FIGURE',handles.figure1);

% Add 'range' function to base
assignin('base','range',@(x) max(x)-min(x))
assignin('base','drawing','false')

% Choose default command line output for PALMsiever
handles.output = hObject;


if ~isempty(varargin)
    handles.settings.varx=varargin{1};
    handles.settings.vary=varargin{2};
    handles.settings.varz=varargin{1}; % Change?
    handles.settings.sigmax=['Dummy_sigma_' varargin{1}];
    handles.settings.sigmay=['Dummy_sigma_' varargin{2}];
    assignin('base',handles.settings.sigmax,ones(size(evalin('base',varargin{1}))));
    assignin('base',handles.settings.sigmay,ones(size(evalin('base',varargin{2}))));
    handles.settings.N=evalin('base',['length(' varargin{1} ')']);   
else
    N = 1000; R = 1000; s = 20;sZ = 100;
    T = (1:N)';
    X = sin(T)*R;
    Y = cos(T)*R;

    X = X+randn(1000,1)*s;
    Y = Y+randn(1000,1)*s;
    Z = randn(1000,1)*sZ;
    sigmax = s*ones(size(X));
    sigmay = s*ones(size(Y));
    
    %workaround for calling palmsiever without arguments
    %nPts = 100;
    %X = rand(nPts,1); Y=X;sigmax = X;sigmay=X;
    %T = (1:nPts)';
    assignin('base','X',X);assignin('base','Y',Y);assignin('base','T',T);assignin('base','Z',Z);
    assignin('base','Dummy_sigma_X',sigmax);assignin('base','Dummy_sigma_Y',sigmay);
    handles.settings.varx='X';
    handles.settings.vary='Y';
    handles.settings.varz='Z';
    handles.settings.varFrame ='T';
    handles.settings.sigmax='Dummy_sigma_X';
    handles.settings.sigmay='Dummy_sigma_Y';
    handles.settings.N=size(X,1);
    
    % OMERO session details
    handles.session = [];
    handles.client = [];
    handles.userid = [];
end
guidata(handles.output, handles);
handles=reloadData(handles);

rows2 = get(handles.pXAxis,'String');
ix = find(cellfun(@(x) strcmp(x,handles.settings.varx),rows2),1); set(handles.pXAxis,'Value',ix);
iy = find(cellfun(@(x) strcmp(x,handles.settings.vary),rows2),1); set(handles.pYAxis,'Value',iy);

% Update Z Axis too
set(handles.pZAxis,'String',rows2);
iz = find(cellfun(@(x) strcmp(x,handles.settings.varz),rows2),1); set(handles.pZAxis,'Value',iz);
%and frame!
set(handles.pFrame,'String',rows2);
try
    iF = find(cellfun(@(f) strcmp(f,handles.settings.varFrame),rows2),1); set(handles.pFrame,'Value',iF);
catch err
    handles.settings.varFrame=rows2{1};
    iF = find(cellfun(@(f) strcmp(f,handles.settings.varFrame),rows2),1); set(handles.pFrame,'Value',iF);
end

% Update handles structure
guidata(hObject, handles);

% Update plugins menu
plugins_refresh();

% Update menuimport menu
menuImport_refresh(hObject, eventdata, handles)
menuExport_refresh(hObject, eventdata, handles)

% Set default action to zoom
set(handles.bgWheel,'SelectedObject',handles.rbZoom);

% Generate first image
redraw(handles)

% Auto display-range
autoMin(handles)
autoMax(handles)

% Use adjusted min/max
redraw(handles)

% UIWAIT makes PALMsiever wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function handles = selectVariables(handles)

rows2 = getVariables(handles);

if length(rows2)<1
    return
end

sel = javaMethod('showInputDialog','javax.swing.JOptionPane',[],'Choose X axis','',3,[],rows2,[]);
if sel
    handles.settings.N = evalin('base',['length(' sel ')']);
else
    return
end

if sel
   handles.settings.varx=sel; 
end

sel = javaMethod('showInputDialog','javax.swing.JOptionPane',[],'Choose Y axis','',3,[],rows2,[]);

if sel
   handles.settings.vary=sel; 
end

sel = javaMethod('showInputDialog','javax.swing.JOptionPane',[],'Choose X axis sigma','',3,[],rows2,[]);

if sel
   handles.settings.sigmax=sel; 
end

sel = javaMethod('showInputDialog','javax.swing.JOptionPane',[],'Choose Y axis sigma','',3,[],rows2,[]);

if sel
   handles.settings.sigmay=sel; 
end

% --- Outputs from this function are returned to the command line.
function varargout = PALMsiever_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(0,'self',[]);

% Get default command line output from handles structure
if isfield(handles,'output')
    varargout{1} = handles.output;
end



function maxY_Callback(hObject, eventdata, handles)
% hObject    handle to maxY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxY as text
%        str2double(get(hObject,'String')) returns contents of maxY as a double
redraw(handles)


% --- Executes during object creation, after setting all properties.
function maxY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minY_Callback(hObject, eventdata, handles)
% hObject    handle to minY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minY as text
%        str2double(get(hObject,'String')) returns contents of minY as a double
redraw(handles)


% --- Executes during object creation, after setting all properties.
function minY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minX_Callback(hObject, eventdata, handles)
% hObject    handle to minX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minX as text
%        str2double(get(hObject,'String')) returns contents of minX as a double
redraw(handles)


% --- Executes during object creation, after setting all properties.
function minX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxX_Callback(hObject, eventdata, handles)
% hObject    handle to maxX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxX as text
%        str2double(get(hObject,'String')) returns contents of maxX as a double
redraw(handles)

% --- Executes during object creation, after setting all properties.
function maxX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stack = renderStack(handles)
ZPosition=evalin('base',handles.settings.varz);

minZ = min(ZPosition);
maxZ = max(ZPosition);

deltaz = str2double(get(handles.fDeltaZ,'String'));
nslices = ceil((maxZ-minZ)/deltaz);

res = getRes(handles);
stack = zeros(res, res, nslices);
%h = waitbar(0,'Rendering stack...');
for i=1:nslices
    from = minZ + deltaz*(i-1);
    to = minZ + deltaz*i;
    
    setZbounds(handles,[from to]);
    
    frame = zeros(res,res);

    redraw(handles);
    
    if sum(getSubset(handles))>0
        pdf = getappdata(0,'KDE');
        frame(1:size(pdf{3},1),1:size(pdf{3},2)) = pdf{3};
    end
    
    stack(:,:,i) = frame;
    disp([i nslices]);
    %waitbar(i/nslices,h);
end
%close(h)

function res = getRes(handles);
res = 2^(get(handles.pResolution,'Value')+7); %CAREFUL CHANGING VALS IN CTRL!!!


function redraw(handles)
watch_on

if evalin('base','drawing')==true
    return
end

assignin('base','drawing',true);

try
    redrawHelper(handles)
catch err
    assignin('base','drawing',false);
    
    rethrow(err)
end
assignin('base','drawing',false);

watch_off

function redrawHelper(handles)

set(0,'CurrentFigure',handles.figure1);
hold(handles.axes1,'off')

XPosition=evalin('base',handles.settings.varx);
YPosition=evalin('base',handles.settings.vary);
ZPosition=evalin('base',handles.settings.varz);

if isfield(handles.settings,'varID')
    ID=evalin('base',handles.settings.varID);
else
    ID=ones(size(XPosition));
end

gamma = getGamma(handles);

data = get(handles.tParameters,'Data');

subset = true(length(XPosition),1);
subset0 = true(length(XPosition),1);
rows = get(handles.tParameters,'RowName');
for irow=1:length(rows)
    try
        rv = fetch(rows{irow});
        
        m = data{irow,1};
        M = data{irow,2};
        
        curSubset = rv>=m & rv<=M;

        subset = subset & curSubset;

        if rows{irow}(end)=='_' 
            % Skip
        else
            subset0 = subset0 & curSubset;
        end
    catch
        % Skip
    end
end
assignin('base','subset',subset);

if get(handles.pbGrouped,'Value')
    % Group data if necessary
    XPosition = groupBy(XPosition(subset), ID(subset)); 
    YPosition = groupBy(YPosition(subset), ID(subset));
    ZPosition = groupBy(ZPosition(subset), ID(subset));
    XPosition=XPosition(~isnan(XPosition));
    YPosition=YPosition(~isnan(YPosition));
    ZPosition=ZPosition(~isnan(ZPosition));
    ID = 1:sum(subset);
    subset = true(size(XPosition));
end
    
[minX, maxX, minY, maxY] = getBounds(handles);
[minZ, maxZ]=getZbounds(handles);

minC = str2double(get(handles.minC,'String'));
maxC = str2double(get(handles.maxC,'String'));
nbins = str2double(get(handles.tBins,'String'));

setappdata(0,'pointsetsubset',subset);

NP = sum(subset);

if NP<1
    logger('Warning: no points to display. Press ''Fit'' to reset the field of view.')
    %return
end

set(handles.tNumPoints,'String',num2str(NP));

is3D = (get(handles.pShow,'Value') == 6||get(handles.pShow,'Value') == 9);

res = getRes(handles);

r = str2double(get(handles.radius,'String'));

% Calculate pixel sizes
pxx = (maxX-minX)/res; pxy = (maxY-minY)/res;
set(handles.lPxSize,'String',[num2str(pxx) 'x' num2str(pxy)]);
cbcol = 'white';
switch get(handles.pShow,'Value')
    case 1 % "Points"
        scatter(handles.axes1,XPosition(subset),YPosition(subset),r,ID(subset),'.');
        cbcol = 'black';
    case 2 % "Histogram"
        n=linspace(minX,maxX,res); m=linspace(minY,maxY,res);

        if NP>0
            RR = round((res-1)*[...
                (XPosition(subset)-minX)/(maxX-minX) ...
                (YPosition(subset)-minY)/(maxY-minY) ])+1;
            RRok = all(RR<=res,2) & all(RR>=1,2) ;
            pxx=(maxX-minX)/res; pxy=(maxY-minY)/res;
            pxArea=pxx * pxy;
            density = accumarray(RR(RRok,:),1,[res,res])/pxArea;
            X = repmat(n,res,1); Y = repmat(m',1,res);
        else
            density = zeros(res+1);
            X = repmat(n,res+1,1); Y = repmat(m',1,res+1);
        end

        %[density n m] = calcHistogram(handles);
        
        %[density px] = histn([XPosition YPosition], res, [minX minY], [maxX maxY]);
        
        %X = repmat(n,res,1); Y = repmat(m',1,res);
        density = gammaAdjust(density,gamma);
        imagesc(n,m,density',[minC maxC]); colormap hot
        setappdata(0,'KDE',{X,Y,density'})
    case 3 % "KDE"
        if NP>0
            [bandwidth,density,X,Y]=kde2d([XPosition(subset) YPosition(subset)],res,...
                [min(XPosition(subset)) min(YPosition(subset))],...
                [max(XPosition(subset)) max(YPosition(subset))]);
            pxArea=(maxX-minX)/res * (maxY-minY)/res;
            density = density*sum(subset)/pxArea;
            
            logger(['Bandwidths: ', num2str(bandwidth)]);
        else
            density = zeros(res);
        end
        density = gammaAdjust(density,gamma);
        imagesc(X(1,:),Y(:,1),density,[minC maxC])
        setappdata(0,'KDE',{X,Y,density})
        set(handles.axes1,'Color',[0 0 0])
    case 4 % "KDE contour"
        if NP>0            
            [bandwidth,density,X,Y]=kde2d([XPosition(subset) YPosition(subset)],res,...
                [min(XPosition(subset)) min(YPosition(subset))],...
                [max(XPosition(subset)) max(YPosition(subset))]);
            pxArea=(maxX-minX)/res * (maxY-minY)/res;
            density = density*sum(subset)/pxArea;
            if nodiplib()
                H = fspecial('gaussian',7,2);
                density = imfilter(density,H);
            else
                density = double(gaussf(density,2));
            end
        else
            n=linspace(minX,maxX,res); m=linspace(minY,maxY,res);
            density = zeros(res);
            X = repmat(n,res,1); Y = repmat(m',1,res);
        end
        density = gammaAdjust(density,gamma);
        contour(handles.axes1,X,Y,density,linspace(minC,maxC,nbins))
        setappdata(0,'KDE',{X,Y,density})
    case 5 % "Histogram + Gauss"
        n=linspace(minX,maxX,res); m=linspace(minY,maxY,res);
        if NP>0
            RR = round((res-1)*[...
                (XPosition(subset)-minX)/(maxX-minX) ...
                (YPosition(subset)-minY)/(maxY-minY) ])+1;
            RRok = all(RR<=res,2) & all(RR>=1,2) ;
            pxx=(maxX-minX)/res; pxy=(maxY-minY)/res;
            pxArea=pxx * pxy;
            sigma = str2double(get(handles.sigma,'String'));
            A = accumarray(RR(RRok,:),1,[res,res])/pxArea;
            if nodiplib()
                H = fspecial('gaussian',round(sigma/pxy*6)/2*2+1,sigma/pxx);
                density = imfilter(A,H);
            else
                density = double(gaussf(A,[sigma/pxy sigma/pxx]));
            end
            X = repmat(n,res,1); Y = repmat(m',1,res);
        else
            density = zeros(res+1);
            X = repmat(n,res+1,1); Y = repmat(m',1,res+1);
        end
        density = gammaAdjust(density,gamma);
        imagesc(n,m,density',[minC maxC]); colormap hot
        setappdata(0,'KDE',{X,Y,density'})
    case 6 % Histogram 3D Hue Opacity
        n=linspace(minX,maxX,res); m=linspace(minY,maxY,res);
        a = .05; b=1;
        rgb = plotZ_fast(handles,res,subset,XPosition,YPosition,ZPosition,minZ,maxZ,minX,maxX,minY,maxY,gamma,minC,maxC,a,b);%simplified version without jittering
        
        imagesc(n,m,rgb);
    case 9 % Histogram 3D Hue
        n=linspace(minX,maxX,res); m=linspace(minY,maxY,res);
        a = 0; b=1;
        rgb = plotZ_fast(handles,res,subset,XPosition,YPosition,ZPosition,minZ,maxZ,minX,maxX,minY,maxY,gamma,minC,maxC,a,b);%simplified version without jittering
        
        imagesc(n,m,rgb);
    case 7 % "Jittered histogram"
%        n=linspace(minX,maxX,res+1); m=linspace(minY,maxY,res+1);
        n=linspace(minX,maxX,res); m=linspace(minY,maxY,res);
        if NP>0
            notrials = 20;
            NN = sum(subset);
            amount = (evalin('base',handles.settings.sigmax)+evalin('base',handles.settings.sigmay))/2;
            for i=1:notrials
                RR = round((res-1)*[...
                    (XPosition(subset)+randn(NN,1).*amount(subset)-minX)/(maxX-minX) ...
                    (YPosition(subset)+randn(NN,1).*amount(subset)-minY)/(maxY-minY) ])+1;
                RRok = all(RR<=res,2) & all(RR>=1,2) ;
                pxx=(maxX-minX)/res; pxy=(maxY-minY)/res;
                pxArea=pxx * pxy;
                d = accumarray(RR(RRok,:),1,[res,res])/pxArea;
                if i==1
                    density = d;
                else
                    density = density + d;
                end
            end
            X = repmat(n,res,1); Y = repmat(m',1,res);
            density = density/notrials;
        else
            density = zeros(res+1);
            X = repmat(n,res+1,1); Y = repmat(m',1,res+1);
        end
        density = gammaAdjust(density,gamma);
        imagesc(n,m,density',[minC maxC]); colormap hot
        setappdata(0,'KDE',{X,Y,density'})
    case 8 %"Delaunay Triangulation"
        X=XPosition(subset); Y=YPosition(subset);
        T = delaunay(X,Y);
        Ax = X(T(:,1)); Bx = X(T(:,2)); Cx = X(T(:,3)); Ay = Y(T(:,1)); By = Y(T(:,2)); Cy = Y(T(:,3));
        C = -abs(.5*( Ax.*(By-Cy)+Bx.*(Cy-Ay)+Cx.*(Ay-By) ));
        cla(handles.axes1);
        patch('Faces',T,'Vertices',[X Y],'FaceColor','flat','EdgeColor','none','FaceVertexCData',C,'CDataMapping','scaled');
        caxis([minC maxC]);
        set(handles.axes1,'Color',[0 0 0])
        setappdata(0,'Tri',{X,Y,T,C})
end

axis(handles.axes1,'ij');
if ~is3D
    updateColormap(handles)
end
set(handles.axes1,'ButtonDownFcn',@axes1_ButtonDownFcn);
set(allchild(handles.axes1),'ButtonDownFcn',@axes1_ButtonDownFcn);
axis(handles.axes1,'manual');
set(handles.axes1,'XLim', [minX maxX], 'YLim', [minY maxY])

% Add the scalebar
if doScalebar(handles)
    add_scalebar(handles,cbcol)
end

% Add color bar
if doColorbar(handles)
    add_colorbar(handles,cbcol)
end


function updateColormap(handles)
colormap(getColormapName(handles))

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

XYZ=get(handles.axes1,'CurrentPoint');
x = XYZ(1,1);
y = XYZ(1,2);
r = str2double(get(handles.radius,'String'));
l = str2double(get(handles.length,'String'));

isRightclick = strcmp(get(gcf,'SelectionType'),'alt');
isLeftclick = strcmp(get(gcf,'SelectionType'),'normal');

if isRightclick
    PLOTS = [2];
    
    S = getappdata(0,'KDE');
    if isempty(S)
        return
    end
    val = interp2(S{1},S{2},S{3},x,y,'nearest',0);
    handles = setStatus(handles,['X: ' num2str(x) 10 'Y: ' num2str(y) 10 ' d(X,Y): ' 9 num2str(val)]);
    
    % Calculate profile along eigenvalues
    subset = evalin('base','subset');
    X=evalin('base',handles.settings.varx); X=X(subset)-x;
    Y=evalin('base',handles.settings.vary); Y=Y(subset)-y;
    sigmas = (evalin('base',handles.settings.sigmax)+evalin('base',handles.settings.sigmay))/2;
    nbins = str2double(get(handles.tBins,'String'));
        
    subset0 = X.^2 + Y.^2 < r*r;
    ss = [X(subset0) Y(subset0)];
    if isempty(ss)
        msgbox(['No points within the specified radius: ' num2str(r)]);
        return
    end
    [v d] = eig(cov(ss)); 
    dir = v(:,2);
    dirM = [dir [-dir(2);dir(1)]];
    
    sscp = [X Y]*dirM;
    sscp_ok = sscp(:,2)<r & sscp(:,2)>-r ...
        & sscp(:,1)<l & sscp(:,1)>-l;
    sscp = sscp(sscp_ok,:);
    
    %subset0 = sscp( + Y.^2 < r*r;
    %ss = [X(subset0) Y(subset0)];

    line([x-dirM(1,2)*r x+dirM(1,2)*r],[y-dirM(2,2)*r y+dirM(2,2)*r])
    line([x-dirM(1,1)*l x+dirM(1,1)*l],[y-dirM(2,1)*l y+dirM(2,1)*l],'Color','g')
    
    if nbins==0
        nbins = ceil(log(sum(subset0))/log(2)+1)*2;
    end
    
    %amount = str2double(get(handles.sigma,'String'));
    %amount = sigmas(sscp_ok);
    %[h b h2] = jhist(sscp(:,2),100,amount,20);
    amount = 0;
    [h b h2] = jhist(sscp(:,2),linspace(min(sscp(:,2)),max(sscp(:,2)),nbins)',amount,1);

    figure; 

    pxSizeData = 1;

    if find(PLOTS==1)
        subplot(1,length(PLOTS),find(PLOTS==1)); bar(b,h+h2,'FaceColor',[0 0 0]+.9,'EdgeColor','none'); hold; bar(b,h,'EdgeColor','b'); %area(b,h-h2,'FaceColor',[0 0 0]+.9); 


    %    [fitresult, gof] = jdg_fit(b'*pxSizeData,h',h2',5);
    %    title(sprintf('A = %.3f (%.3f)     s = %.3f (%.3f)\nw = %.3f (%.3f)     x0 = %.3f (%.3f)',...
        [coeff, gof, fitresult] = jth_fit(b(:)*pxSizeData,h(:),h2(:),5);
        title(sprintf('h = %.3f (%.3f)     mu = %.3f (%.3f)\nsigma = %.3f (%.3f)     w = %.3f (%.3f)',...
            coeff(1), gof(1),...
            coeff(2)/pxSizeData, gof(2),...
            coeff(3)/pxSizeData, gof(3),...
            coeff(4)/pxSizeData, gof(4) ));
        plot(fitresult)
    end
    
    if find(PLOTS==2)
        [fitresult, gof] = sg_fit(b(:),h(:));

        subplot(1,length(PLOTS),find(PLOTS==2));  bar(b,h+h2,'FaceColor',[0 0 0]+.9,'EdgeColor','none'); hold; bar(b,h,'EdgeColor','b');
        plot(fitresult); %area(b,h-h2,'FaceColor',[0 0 0]+.9); 
        
        fitresult = coeffvalues(fitresult);
        title(sprintf('A = %.3f   s = %.3f\nx0 = %.3f',...
            fitresult(1),...
            fitresult(3),...
            fitresult(2)));

    end
    
    if find(PLOTS==3)
        %[coeff, gof, fitresult] = jdg_fit(b'*pxSizeData,h'); %,h2',5);
    %     title(sprintf('A = %.3f (%.3f)     s = %.3f (%.3f)\nw = %.3f (%.3f)     x0 = %.3f (%.3f)',...
    %         coeff(1), gof(1),...
    %         coeff(2)/pxSizeData, gof(2),...
    %         coeff(3)/pxSizeData, gof(3),...
    %         coeff(4)/pxSizeData, gof(4) ));
        [fitresult, gof] = dg_fit(b(:)*pxSizeData,h(:)); %,h2',5);
        coeff = coeffvalues(fitresult);
        subplot(1,length(PLOTS),find(PLOTS==3));  bar(b,h+h2,'FaceColor',[0 0 0]+.9,'EdgeColor','none'); hold; bar(b,h,'EdgeColor','b'); %area(b,h-h2,'FaceColor',[0 0 0]+.9); 
        plot(fitresult)
        title(sprintf('A = %.3f   s = %.3f \nw = %.3f     x0 = %.3f',...
            coeff(1),...
            coeff(2)/pxSizeData,...
            coeff(3)/pxSizeData,...
            coeff(4)/pxSizeData ));
    end
    

elseif isLeftclick
    [minX maxX minY maxY] = getBounds(handles);
    intX = maxX-minX;
    intY = maxY-minY;


    % NOTE: now the scroll wheel is handling the ZOOM
    %isDoubleclick = strcmp(get(gcf,'SelectionType'),'open');
    %if isDoubleclick
    %    newMinX = x-intX/4; newMaxX = x+intX/4;
    %    newMinY = y-intY/4; newMaxY = y+intY/4;
    %else
         newMinX = x-intX/2; newMaxX = x+intX/2;
         newMinY = y-intY/2; newMaxY = y+intY/2;
    %end

    handles = setBounds(handles,[newMinX newMaxX newMinY newMaxY]);

    redraw(handles)
end

% --- Executes on button press in cbHisto.
function cbHisto_Callback(hObject, eventdata, handles)
% hObject    handle to cbHisto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbHisto
redraw(handles)


% --- Executes on button press in bZoomOut.
function bZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to bZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[minX maxX minY maxY] = getBounds(handles);

intX = maxX-minX;
intY = maxY-minY;

newMinX = minX-intX/2; newMaxX = maxX+intX/2;
newMinY = minY-intY/2; newMaxY = maxY+intY/2;

handles = setBounds(handles,[newMinX newMaxX newMinY newMaxY]);

redraw(handles)


% --- Executes on button press in bZoomIn.
function bZoomIn_Callback(hObject, eventdata, handles)
% hObject    handle to bZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[minX maxX minY maxY] = getBounds(handles);

intX = maxX-minX;
intY = maxY-minY;

newMinX = minX+intX/4; newMaxX = maxX-intX/4;
newMinY = minY+intY/4; newMaxY = maxY-intY/4;

handles=setBounds(handles,[newMinX newMaxX newMinY newMaxY]);

guidata(gcf,handles)

redraw(handles)



function maxC_Callback(hObject, eventdata, handles)
% hObject    handle to maxC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxC as text
%        str2double(get(hObject,'String')) returns contents of maxC as a double
redraw(handles)

% --- Executes during object creation, after setting all properties.
function maxC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function minC_Callback(hObject, eventdata, handles)
% hObject    handle to minC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minC as text
%        str2double(get(hObject,'String')) returns contents of minC as a double
redraw(handles)

% --- Executes during object creation, after setting all properties.
function minC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in tParameters.
function tParameters_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tParameters (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
redraw(handles)

function handles=reloadData(handles)
if ~isfield(handles.settings,'N')
    return
end
% Set data
[rows2 data] = getVariables(handles,handles.settings.N);
set(handles.tParameters,'RowName',rows2);
set(handles.tParameters, 'Data', data);

set(handles.pXAxis,'String',rows2);
set(handles.pYAxis,'String',rows2);
set(handles.pZAxis,'String',rows2);
set(handles.pFrame,'String',rows2);
set(handles.pID,'String',rows2);

function updateTable(handles)
XPosition=evalin('base',handles.settings.varx);
data = get(handles.tParameters,'Data');
subset = true(length(XPosition),1);
rows = get(handles.tParameters,'RowName');
for irow=1:length(rows)
    subset = subset & evalin('base',[rows{irow} '>=' num2str(data{irow,1}) '&' ...
        rows{irow} '<=' num2str(data{irow,2})]);
end
assignin('base','subset',subset)

cols = get(handles.tParameters,'ColumnName');
rows = get(handles.tParameters,'RowName');
for irow=1:length(rows)
    var = evalin('base',rows{irow});
    for icol=3:length(cols)
        fev = evalin('base',[cols{icol} '(' rows{irow} '(subset))']);
        if strcmp(cols{icol},'min')
            if fev>=0
                fev = fev * .999;
            else
                fev = fev / .999;
            end
        elseif strcmp(cols{icol},'max')
            if fev >=0
                fev = fev / .999;
            else
                fev = fev * .999;
            end
        end
        data{irow,icol} = fev;
    end
end
set(handles.tParameters,'Data',data)

% --- Executes on selection change in pXAxis.
function pXAxis_Callback(hObject, eventdata, handles)
% hObject    handle to pXAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pXAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pXAxis

% Get data range for previous X
minmaxX = evalin('base',['[min(' handles.settings.varx ') max(' handles.settings.varx ')]']);

% Set range on the table
[minX maxX minY maxY] = getBounds(handles);
handles=setBounds(handles,[minmaxX minY maxY]);
redraw(handles)

% Go on and save the new X
valsX = get(handles.pXAxis,'String');
handles.settings.varx=valsX{get(handles.pXAxis,'Value')};
guidata(gcf,handles);

% Redraw
redraw(handles)

% --- Executes during object creation, after setting all properties.
function pXAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pXAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pYAxis.
function pYAxis_Callback(hObject, eventdata, handles)
% hObject    handle to pYAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pYAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pYAxis
% Get data range for previous Y
minmaxY = evalin('base',['[min(' handles.settings.vary ') max(' handles.settings.vary ')]']);

% Set range on the table
[minX maxX minY maxY] = getBounds(handles);
handles=setBounds(handles,[minX maxX minmaxY]);
redraw(handles)

% Go on and save the new Y
valsY = get(handles.pYAxis,'String');
handles.settings.vary=valsY{get(handles.pYAxis,'Value')};
guidata(gcf,handles);

redraw(handles)

% --- Executes during object creation, after setting all properties.
function pYAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pYAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pID.
function pID_Callback(hObject, eventdata, handles)
% hObject    handle to pID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pID
valsID = get(handles.pID,'String');

handles.settings.varID=valsID{get(handles.pID,'Value')};

guidata(gcf,handles);

redraw(handles)


% --- Executes during object creation, after setting all properties.
function pID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in tParameters.
function tParameters_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to tParameters (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

handles.selectedCell = eventdata.Indices;
guidata(gcf,handles)

if isempty(eventdata.Indices)
    return
end

drawhist(handles, eventdata.Indices(1));

function drawhist(handles,rown)
rows = get(handles.tParameters,'RowName');
data = evalin('base',[rows{rown} '(subset)']);
tabl = get(handles.tParameters,'Data');

[n bins] = hist(data,linspace(tabl{rown,1},tabl{rown,2},100));
bar(handles.axes2, bins, n, 1);
set(handles.axes2,'XLim',[tabl{rown,1} tabl{rown,2}]);
set(handles.axes2,'YLim',[0 max(n)]);

% Highlight u/l 5%
l = q05(data);
h = q95(data);
m = median(data);

axes(handles.axes2)
line([l l],[0 max(n)/8],'Color','r');
line([h h],[0 max(n)/8],'Color','r');
line([m m],[0 max(n)/8],'Color','b');
axes(handles.axes1)

% --- Executes on button press in bRedraw.
function bRedraw_Callback(hObject, eventdata, handles)
% hObject    handle to bRedraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
redraw(handles)

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in pShow.
function pShow_Callback(hObject, eventdata, handles)
% hObject    handle to pShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pShow contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pShow
redraw(handles)
autoMin(handles)
autoMax(handles)
redraw(handles)

% --- Executes during object creation, after setting all properties.
function pShow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pResolution.
function pResolution_Callback(hObject, eventdata, handles)
% hObject    handle to pResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pResolution contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pResolution
redraw(handles)

% --- Executes during object creation, after setting all properties.
function pResolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pColormap.
function pColormap_Callback(hObject, eventdata, handles)
% hObject    handle to pColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pColormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pColormap
updateColormap(handles)

% --- Executes during object creation, after setting all properties.
function pColormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pResetY.
function pResetY_Callback(hObject, eventdata, handles)
% hObject    handle to pResetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data range for Y
rows = get(handles.tParameters,'RowName');
minmaxY = evalin('base',['[min(' rows{get(handles.pYAxis,'Value')} ') max(' rows{get(handles.pYAxis,'Value')} ')]']);

% Set range on the table
[minX maxX minY maxY] = getBounds(handles);
handles=setBounds(handles,[minX maxX minmaxY]);
redraw(handles)

% --- Executes on button press in pResetX.
function pResetX_Callback(hObject, eventdata, handles)
% hObject    handle to pResetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data range for Y
rows = get(handles.tParameters,'RowName');
minmaxX = evalin('base',['[min(' rows{get(handles.pXAxis,'Value')} ') max(' rows{get(handles.pXAxis,'Value')} ')]']);

% Set range on the table
[minX maxX minY maxY] = getBounds(handles);
handles=setBounds(handles,[minmaxX minY maxY]);
redraw(handles)

% --- Executes on button press in bAutoMinC.
function bAutoMinC_Callback(hObject, eventdata, handles)
% hObject    handle to bAutoMinC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoMin(handles)

minC = str2double(get(handles.minC,'String'));
maxC = str2double(get(handles.maxC,'String'));

if minC>=maxC
    autoMin(handles)
end
redraw(handles)

function autoMin(handles)
switch get(handles.pShow,'Value')
    case 1
        1;
    case 2 %'Histogram'
        set(handles.minC,'String',num2str(0));
    case 3 %'KDE'
        set(handles.minC,'String',num2str(0));
    case 4 %'KDE contour'
        set(handles.minC,'String',num2str(1e-5));
    case 5 %'Histogram + Gauss filter'
        set(handles.minC,'String',num2str(0));
    case 6 %'Histogram 3D opacity'
        set(handles.minC,'String',num2str(0));
    case 9 %'Histogram 3D'
        set(handles.minC,'String',num2str(0));
    case 7 %'Jittered histogram'
        set(handles.minC,'String',num2str(0));
    case 8 %'Delaunay Triangulation'
        Tr = getappdata(0,'Tri');
        set(handles.minC,'String',num2str(quantile(Tr{4},.05)));
    otherwise
        msgbox('Not implemented yet for this visualization');
        return
end  

% --- Executes on button press in bAutoMaxC.
function bAutoMaxC_Callback(hObject, eventdata, handles)
% hObject    handle to bAutoMaxC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateAutoMax(handles);

function updateAutoMax(handles)
autoMax(handles);

minC = str2double(get(handles.minC,'String'));
maxC = str2double(get(handles.maxC,'String'));

if minC>=maxC
    autoMin(handles)
end
redraw(handles)

function autoMax(handles)
try
    a = getappdata(0,'KDE'); 
    val = num2str(max(a{3}(:)));
catch err
end

switch get(handles.pShow,'Value')
    case 1
        1;
    case 2 %'Histogram'
        set(handles.maxC,'String',val);
    case 3 %'KDE'
        set(handles.maxC,'String',val);
    case 4 %'KDE contour'
        set(handles.maxC,'String',val);
    case 5 %'Histogram + Gauss filter'
        set(handles.maxC,'String',val);
    case 6 %'Histogram 3D opacity'
        set(handles.maxC,'String',val);
    case 9 %'Histogram 3D'
        set(handles.maxC,'String',val);
    case 7 %'Jittered histogram'
        set(handles.maxC,'String',val);
    case 8 %'Delaunay Triangulation'
        Tr = getappdata(0,'Tri');
        set(handles.maxC,'String',num2str(quantile(Tr{4},1))); % takes max..
    otherwise
        msgbox('Not implemented yet for this visualization');
        return
end
guidata(gcf,handles)

% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

XYZ=get(handles.axes1,'CurrentPoint');
x = XYZ(1,1);
y = XYZ(1,2);

[minX maxX minY maxY] = getBounds(handles);

if x>maxX | x<minX | y>maxY | y<minY
    return
end

isZoom = get(handles.bgWheel,'SelectedObject')==handles.rbZoom;
isZ = get(handles.bgWheel,'SelectedObject')==handles.rbZ;

if isZoom
    intX = maxX-minX;
    intY = maxY-minY;

    if eventdata.VerticalScrollCount < 0
        newMinX = x-intX/4; newMaxX = x+intX/4;
        newMinY = y-intY/4; newMaxY = y+intY/4;
    else
        newMinX = minX-intX/2; newMaxX = maxX+intX/2;
        newMinY = minY-intY/2; newMaxY = maxY+intY/2;
    end

    handles = setBounds(handles,[newMinX newMaxX newMinY newMaxY]);
elseif isZ
    [minZ maxZ] = getZbounds(handles);
    dz = str2double(get(handles.fDeltaZ,'String'));
    if eventdata.VerticalScrollCount < 0
        dz = -dz;
    end
    handles = setZbounds(handles,[minZ maxZ]+dz);
end

redraw(handles)


% --- Executes on button press in pUpdateTable.
function pUpdateTable_Callback(hObject, eventdata, handles)
% hObject    handle to pUpdateTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateTable(handles);


% --- Executes on button press in p1to1Y.
function p1to1Y_Callback(hObject, eventdata, handles)
% hObject    handle to p1to1Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[minX maxX minY maxY] = getBounds(handles);
y=(maxY+minY)/2;
intX = maxX-minX;
newMinY = y-intX/2; newMaxY = y+intX/2;
handles = setBounds(handles,[minX maxX newMinY newMaxY]);
redraw(handles)

% --- Executes on button press in p1to1X.
function p1to1X_Callback(hObject, eventdata, handles)
% hObject    handle to p1to1X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resizeX1to1(handles);

function resizeX1to1(handles)
[minX maxX minY maxY] = getBounds(handles);
x=(maxX+minX)/2;
intY = maxY-minY;
newMinX = x-intY/2; newMaxX = x+intY/2;
handles = setBounds(handles,[newMinX newMaxX minY maxY]);
redraw(handles)


% --- Executes on button press in pRefreshVariables.
function pRefreshVariables_Callback(hObject, eventdata, handles)
% hObject    handle to pRefreshVariables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refreshVariables(handles);

function h=refreshVariables(handles)
rows_prev = get(handles.tParameters,'RowName');
tabl_prev = get(handles.tParameters,'Data');
h = handles;

% Save X,Y,Frame,Z,ID
vars = get(handles.pXAxis,'String');
xvar = vars{get(handles.pXAxis,'Value')};
yvar = vars{get(handles.pYAxis,'Value')};
zvar = vars{get(handles.pZAxis,'Value')};
fvar = vars{get(handles.pFrame,'Value')};
idvar = vars{get(handles.pID,'Value')};

handles = reloadData(handles);

rows_new = get(handles.tParameters,'RowName');
tabl_new = get(handles.tParameters,'Data');

% Try to set everything as before...
nvars = get(handles.pXAxis,'String');
for i=1:length(rows_new)
    if ismember(rows_new{i},rows_prev)
        ri_prev = find(ismember(rows_prev,rows_new{i}),1);
        tabl_new(i,:) = tabl_prev(ri_prev,:);
    end
end
set(handles.tParameters,'Data',tabl_new);

f = @(vars,varname) max(find(ismember([varname;vars],varname),1,'last')-1,1);

set(handles.pXAxis,'Value',f(nvars,xvar)); handles.settings.varx = nvars{f(nvars,xvar)};
set(handles.pYAxis,'Value',f(nvars,yvar)); handles.settings.vary = nvars{f(nvars,yvar)};
set(handles.pZAxis,'Value',f(nvars,zvar)); handles.settings.varz = nvars{f(nvars,zvar)};
set(handles.pFrame,'Value',f(nvars,fvar)); handles.settings.varFrame = nvars{f(nvars,fvar)};
set(handles.pID,'Value',f(nvars,idvar)); handles.settings.varID = nvars{f(nvars,idvar)};

guidata(gcf,handles);

redraw(handles);

% --- Executes on button press in pFit.
function pFit_Callback(hObject, eventdata, handles)
% hObject    handle to pFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

XPosition=evalin('base',handles.settings.varx);
YPosition=evalin('base',handles.settings.vary);

minX = min(XPosition); maxX = max(XPosition);
minY = min(YPosition); maxY = max(YPosition);

handles=setBounds(handles,[minX maxX minY maxY]);

guidata(gcf,handles)

redraw(handles)


% --------------------------------------------------------------------
function tParameters_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to tParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

function handles = setStatus(handles, str)

%set(handles.tStatus, 'String', str)
%text(10,10,str,'Color','y')


% --- Executes on button press in cbDensity.
function cbDensity_Callback(hObject, eventdata, handles)
% hObject    handle to cbDensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbDensity



function fDeltaZ_Callback(hObject, eventdata, handles)
% hObject    handle to fDeltaZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fDeltaZ as text
%        str2double(get(hObject,'String')) returns contents of fDeltaZ as a double


% --- Executes during object creation, after setting all properties.
function fDeltaZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fDeltaZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pZAxis.
function pZAxis_Callback(hObject, eventdata, handles)
% hObject    handle to pZAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pZAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pZAxis
vals = get(hObject,'String');
handles.settings.varz=vals{get(hObject,'Value')};
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function pZAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pZAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fSlice_Callback(hObject, eventdata, handles)
% hObject    handle to fSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fSlice as text
%        str2double(get(hObject,'String')) returns contents of fSlice as a double

[minZ maxZ] = getZbounds(handles);

center = .5*maxZ + .5*minZ;
slice = str2double(get(hObject,'String'));

handles = setZbounds(handles, [center-slice/2 center+slice/2]);

guidata(gcf, handles)


% --- Executes during object creation, after setting all properties.
function fSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function mPRM_Callback(hObject, eventdata, handles)
% hObject    handle to mPRM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=openDelimited(sprintf('\t'),'prm', handles)
guidata(gcf,handles)

% --------------------------------------------------------------------
function mCSV_Callback(hObject, eventdata, handles)
% hObject    handle to mCSV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=openDelimited(sprintf(','),'csv', handles)
guidata(gcf,handles)

function handles=openDelimited(delimiter, extension, handles)

[filename, pathname] = uigetfile(['*.' extension]);

if filename(1)~=0
    try
        evalin('base','clear')

        Nr = importprm(fullfile(pathname,filename),delimiter);
    
        [rows2 data] = getVariables(handles, Nr);

        if length(rows2)<1
            uiwait(errordlg('Empty file? I was not able to load the file'))
            return
        end

        evalin('base','clear subset');

        set(handles.pXAxis,'String',rows2);
        set(handles.pYAxis,'String',rows2);
        set(handles.pZAxis,'String',rows2);

        assignin('base','subset',evalin('base',['true(size(' rows2{1} '))']))

        set(handles.tFilename, 'String', fullfile(pathname,filename));

        handles=selectVariables(handles);

        assignin('base','drawing',false);
        redraw(handles);
    catch err
        throw(err)
    end
end

function res = isPoints(handles)

res = strcmp(getSelectedRendering(handles),'Points');


% --- Executes on button press in pbRefreshZ.
function pbRefreshZ_Callback(hObject, eventdata, handles)
% hObject    handle to pbRefreshZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get data range for Y
rows = get(handles.tParameters,'RowName');
minmaxZ = evalin('base',['[min(' rows{get(handles.pZAxis,'Value')} ') max(' rows{get(handles.pZAxis,'Value')} ')]']);

% Set range on the table
handles=setZbounds(handles,minmaxZ);
redraw(handles)



function sigma_Callback(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma as text
%        str2double(get(hObject,'String')) returns contents of sigma as a double
redraw(handles)

% --- Executes during object creation, after setting all properties.
function sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function radius_Callback(hObject, eventdata, handles)
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius as text
%        str2double(get(hObject,'String')) returns contents of radius as a double


% --- Executes during object creation, after setting all properties.
function radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function length_Callback(hObject, eventdata, handles)
% hObject    handle to length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of length as text
%        str2double(get(hObject,'String')) returns contents of length as a double


% --- Executes during object creation, after setting all properties.
function length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Progress bar
function setProgress(handles, p)
if p==1
    set(handles.tProgress,'Visible','off'); drawnow;
else
    set(handles.tProgress,'Visible','on')
    set(handles.tProgress,'String',[num2str(p*100) ' %']); drawnow;
end

% Plugins
function plugins_refresh(mh)
if nargin>0
    delete(mh)
end
    
mh = uimenu(gcf,'Label','Plugins');
uimenu(mh,'Label','Refresh','Callback',@(varargin) plugins_refresh(mh));

if isappdata(0,'staticplugins') && getappdata(0,'staticplugins')
    plugins = get_static_plugins;
else
    palm_siever = fileparts(which('palmsiever_setup'));
    pluginsDir= fullfile(palm_siever,'plugins');
    addpath(pluginsDir)
    pluginsCore = dir(fullfile(pluginsDir,'*.m'))';
    %optional directory for local plugins
    if exist(fullfile(palm_siever,'plugin-test'),'dir')
        pluginsTestDir = fullfile(palm_siever,'plugin-test');
        addpath(pluginsTestDir);
        pluginsTest = dir(fullfile(pluginsTestDir,'*.m'))';
    else
       pluginsTest = [];
    end
    plugins = [pluginsCore,pluginsTest];
end

sep = true;
for f = plugins
    name = f.name(1:end-2);
    if sep
        sep=false; 
        uimenu(mh,'Label',name,'Callback',@(varargin) plugins_callback(name,varargin{:}),'Separator','on'); 
    else
        uimenu(mh,'Label',name,'Callback',@(varargin) plugins_callback(name,varargin{:})); 
    end
end

function plugins_callback(name,varargin)

try 
    if isprop(0,'CurrentFigure')
        fig = get(0,'CurrentFigure');
    else
        fig = gcf;
    end
    feval(name,guidata(fig))
    %redraw(guidata(fig))
catch err
    if strcmp(err.identifier,'MATLAB:scriptNotAFunction')
        evalin('base',name)
    else
        rethrow(err)
    end
end

function menuImport_refresh(hObject, eventdata, handles)

hImp= findobj(gcf,'Tag','MenuImport'); %DONT CHANGE THE TAG NAME FOR IMPORT!
hCh = get(hImp,'Children');
if ~isempty(hCh)
   for ii = 1:numel(hCh)
      delete(hCh(ii));
   end
end

% add the Ascii file imports
fileSpecPath= fullfile(fileparts(which('palmsiever_setup')),'fileIO','Ascii');

sep = false;
for f = dir(fullfile(fileSpecPath,'*.m'))'
    name = f.name(1:end-2);
    if sep
        sep=false; 
        uimenu(hImp,'Label',name,'Callback',@(varargin) import_callback(name,'ascii',varargin{:}),'Separator','on'); 
    else
        uimenu(hImp,'Label',name,'Callback',@(varargin) import_callback(name,'ascii',varargin{:})); 
    end
end

% add the Other file imports
fileSpecPath= fullfile(fileparts(which('palmsiever_setup')),'fileIO','Other');

sep = true;
for f = dir(fullfile(fileSpecPath,'*.m'))'
    name = f.name(1:end-2);
    if sep
        sep=false; 
        uimenu(hImp,'Label',name,'Callback',@(varargin) import_callback(name,'other',varargin{:}),'Separator','on'); 
    else
        uimenu(hImp,'Label',name,'Callback',@(varargin) import_callback(name,'other',varargin{:})); 
    end
end


% add the Generic file import
sep = true;
name = 'Generic';
uimenu(hImp,'Label','Generic text file','Callback',@(varargin) import_callback(name,'other',varargin{:}),'Separator','on'); 

function import_callback(name,mode,hObject, eventdata)
% function import_callback(name,hObject, eventdata, handles)
% hObject    handle to calling menu item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

if strcmp(mode,'ascii')
   fname = 'fileIoAscii';
elseif strcmp(mode,'other')
   fname = 'fileIoOther';
else
   fname ='';
   error('Unsupported import mode');
end
   
fileType = feval(fname,name,'FileType');
[filename path]=uigetfile(['*.',fileType]);

if filename~=0
   watch_on
   
   varAssignment=feval(fname,name, 'Import', 'Filename',fullfile(path,filename));
   nEl = evalin('base',['numel(',varAssignment{1}{2},')']);
   handles.settings.N = nEl;
   set(handles.tFilename,'String',filename);
   guidata(handles.output, handles);
   reloadData(handles);
   setPSVar(handles,varAssignment);
   handles=guidata(handles.output);
   reloadData(handles);
   handles=guidata(handles.output);
   redraw(handles);
   handles=guidata(handles.output);
   autoMin(handles);
   handles=guidata(handles.output);
   autoMax(handles);
   handles=guidata(handles.output);
   redraw(handles);
   
   watch_off
end


function menuExport_refresh(hObject, eventdata, handles)

hImp= findobj(gcf,'Tag','MenuExport'); %DONT CHANGE THE TAG NAME FOR EXPORT!
hCh = get(hImp,'Children');
if ~isempty(hCh)
   for ii = 1:numel(hCh)
      delete(hCh(ii));
   end
end

% add the Ascii file imports
fileSpecPath= fullfile(fileparts(which('palmsiever_setup')),'fileIO','Ascii');

sep = true;
for f = dir(fullfile(fileSpecPath,'*.m'))'
    name = f.name(1:end-2);
    if sep
        sep=false; 
        uimenu(hImp,'Label',name,'Callback',@(varargin) export_callback(name,'ascii',varargin{:}),'Separator','on'); 
    else
        uimenu(hImp,'Label',name,'Callback',@(varargin) export_callback(name,'ascii',varargin{:})); 
    end
end

% add the Other file imports
fileSpecPath= fullfile(fileparts(which('palmsiever_setup')),'fileIO','Other');

sep = true;
for f = dir(fullfile(fileSpecPath,'*.m'))'
    name = f.name(1:end-2);
    if sep
        sep=false; 
        uimenu(hImp,'Label',name,'Callback',@(varargin) export_callback(name,'other',varargin{:}),'Separator','on'); 
    else
        uimenu(hImp,'Label',name,'Callback',@(varargin) export_callback(name,'other',varargin{:}));
    end
end

% add the Generic file import
sep = true;
name = 'Generic';
uimenu(hImp,'Label','Generic text file','Callback',@(varargin) export_callback(name,'other',varargin{:}),'Separator','on'); 

function export_callback(name,mode,hObject, eventdata)
% function import_callback(name,hObject, eventdata, handles)
% hObject    handle to calling menu item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
if strcmp(mode,'ascii')
   fname = 'fileIoAscii';
elseif strcmp(mode,'other')
   fname = 'fileIoOther';
else
   fname ='';
   error('Unsupported export mode');
end
   
fileType = feval(fname,name,'FileType');
[filename path]=uiputfile(['*.',fileType]);

if filename~=0
   if strcmp(name,'Generic')
      varNamesGui= getVariables(handles,handles.settings.N);
      feval(fname,name, 'Export', 'Filename',fullfile(path,filename),'ColAssingment',varNamesGui);
   else
      colNamesFile= feval(fname,name, 'ReturnColNames');
      varNamesFile= feval(fname,name, 'ReturnVarNames');
      varNamesGui= getVariables(handles,handles.settings.N);
      [colHash isCancelled]= getColHash(colNamesFile, varNamesFile, varNamesGui);
      if isCancelled ==0
         feval(fname,name, 'Export', 'Filename',fullfile(path,filename),'ColAssingment',colHash);
      end
   end
end



function tBins_Callback(hObject, eventdata, handles)
% hObject    handle to tBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tBins as text
%        str2double(get(hObject,'String')) returns contents of tBins as a double


% --- Executes during object creation, after setting all properties.
function tBins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function mTrace_Callback(hObject, eventdata, handles)
% hObject    handle to mTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miTrace_Callback(hObject, eventdata, handles)
% hObject    handle to miTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subset = evalin('base','subset');
X=evalin('base',handles.settings.varx); X=X(subset);
Y=evalin('base',handles.settings.vary); Y=Y(subset);
r0 = str2double(get(handles.radius,'String'));
step = str2double(get(handles.length,'String'));

%% Choose starting point and first waypoint for initial direction
P0 = ginput(1);
P1 = ginput(1); dir0 = (P1-P0)'; dir0 = dir0/sqrt(sumsqr(dir0));

%% Tracing
Trace = trace(X,Y,P0,dir0,r0,step);

assignin('base','Trace',Trace)

showTrace(handles)

% --------------------------------------------------------------------
function miSaveTrace_Callback(hObject, eventdata, handles)
% hObject    handle to miSaveTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename path]=uiputfile('*.mat');
Trace = evalin('base','Trace');
if filename
    save(fullfile(path,filename),'Trace');
end

% --------------------------------------------------------------------
function miLoadTrace_Callback(hObject, eventdata, handles)
% hObject    handle to miLoadTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename path]=uigetfile('*.mat');
if filename
    S=load(fullfile(path,filename),'Trace');
    assignin('base','Trace',S.Trace);
    miShowTrace_Callback(hObject, eventdata, handles)
end

% --------------------------------------------------------------------
function miShowTrace_Callback(hObject, eventdata, handles)
% hObject    handle to miShowTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
showTrace(handles);

function showTrace(handles)

Trace = evalin('base','Trace');

if numel(Trace)<2
    msgbox('No trace found. Try increasing the radius or the length.','modal')
end

%axes(handles.axes1);
%hold on;
line(Trace(:,1)',Trace(:,2)','Marker','+','Color','g');


% --------------------------------------------------------------------
function miTrace_Histogram_Callback(hObject, eventdata, handles)
% hObject    handle to miTrace_Histogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Trace = evalin('base','Trace');
subset = evalin('base','subset');
X=evalin('base',handles.settings.varx); X=X(subset);
Y=evalin('base',handles.settings.vary); Y=Y(subset);
nbins = str2double(get(handles.tBins,'String'));
r = str2double(get(handles.radius,'String'));

[ C centers ] = trace_histogram(Trace,X,Y,r,nbins);

Trace_Histogram.C = C;
Trace_Histogram.centers = centers;
assignin('base','Trace_Histogram',Trace_Histogram);

figure; area(centers, sum(C));


% --------------------------------------------------------------------
function miDG1_Callback(hObject, eventdata, handles)
% hObject    handle to miDG1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Trace = evalin('base','Trace');
subset = evalin('base','subset');
X=evalin('base',handles.settings.varx); X=X(subset);
Y=evalin('base',handles.settings.vary); Y=Y(subset);
nbins = str2double(get(handles.tBins,'String'));
r = str2double(get(handles.radius,'String'));

% % Collect points along the trace
% [sX sY]=trace_collect(Trace, X, Y, r, 1);
% 
% [a b]=hist(sX,ceil(log(length(sX))/log(2)+1));
% figure;
%     plot(sX, sY, '.');

if nbins<1
    msgbox('You specified 0 bins. I can''t use automatic bin estimation on a trace (yet?). I''m setting it to 100 bins.');
    nbins = 100;
    set(handles.tBins,'String',int2str(nbins));
end

[a b visited] = trace_histogram(Trace, X, Y, r, nbins, 1);
a = sum(a); % Get the total histogram

figure;
    fit = dg_fit(b,a);
    area(b,a,'EdgeColor','none','FaceColor',[.8 .8 .8]); set(handles.axes1,'YTickLabel',[]);
    hold;
    h=plot(fit); set(h,'Color','r'); legend off;
    h=plot(sg_fit(b',a')); set(h,'Color','g'); legend off;
    [ dummy__, dummy__, th_fit] = jth_fit(b',a');
    h=plot(th_fit); set(h,'Color','b'); legend off;
    ylabel(handles.axes1,'Density'); xlabel(handles.axes1,'[nm]');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', [0 0 2.5 2.5]);   
    fit

f25 = dg_fit(b,a,.25)
f60 = dg_fit(b,a,.60)

cfit = coeffvalues(fit);
cf25 = coeffvalues(f25);
cf60 = coeffvalues(f60);
cifit = confint(fit);
cif25 = confint(f25);
cif60 = confint(f60);

fprintf('# \t r \t s \t s \t s \t s25 \t s25 \t s25 \t s60 \t s60 \t s60 \t w \t w \t w \t w_est \n');
fprintf('%d \t %d \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \n',...
    sum(visited>0), r,...
    cfit(2), cifit(1,2)', cifit(2,2)', ...
    cf25(2), cif25(1,2)', cif25(2,2)', ...
    cf60(2), cif60(1,2)', cif60(2,2)', ...
    cfit(3), cifit(1,3)', cifit(2,3)', cfit(3)+.5*2.35*cfit(2))
    


% --- Executes on button press in pbToFigure.
function pbToFigure_Callback(hObject, eventdata, handles)
% hObject    handle to pbToFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h=figure;
% handles.axes1 = gca;
% redraw(handles)

nh = copyobj(handles.axes1,h);
set(nh,'OuterPosition',[0 0 1 1]);
axis(nh,'equal');
set(nh,'color','none');

cm = colormap(handles.axes1);
colormap(nh,cm);


% --------------------------------------------------------------------
function miSigmaProfile_Callback(hObject, eventdata, handles)
% hObject    handle to miSigmaProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Trace subset X Y] = fetch('Trace','subset',handles.settings.varx,handles.settings.vary);
X=X(subset); Y=Y(subset);

nbins = str2double(get(handles.tBins,'String'));
r = str2double(get(handles.radius,'String'));

[A centersY , dummy__, centersX] = trace_histogram(Trace, X, Y, r, nbins, 0);
[sX sY]=trace_collect(Trace, X, Y, r, 1);
[ sigmas means gofs ns sigmas_outliers ]= trace_sigmas(A, centersY);

% Plot
Y = interp1(centersX,abs(sigmas),sX,'nearest','extrap');
figure; scatter(sX,sY,2,Y, 'filled'); axis equal
set(handles.axes1,'PlotBoxAspectRatioMode','auto')
colormap(hot); caxis((caxis-mean(caxis))*1.3+mean(caxis))
colorbar('SouthOutside')

% Output some info on the fit
logger(['Sigmas: ' num2str(sigmas(:)',4)])
logger(['Ns: ' num2str(ns(:)')])
logger(['Sigmas: ' num2str(mean(sigmas),4) ' +-' num2str(std(sigmas),4)])

% --------------------------------------------------------------------
function miTubeFit_Callback(hObject, eventdata, handles)
% hObject    handle to miTubeFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Trace subset X Y] = fetch(...
    'Trace',...
    'subset',...
    handles.settings.varx,...
    handles.settings.vary);
X=X(subset);
Y=Y(subset);

nbins = str2double(get(handles.tBins,'String'));
r = str2double(get(handles.radius,'String'));

[a b ] = trace_histogram(Trace, X, Y, r, nbins, 1);
a = sum(a); % Get the total histogram

nm=true(size(a));
nm(a<[0 a(1:end-1)] | a<[a(2:end) 0])=false;
nmi = find(nm);

[anms anmsi] = sort(a(nm));
asi = nmi(anmsi);

r1=(b(asi(end))-b(asi(end-1)))/2;
r2=r1*2;
s=r1/2;

figure;
    fit = dtube_fit(b,a,s,r1,r2);
    area(b,a);
    hold;
    plot(fit); legend off;


% --------------------------------------------------------------------
function miCropTrace_Callback(hObject, eventdata, handles)
% hObject    handle to miCropTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
r = str2double(get(handles.radius,'String'));

P0 = ginput(1);

Trace0 = evalin('base','Trace');
Trace = Trace0;

% Find the closest trace point to the cursor and crop until there
iLast = find((Trace(:,1)-P0(1)).^2+(Trace(:,2)-P0(2)).^2<r*r);
assignin('base','Trace',Trace(1:iLast,:));

% Draw the cropped trace
redraw(handles);
miShowTrace_Callback(hObject, eventdata, handles);

ButtonName = questdlg('Do you confirm this crop?', ...
                     'Crop confirm', ...
                     'OK','Cancel','Cancel');
switch ButtonName,
    case 'Cancel',
        % Revert
        assignin('base','Trace',Trace0);
        redraw(handles);
        miShowTrace_Callback(hObject, eventdata, handles);
end


% --- Executes when selected object is changed in bgWheel.
function bgWheel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bgWheel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)



function tGamma_Callback(hObject, eventdata, handles)
% hObject    handle to tGamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tGamma as text
%        str2double(get(hObject,'String')) returns contents of tGamma as a double
redraw(handles)

% --- Executes during object creation, after setting all properties.
function tGamma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tGamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ndl = nodiplib()
ndl = getappdata(0,'usediplib')==false;


% --------------------------------------------------------------------
function mSaveTIFF_Callback(hObject, eventdata, handles)
% hObject    handle to mSaveTIFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.pShow,'String'),'Points')
    msgbox('Does not work with point sets. Try KDE or Histogram instead');
    return
end

[filename path]=uiputfile('*.tif');
if filename
    a = getappdata(0,'KDE');
    X = a{1}(1,:); Y = a{2}(:,1); 
    density = a{3};

    minC = str2double(get(handles.minC,'String'));
    maxC = str2double(get(handles.maxC,'String'));

    res = 2^(get(handles.pResolution,'Value')+7); %CAREFUL CHANGING VALS IN CTRL!!!
    pxx = (max(X)-min(X))/res; pxy = (max(Y)-min(Y))/res;

    imwrite(...
        uint16((density-minC)*2^16/(maxC-minC)),...
        fullfile(path,filename),...
        'tif','Resolution',[1/pxx 1/pxy]);
end

% --------------------------------------------------------------------
function mSaveStack_Callback(hObject, eventdata, handles)
% hObject    handle to mSaveStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Export_PALM_Movie_or_Stack(handles); 

% --------------------------------------------------------------------
function mSaveCSV_Callback(hObject, eventdata, handles)
% hObject    handle to mSaveCSV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename path]=uiputfile('*.csv');
if filename
    rows = get(handles.tParameters,'RowName'); N = length(rows);
    ffname = fullfile(path,filename);
    
    M = zeros(N,sum(getappdata(0,'pointsetsubset')));
    rows2='';
    for irow=1:N
        M(irow,:)=evalin('base',[rows{irow} '(getappdata(0,''pointsetsubset''))']);
        rows2=[rows2 ',' char(rows{irow})];
    end
    rows2=rows2(2:end);
    
    fd=fopen(ffname,'w');
    fprintf(fd,'%s\n',rows2);
    fprintf(fd,['%10f' repmat(',%10f',1,N-1) '\n'],M);
    fclose(fd);
end


% --------------------------------------------------------------------
function mEdit_Callback(hObject, eventdata, handles)
% hObject    handle to mEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mCopy_Callback(hObject, eventdata, handles)
% hObject    handle to mCopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strs = get(handles.pShow,'String');
switch strs{get(handles.pShow,'Value')}
    case 'KDE'
    case 'Histogram'
    case 'Histogram + Gauss filter'
    case 'Jittered histogram'
    otherwise
        msgbox('Not implemented yet, only works with histograms & KDE.');
        return
end  

a = getappdata(0,'KDE');
X = a{1}; Y = a{2}; density = a{3};

minC = str2double(get(handles.minC,'String'));
maxC = str2double(get(handles.maxC,'String'));

xxi=uint8((density'-minC)*2^8/(maxC-minC))';

if doScalebar(handles)
    sb = add_scalebar(handles,'white',density);
    xxi(sb>0)=255;
end

ims = ImageSelection(im2java(xxi,feval(getColormapName(handles),256)));
tk=javaMethod('getDefaultToolkit','java.awt.Toolkit');
cp=tk.getSystemClipboard;
cp.setContents(ims,[]);


function doit = doScalebar(handles)
doit = strcmp(get(handles.miScalebar,'Checked'),'on');

function doit = doColorbar(handles)
doit = strcmp(get(handles.miColorbar,'Checked'),'on');

% --------------------------------------------------------------------
function MenuImport_Callback(hObject, eventdata, handles)
% hObject    handle to MenuImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuExport_Callback(hObject, eventdata, handles)
% hObject    handle to MenuExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mSave_Callback(hObject, eventdata, handles)
% hObject    handle to mSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uiputfile('*.mat');

if filename(1)~=0
    watch_on
    
    try
        serialize(handles,fullfile(pathname,filename));
    catch err
        rethrow(err)
    end
    
    watch_off
end


% --------------------------------------------------------------------
function mOpen_Callback(hObject, eventdata, handles)
% hObject    handle to mOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.mat');

if filename(1)~=0
    watch_on
    
    try
        handles=serialize(handles,fullfile(pathname,filename));
        
        guidata(hObject, handles);
        
        redraw(handles);
    catch err
        rethrow(err)
    end
    
    watch_off
end


% --- Executes on selection change in pFrame.
function pFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pFrame contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pFrame
valsFrame = get(handles.pFrame,'String');

handles.settings.varFrame=valsFrame{get(handles.pFrame,'Value')};

guidata(gcf,handles);

redraw(handles)


% --- Executes during object creation, after setting all properties.
function pFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbRefreshFrame.
function pbRefreshFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pbRefreshFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get data range for Y
rows = get(handles.tParameters,'RowName');
minmaxZ = evalin('base',['[min(' rows{get(handles.pFrame,'Value')} ') max(' rows{get(handles.pFrame,'Value')} ')]']);

% Set range on the table
handles=setFramebounds(handles,minmaxZ);
redraw(handles)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

if isfield(handles,'client')
    if ~isempty(handles.client)
        disp('Closing OMERO session');
        handles.client.closeSession();
    end
end

res = questdlg('Would you like to save your work before closing?','Save');

if strcmp(res,'Yes')
    mSave_Callback(hObject, eventdata, handles)
    delete(hObject);
elseif strcmp(res,'No')
    delete(hObject);    
end


% --------------------------------------------------------------------
function mPoints_Callback(hObject, eventdata, handles)
% hObject    handle to mPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mSieve_Callback(hObject, eventdata, handles)
% hObject    handle to mSieve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
res = questdlg('This will keep only the selected points and delete the rest. Do you wish to continue?','Sieve','Yes','No','No');

if strcmp(res,'Yes')
    N0 = handles.settings.N;
    
    sieve(handles);
    
    handles.settings.N = evalin('base','numel(subset)');
    msgbox(['Discarded ' num2str(N0-handles.settings.N) ' points. ' num2str(handles.settings.N) ' remaining.']);
    
    guidata(hObject,handles);
end
guidata(hObject,handles)

% --------------------------------------------------------------------
function mSieveNoXYZ_Callback(hObject, eventdata, handles)
% hObject    handle to mSieveNoXYZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
res = questdlg('This will keep only the selected points and delete the rest. Do you wish to continue?','Sieve','Yes','No','No');

if strcmp(res,'Yes')
    pResetX_Callback(hObject, eventdata, handles)
    pResetY_Callback(hObject, eventdata, handles)
    pbRefreshZ_Callback(hObject, eventdata, handles)
    
    N0 = handles.settings.N;
    
    sieve(handles);
    
    handles.settings.N = evalin('base','numel(subset)');
    msgbox(['Discarded ' num2str(N0-handles.settings.N) ' points. ' num2str(handles.settings.N) ' remaining.']);
end

function sieve(handles)

rows = getVariables(handles,handles.settings.N);
for irow=1:length(rows)
    evalin('base',[rows{irow} '=' rows{irow} '(subset);']);
end
evalin('base','subset=subset(subset);');

function rgb = plotZ_fancy(handles,res,subset,XPosition,YPosition,ZPosition,minZ,maxZ,n,m,minX,maxX,minY,maxY,gamma,minC,maxC,a,b,sbar)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SH: turned jittering off for now - it was causing crashes
% if sigmax, sigmay not defined.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% notrials = 1; % SET NOTRIALS TO 20 FOR JITTERING
%amount = (evalin('base',handles.settings.sigmax)+evalin('base',handles.settings.sigmay))/2;
%amount = amount*0; % TO AVOID JITTERING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nz = 32;
notrials=1;
amount = zeros(size(XPosition));
NN = sum(subset);
density = zeros(res,res,nz);
setProgress(handles,0);
pxx=(maxX-minX)/res; pxy=(maxY-minY)/res; pxz=(maxZ-minZ)/res;
pxVol=pxx * pxy * pxz;
for i=1:notrials
   RR = [round((res-1)*[...
       (XPosition(subset)+randn(NN,1).*amount(subset)-minX)/(maxX-minX) ...
       (YPosition(subset)+randn(NN,1).*amount(subset)-minY)/(maxY-minY) ])+1 ...
         round(nz*(ZPosition(subset)+randn(NN,1).*amount(subset)-minZ)/(maxZ-minZ))];
   RRok = all(RR(:,1:2)<=res,2) & all(RR>=1,2) & RR(:,3)<=nz;

   d = accumarray(RR(RRok,:),1,[res,res,nz])/pxVol;
   if i==1
       density = d;
   else
       density = density + d;
   end

   X = repmat(n,res,1); Y = repmat(m',1,res);
   density = density/notrials;
   
   setProgress(handles,1/notrials)
   drawnow
end

sigma = str2double(get(handles.sigma,'String'));
if nodiplib()
   H = fspecial('gaussian',round(mean([sigma/pxx*6 sigma/pxy*6]))/2*2+1,mean([sigma/pxx sigma/pxy]));
   density = imfilter(density/max(density(:)),H);
else
   density = gaussf(density/max(density(:)),[sigma/pxx sigma/pxy 0]);
end
density = gammaAdjust(density,gamma);

if nodiplib()
   hh = (cumsum(ones(size(density)),3)-1)/nz;
   ss = ones(size(density));
   vv = density/max(density(:));
   RGB0 = reshape(hsv2rgb([hh(:) ss(:) vv(:)]),[size(density) 3]);
   RGB = {squeeze(RGB0(:,:,:,1)) squeeze(RGB0(:,:,:,2)) squeeze(RGB0(:,:,:,3))};            
   di=0;
else
   HSV = joinchannels('HSV',zz(density,'corner')/(nz+1)*2*pi,1+newim(size(density)),density);
   RGB = colorspace(HSV,'RGB');
   di=1;
end

rgb = zeros(size(density,2),size(density,1),3);
for i=1:size(density,3)
   for c=1:3
       rgb(:,:,c) = rgb(:,:,c).*double(1-a*squeeze(density(:,:,i-di)))' + double(b*squeeze(RGB{c}(:,:,i-di)*density(:,:,i-di)))';
   end
end

rgb = (rgb/max(rgb(:)) - minC) / (maxC-minC);

rgb(rgb<0)=0; 
rgb(rgb>1)=1;



function rgb = plotZ_fast(handles,res,subset,XPosition,YPosition,ZPosition,minZ,maxZ,minX,maxX,minY,maxY,gamma,minC,maxC,a,b)
nz = res/8;

pxx=(maxX-minX)/res; pxy=(maxY-minY)/res; pxz=(maxZ-minZ)/nz;
pxVol=pxx * pxy * pxz;

RR = [ceil((res-1)*[...
    (XPosition(subset)-minX)/(maxX-minX) ...
    (YPosition(subset)-minY)/(maxY-minY) ])+1 ...
      ceil(nz*(ZPosition(subset)-minZ)/(maxZ-minZ))];
RR(RR==0)=1;
RRok = all(RR(:,1:2)<=res,2) & all(RR>=1,2) & RR(:,3)<=nz;

density = accumarray(RR(RRok,[2 1 3]),1,[res,res,nz])/pxVol;

sigma = str2double(get(handles.sigma,'String'));
sPix = sigma/pxx;
%gWindow = ceil(5*sPix);
%gKern = fspecial('gaussian',gWindow, sPix);
dMax = max(density(:));
density = density/dMax;
%for ii = 1:size(density,3)
%  density(:,:,ii) = imfilter(density(:,:,ii),gKern,'replicate');
%end
density=double(gaussf(density,sigma./[pxx pxy pxz]));

% ADJUST GAMMA HERE
density(density<0)=0;
density = gammaAdjust(density,gamma);
rgbc = hsv(round(nz*3/2));
rgbc = rgbc(1:nz,:);
%rgb = zeros(size(density,2),size(density,1),3);

Z = reshape(kron(1:size(density,3),ones(size(density,1),size(density,2))),size(density));

%att = cumsum(flip(density./repmat(sum(density,3),1,1,size(density,3)),3),3);
att = 1+sum(density(:))*a*cumsum(density,3);
att(isnan(att))=Inf;

rs = reshape(rgbc(Z,1),size(Z));
gs = reshape(rgbc(Z,2),size(Z));
bs = reshape(rgbc(Z,3),size(Z));

rgb = cat(3,sum(density.* rs./att,3),sum(density.* gs./att,3),sum(density.* bs./att,3));

% alphO = zeros(size(density,2),size(density,1));
% for i=1:size(density,3)
%     D = squeeze(density(:,:,i));    
%     alphA = a*alphO;
%     alphB = b*D;
%     for c=1:3
%         Ca = rgb(:,:,c);
%         Cb = rgbc(i,c);
%         rgb(:,:,c) = alphA.*Ca+(1-alphA).*alphB.*Cb;
%     end
%     alphO = 1-(1-alphO).*(1-D);
% end

rgb = (rgb/max(rgb(:))*max(density(:)) - minC) / (maxC-minC);

rgb(rgb<0)=0; 
rgb(rgb>1)=1;

% --------------------------------------------------------------------
function mOptions_Callback(hObject, eventdata, handles)
% hObject    handle to mOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miColorbar_Callback(hObject, eventdata, handles)
% hObject    handle to miColorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject,'Checked'),'on')
    set(hObject,'Checked','off')
else
    set(hObject,'Checked','on')
end

redraw(handles)

% --------------------------------------------------------------------
function miScalebar_Callback(hObject, eventdata, handles)
% hObject    handle to miScalebar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject,'Checked'),'on')
    set(hObject,'Checked','off')
else
    set(hObject,'Checked','on')
end

redraw(handles)


% --------------------------------------------------------------------
function mAnalyze_Callback(hObject, eventdata, handles)
% hObject    handle to mAnalyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mFIRE_Callback(hObject, eventdata, handles)
% hObject    handle to mFIRE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ss0=getSubset(handles);
res = getRes(handles);
[minX maxX] = getBounds(handles);

linx = linspace(0,res/(maxX-minX)/2,res/2+1)'; dx=linx(2)-linx(1);
nTrials = 3;
frcprofile = zeros(nTrials,res/2+1);
for trials=1:nTrials
    iss0 = find(ss0);
    iss0 = iss0(randperm(length(iss0)));

    iss1 = iss0(1:end/2);
    iss2 = iss0(end/2+1:end);

    ss1 = false(size(ss0)); ss1(iss1)=true;
    ss2 = false(size(ss0)); ss2(iss2)=true;

    assignin('base','subset',ss1);
    D1 = calcHistogram(handles);

    assignin('base','subset',ss2);
    D2 = calcHistogram(handles);

    assignin('base','subset',ss0);

    frcprofile(trials,:)=double(frc(cat(3,D1,D2)));
end

X = linx;
for trials=1:nTrials
    Y = frcprofile(trials,:); Y=Y(:);
    P = polyfit(X,Y,5);
    R = roots(P-[0 0 0 0 0 1/7]);
    FIRE_ = R(abs(imag(R))<100*eps & real(R)<max(linx) & real(R)>0);
    if isempty(FIRE_)
        logger('The resolution threshold of 1/7 was not attained. You can probably use a finer grid to bin your data.');
        return
    end
    FIREs(trials)=FIRE_;
end

FIRE = mean(FIREs);
se = std(FIREs)/sqrt(nTrials);

X = [linx;linx+dx/3;linx+dx/3*2]; % DEPENDS ON nTrials
Y = frcprofile'; Y=Y(:);
P = polyfit(X,Y,5);
R = roots(P-[0 0 0 0 0 1/7]);
%FIRE = R(abs(imag(R))<100*eps & real(R)<max(linx) & real(R)>0);

% ss = (X-FIRE).^2+(Y-1/7).^2 < .3^2;

% % Find first three points with Y~1/7
% Qx = sort(X(abs(Y-1/7)<.1)); Qx=median(Qx(1:3)); Qy = 1/7;
% 
% % Project along normal to the vector from the origin to that point
% %P = [-Qy;Qx];
% %P_ = [X(:) Y(:)] * P;
% %ss = abs(P_)<.05;
% 
% % Collect points in a radius of .1 around that point into ss
% ss = (X-Qx).^2+(Y-Qy).^2 < .1^2;
% 
% % Collect points around centroid into ss
% Qx = mean(X(ss)); Qy= mean(Y(ss));
% ss = (X-Qx).^2+(Y-Qy).^2 < .1^2;
% 
% % Linear interpolate points in ss to y=1/7
% P = polyfit(X(ss),Y(ss),1);
% Qx = roots(P-[0 1/7]);
% 
% % Find points around .1 that and re-extrapolate to y=1/7
% ss = (X-Qx).^2+(Y-Qy).^2 < .1^2;
% P = polyfit(X(ss),Y(ss),1);
% R = roots(P-[0 1/7]);
% 
% % Calculate principal direction and its normal
% [V,D] = eig(cov(X(ss),Y(ss)));
% mainDir = V(:,2);
% pMainDir = [-mainDir(2); mainDir(1)];
% 
% % Project and calc std error
% P_ = [X(ss) Y(ss)] * pMainDir;
% se = std(P_)/sqrt(nnz(ss));

fitx = sort(X); fity = polyval(P,fitx);

figure; plot(linx,frcprofile','b.',fitx,fity,'r-'); axis([0 max(linx) 0 1]); hold;
% quiver(R,1/7,V(1,2),V(2,2));
% plot(X(ss),Y(ss),'g.')

FIRE=1/min(FIRE);
line([0 max(linx)],[1/7 1/7],'Color','g');
line([1/FIRE 1/FIRE],[0 1],'Color','g');
s = sprintf('FIRE = %2.1f +-%.2f [U]\n', FIRE, se);
logger(s);
text(mean(linx),.5,s);


% --- Executes on button press in pbGrouped.
function pbGrouped_Callback(hObject, eventdata, handles)
% hObject    handle to pbGrouped (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pbGrouped
redraw(handles)


% --- Executes on button press in pbCQ.
function pbCQ_Callback(hObject, eventdata, handles)
% hObject    handle to pbCQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'selectedCell') && ~isempty(handles.selectedCell)
    rows = get(handles.tParameters,'RowName');
    data = evalin('base',[rows{handles.selectedCell(1)} '(subset)']);
    q = quantile(data,[.05 .95]);

    setMin(handles, rows{handles.selectedCell(1)},q(1));
    setMax(handles, rows{handles.selectedCell(1)},q(2));
    
    redraw(handles); drawhist(handles, handles.selectedCell(1));
end


% --------------------------------------------------------------------
function miGroup_Callback(hObject, eventdata, handles)
% hObject    handle to miGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

grouping(handles)

handles = reloadData(handles);

set(handles.pID,'Value',find(ismember(get(handles.pID,'String'),'group_ID')));
handles.settings.varID = 'group_ID';

guidata(gcf, handles);

redraw(handles)
% --------------------------------------------------------------------
function miTrack_Callback(hObject, eventdata, handles)
% hObject    handle to miTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tracking(handles)

handles = reloadData(handles);

set(handles.pID,'Value',find(ismember(get(handles.pID,'String'),'group_ID')));
handles.settings.varID = 'group_ID';

guidata(gcf, handles);

redraw(handles)



function edit14_Callback(hObject, eventdata, handles)


function edit14_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit15_Callback(hObject, eventdata, handles)


function edit15_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function mOMERO_Callback(hObject, eventdata, handles)
% hObject    handle to mOMERO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mOMERO_Logon_Callback(hObject, eventdata, handles)
% hObject    handle to mOMERO_Logon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
 
addpath('OMERO.matlab');
addpath('OMEuiUtils');
 
loadOmero();
 
% find paths to OMEuiUtils.jar and ini4j.jar - approach copied from
% bfCheckJavaPath


session = [];
 
% first check they aren't already in the dynamic path
jPath = javaclasspath('-dynamic');
utilJarInPath = false;
for i = 1:length(jPath)
    if strfind(jPath{i},'OMEuiUtils.jar');
        utilJarInPath = true;
    end
    
end
 
if ~utilJarInPath
    path = which('OMEuiUtils.jar');
    if isempty(path)
        path = fullfile(fileparts(mfilename('fullpath')), 'OMEuiUtils.jar');
    end
    if ~isempty(path) && exist(path, 'file') == 2
        javaaddpath(path);
    else
        errordlg('Cannot automatically locate an OMEuiUtils JAR file');
    end
end
 
logon = OMERO_logon();
 
try
    port = logon{2};
    if ischar(port)
        port = str2num(port); 
    end
    client = loadOmero(logon{1},port);
    session = client.createSession(logon{3},logon{4});
catch err
    errordlg('Logon failed!');
end   % end catch
 
if ~isempty(session)
    client.enableKeepAlive(60); % Calls session.keepAlive() every 60 seconds
    handles.session = session;
    handles.client = client;
    handles.userid = session.getAdminService().getEventContext().userId; 
    set(handles.mOMERO_Import,'Enable','on');
    guidata(hObject,handles);
end
 
 
 
 
% --------------------------------------------------------------------
function mOMERO_Import_Callback(hObject, eventdata, handles)
% hObject    handle to mOMERO_Import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
chooser = OMEuiUtils.OMEROImageChooser(handles.client, handles.userid, int32(1));
dataset = chooser.getSelectedDataset();
clear chooser;
if ~isempty(dataset)
    
    session = handles.session;
    annotationList = getDatasetFileAnnotations(session,dataset,'owner', -1);
    
    if isempty(annotationList)                
        return;
    end
    
    n = 1;
    for a=1:length(annotationList)
        name = char(annotationList(a).getFile().getName().getValue());
        if strfind(name,'.h5')
            names{n} = name;
            h5List(n) = annotationList(a);
            n = n + 1;
        end
    end
    
    if isempty(names)
        return;
    end
    
    if length(names) > 0
        [s,v] = listdlg('PromptString','Select an annotation:',...
                'SelectionMode','single',...
                'ListString',names);
    end
            
    originalFile = h5List(s).getFile();
    filename = char(originalFile.getName().getValue())
    
    table = session.sharedResources().openTable(originalFile)
    
    %table = entryUnencrypted.sharedResources().openTable(originalFile);
    %table = resources.openTable(originalFile);
    
 
    % read 1st three columns initially (frame,x,y)
    % full-list is:
    % frame,x,y,id,intensity,precision,bkgstd (?!), sigma,offset
    
    nCols = 5;
    colSubset = 0:nCols-1;
    
    totalRows = table.getNumberOfRows();
    
    % load 4096 points at a time
    nRows = 4096;
    
    workspacename = 'base';
    
    nBlocks = floor(totalRows./nRows) + 1;
    % pre-allocate arrays
    frame = zeros(nBlocks * nRows,1);
    x = zeros(nBlocks * nRows,1);
    y = zeros(nBlocks * nRows,1);
    int = zeros(nBlocks * nRows,1);
    
    h = waitbar(0,'Importing data...');
    
    for block = 0:nBlocks -1 
        
        waitbar(block./(nBlocks-1));
        
        sstart = block * nRows;
        eend = sstart + (nRows -1);
        
        if eend > totalRows -1
            eend = totalRows -1
        end
     
        rowSubset = sstart:eend;
        data = table.slice(colSubset, rowSubset);
        cols = data.columns;
        
        % convrt to matlab numbering
        sstart = sstart + 1;
        eend = eend + 1;
    
        frame(sstart:eend) = double(cols(1).values);
        x(sstart:eend) = double(cols(2).values);
        y(sstart:eend) = double(cols(3).values);
        int(sstart:eend) = double(cols(5).values);
        
        waitbar(block./(nBlocks-1),h);
        
    end
        
    close(h);
    
    table.close();
    
    assignin(workspacename,'frame', frame);
    assignin(workspacename,'x', x);
    assignin(workspacename,'y', y);
    assignin(workspacename,'intensity', int);
    watch_on
    
    varAssignment={{'frame','frame'},{'x','x'},{'y','y'} };
    
    nEl = evalin('base',['numel(',varAssignment{1}{2},')']);
    handles.settings.N = nEl;
    set(handles.tFilename,'String',filename);
   guidata(handles.output, handles);
   reloadData(handles);
   setPSVar(handles,varAssignment);
   handles=guidata(handles.output);
   reloadData(handles);
   handles=guidata(handles.output);
   redraw(handles);
   handles=guidata(handles.output);
   autoMin(handles);
   handles=guidata(handles.output);
   autoMax(handles);
   handles=guidata(handles.output);
   redraw(handles);
   
   watch_off
 
   
        
end

