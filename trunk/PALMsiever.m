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

% Last Modified by GUIDE v2.5 06-Dec-2012 11:18:03

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

setappdata(0,'self',handles.figure1);

% Add 'range' function to base
assignin('base','range',@(x) max(x)-min(x))
assignin('base','drawing','false')

% Choose default command line output for PALMsiever
handles.output = hObject;

if ~isempty(varargin)
    handles.settings.varx=varargin{1};
    handles.settings.vary=varargin{2};
    if numel(varargin)>2
        handles.settings.sigmax=varargin{3};
        handles.settings.sigmay=varargin{4};
    else
        handles.settings.sigmax=['Dummy_sigma_' varargin{1}];
        handles.settings.sigmay=['Dummy_sigma_' varargin{2}];
        assignin('base',handles.settings.sigmax,ones(size(evalin('base',varargin{1}))));
        assignin('base',handles.settings.sigmay,ones(size(evalin('base',varargin{2}))));
    end
    handles.settings.N=evalin('base',['length(' varargin{1} ')']);   
else
    N = 1000; R = 1000; s = 20;
    T = linspace(0,2*pi,N)';
    X = sin(T)*R;
    Y = cos(T)*R;

    X = X+randn(1000,1)*s;
    Y = Y+randn(1000,1)*s;
    Z = randn(1000,1)*s;
    sigmax = s*ones(size(X));
    sigmay = s*ones(size(Y));
    
    %workaround for calling palmsiever without arguments
    %nPts = 100;
    %X = rand(nPts,1); Y=X;sigmax = X;sigmay=X;
    %T = (1:nPts)';
    assignin('base','X',X);assignin('base','Y',Y);assignin('base','T',T);
    assignin('base','Dummy_sigma_X',sigmax);assignin('base','Dummy_sigma_Y',sigmay);
    handles.settings.varx='X';
    handles.settings.vary='Y';
    handles.settings.varFrame ='T';
    handles.settings.sigmax='Dummy_sigma_X';
    handles.settings.sigmay='Dummy_sigma_Y';
    handles.settings.N=size(X,1);
end
guidata(handles.output, handles);
handles=reloadData(handles);

rows2 = get(handles.pXAxis,'String');
ix = find(cellfun(@(x) strcmp(x,handles.settings.varx),rows2),1); set(handles.pXAxis,'Value',ix);
iy = find(cellfun(@(x) strcmp(x,handles.settings.vary),rows2),1); set(handles.pYAxis,'Value',iy);

% Update Z Axis too
set(handles.pZAxis,'String',rows2);
handles.settings.varz=rows2{1};
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

% Set default action to Z
set(handles.bgWheel,'SelectedObject',handles.rbZ);

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
        curSubset = evalin('base',[rows{irow} ' >= ' num2str(data{irow,1}) ' & ' ...
            rows{irow} ' <= ' num2str(data{irow,2})]);

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

[minX maxX minY maxY] = getBounds(handles);

minC = str2double(get(handles.minC,'String'));
maxC = str2double(get(handles.maxC,'String'));
nbins = str2double(get(handles.tBins,'String'));

setappdata(0,'pointsetsubset',subset);

NP = sum(subset);

if NP<1
    warning('No points to display')
    return
end

set(handles.tNumPoints,'String',num2str(NP));

is3D = get(handles.pShow,'Value') == 7;

res = getRes(handles);

r = str2double(get(handles.radius,'String'));

% Calculate pixel sizes
pxx = (maxX-minX)/res; pxy = (maxY-minY)/res;
set(handles.lPxSize,'String',[num2str(pxx) 'x' num2str(pxy)]);
switch get(handles.pShow,'Value')
    case 1 % "Points"
        scatter(handles.axes1,XPosition(subset),YPosition(subset),r,ID(subset),'.');
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
        density = gammaAdjust(density,gamma);
        imagesc(n,m,density',[minC maxC]); colormap hot
        setappdata(0,'KDE',{X,Y,density'})
    case 8 % "Jittered histogram"
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
    case 7 % Histogram 3D Hue Opacity
        n=linspace(minX,maxX,res);
        m=linspace(minY,maxY,res);
        ZPosition=evalin('base',handles.settings.varz);
        [minZ maxZ]=getZbounds(handles);
        nz = 32; notrials = 1; % SET NOTRIALS TO 20 FOR JITTERING
        NN = sum(subset);
        amount = (evalin('base',handles.settings.sigmax)+evalin('base',handles.settings.sigmay))/2;
        amount = amount*0; % TO AVOID JITTERING
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
        a = .5; b=1; sbar = .625;

        rgb = zeros(size(density,2),size(density,1),3);
        for i=1:size(density,3)
            for c=1:3
                rgb(:,:,c) = rgb(:,:,c).*double(1-a*squeeze(density(:,:,i-di)))' + double(b*squeeze(RGB{c}(:,:,i-di)*density(:,:,i-di)))';
            end
        end
        
        rgb = (rgb/max(rgb(:)) - minC) / (maxC-minC);
        
        rgb(rgb<0)=0; 
        rgb(rgb>1)=1;
        
        sz = [res/4 res/32]; 
        szt = [res/4 3]; 
        cbx = 10; cby = res-sz(2)-10*(res/256);
        szs = [round(sbar/pxx) res/128];
        sbx = res-5*(res/256)-szs(1); sby = res-szs(2)-20*(res/256);

        maxc = max(rgb(:));

        if ~nodiplib()
            tickss = colorspace(...
            joinchannels('HSV',...
            xx(szt,'corner')/szt(1)*2*pi,...
            newim(szt)+1,...
            newim(szt)+maxc),'RGB');
        
            for i=0:10:(szt(1)-1)
                tickss{:}(i,:)=1;
            end

            colb = colorspace(...
                joinchannels('HSV',...
                xx(sz,'corner')/sz(1)*2*pi,...
                newim(sz)+.5,...
                (1-yy(sz,'corner')/sz(2))*maxc),'RGB');

            rgb(cby+(1:sz(2)),cbx+(1:sz(1)),:)=cat(3,double(colb{1}),double(colb{2}),double(colb{3}));
            rgb(cby+(1:szt(2))-3,cbx+(1:szt(1)),:)=cat(3,double(tickss{1}),double(tickss{2}),double(tickss{3}));
            rgb(sbx+(1:szs(2)),sby+(1:szs(1)),:)=maxc;
        end
        
        imagesc(n,m,rgb);
        
        if ~nodiplib()
            text(minX+cbx*pxx,minY+pxy*(cby-5*(res/256)),num2str(minZ),'Color','w', 'HorizontalAlignment','left')
            text(minX+(cbx+sz(1))*pxx,minY+pxy*(cby-5*(res/256)),num2str(maxZ),'Color','w', 'HorizontalAlignment','right')
            text(minX+pxx*(sby+szs(1)/2),minY+pxy*(sbx-5*(res/256)),[num2str(100) ' nm'],'Color','w', 'HorizontalAlignment','center')
            %text(minY+pxy*(cbx+sz(1)),minX+pxx*(cby-5),num2str(maxZ),'Color','w', 'HorizontalAlignment','right')
        end        
    case 3 % "KDE"
        if NP>0
            [bandwidth,density,X,Y]=kde2d([XPosition(subset) YPosition(subset)],res,...
                [min(XPosition(subset)) min(YPosition(subset))],...
                [max(XPosition(subset)) max(YPosition(subset))]);
            pxArea=(maxX-minX)/res * (maxY-minY)/res;
            density = density*sum(subset)/pxArea;
            
            fprintf('Bandwidth: %f\n', bandwidth);
        else
            density = zeros(res);
        end
        density = gammaAdjust(density,gamma);
        imagesc(X(1,:),Y(:,1),density,[minC maxC])
        setappdata(0,'KDE',{X,Y,density})
        set(gca,'Color',[0 0 0])
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
    case 6 % Gaussians
%         if NP>0
%             points = [XPosition(subset)-minX YPosition(subset)-minY];
%             % Convert points to indexes from 1:n and 1:m
%             [xi X]= quantization(XPosition(subset),minX,maxX,res);
%             [yi Y]= quantization(YPosition(subset),minY,maxY,res);
%             pxSize = [(maxX-minX)/res (maxY-minY)/res];
%             sigmaX = evalin('base',handles.settings.sigmax);
%             sigmaY = evalin('base',handles.settings.sigmay);
%             sigmaX=sigmaX(subset);sigmaY=sigmaY(subset);
%             offX = (XPosition(subset)-minX)/(maxX-minX) - xi/res;
%             offY = (YPosition(subset)-minY)/(maxY-minY) - yi/res;
% 
%             density = render_gauss(pxSize,[xi yi],[sigmaX sigmaY],[offX offY],[res res],...
%                 [minX minY (maxX-minX) (maxY-minY)]);
%             offset = points-ceil(points); points = ceil(points);
%         else
%             n=linspace(minX,maxX,res); m=linspace(minY,maxY,res);
%             density = zeros(res);
%             X = repmat(n,res,1); Y = repmat(m',1,res);
%         end
%         imagesc(X,Y,density,[minC maxC])
%         setappdata(0,'KDE',{X,Y,density})
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
    case 9 %"Delaunay Triangulation"
        X=XPosition(subset); Y=YPosition(subset);
        T = delaunay(X,Y);
        Ax = X(T(:,1)); Bx = X(T(:,2)); Cx = X(T(:,3)); Ay = Y(T(:,1)); By = Y(T(:,2)); Cy = Y(T(:,3));
        C = -abs(.5*( Ax.*(By-Cy)+Bx.*(Cy-Ay)+Cx.*(Ay-By) ));
        cla(handles.axes1);
        patch('Faces',T,'Vertices',[X Y],'FaceColor','flat','EdgeColor','none','FaceVertexCData',C,'CDataMapping','scaled');
        caxis([minC maxC]);
        set(gca,'Color',[0 0 0])
        setappdata(0,'Tri',{X,Y,T,C})
end

axis ij
if ~is3D
    updateColormap(handles)
end
set(gca,'ButtonDownFcn',@axes1_ButtonDownFcn);
set(allchild(gca),'ButtonDownFcn',@axes1_ButtonDownFcn);
axis manual
set(gca,'XLim', [minX maxX], 'YLim', [minY maxY])

function updateColormap(handles)
cmps = get(handles.pColormap,'String');
cmpi = get(handles.pColormap,'Value');
colormap(eval(cmps{cmpi}))

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

XYZ=get(gca,'CurrentPoint');
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

if isempty(eventdata.Indices)
    return
end

rows = get(handles.tParameters,'RowName');
data = evalin('base',[rows{eventdata.Indices(1)} '(subset)']);

hist(handles.axes1,data,100);

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
    case 7 %'Histogram 3D'
        set(handles.minC,'String',num2str(0));
    case 8 %'Jittered histogram'
        set(handles.minC,'String',num2str(0));
    case 9 %'Delaunay Triangulation'
        Tr = getappdata(0,'Tri');
        set(handles.minC,'String',num2str(prctile(Tr{4},5)));
    otherwise
        msgbox('Not implemented yet for this visualization');
        return
end  

% --- Executes on button press in bAutoMaxC.
function bAutoMaxC_Callback(hObject, eventdata, handles)
% hObject    handle to bAutoMaxC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoMax(handles)

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
    case 7 %'Histogram 3D'
        set(handles.maxC,'String',val);
    case 8 %'Jittered histogram'
        set(handles.maxC,'String',val);
    case 9 %'Delaunay Triangulation'
        Tr = getappdata(0,'Tri');
        set(handles.maxC,'String',num2str(prctile(Tr{4},100)));
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

XYZ=get(gca,'CurrentPoint');
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

handles = reloadData(handles);
guidata(gcf,handles);


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

renderings = get(handles.pShow,'String');
i = get(handles.pShow,'Value');
res = strcmp(renderings{i},'Points');


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
    pluginsDir= fullfile(fileparts(which('palmsiever_setup')),'plugins');
    addpath(pluginsDir)
    
    plugins = dir(fullfile(pluginsDir,'*.m'))';
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
    feval(name,guidata(gcf))
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

miShowTrace_Callback(hObject, eventdata, handles)

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
Trace = evalin('base','Trace');

if numel(Trace)<2
    msgbox('No trace found. Try increasing the radius or the length.','modal')
end

axes(handles.axes1);
line(Trace(:,1)',Trace(:,2)','Marker','+','Color','r');


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
    area(b,a,'EdgeColor','none','FaceColor',[.8 .8 .8]); set(gca,'YTickLabel',[]);
    hold;
    h=plot(fit); set(h,'Color','r'); legend off;
    h=plot(sg_fit(b',a')); set(h,'Color','g'); legend off;
    [ ~, ~, th_fit] = jth_fit(b',a');
    h=plot(th_fit); set(h,'Color','b'); legend off;
    ylabel(gca,'Density'); xlabel(gca,'[nm]');
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

copyobj(handles.axes1,h);
set(gca,'OuterPosition',[0 0 1 1]);


% --------------------------------------------------------------------
function miSigmaProfile_Callback(hObject, eventdata, handles)
% hObject    handle to miSigmaProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Trace subset X Y] = fetch('Trace','subset',handles.settings.varx,handles.settings.vary);
X=X(subset); Y=Y(subset);

nbins = str2double(get(handles.tBins,'String'));
r = str2double(get(handles.radius,'String'));

[A centersY , ~, centersX] = trace_histogram(Trace, X, Y, r, nbins, 0);
[sX sY]=trace_collect(Trace, X, Y, r, 1);
[ sigmas means gofs ]= trace_sigmas(A, centersY);
Y = interp1(centersX,abs(sigmas),sX,'nearest','extrap');

figure; scatter(sX,sY,10,Y, 'filled'); axis equal
colormap(hot); caxis((caxis-mean(caxis))*1.3+mean(caxis))
colorbar('SouthOutside')

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

if isPoints(handles)
    msgbox('Does not work with scatterplot. Try KDE or Histogram instead');
    return
end

[filename path]=uiputfile('*.tif');
if filename
    density = renderStack(handles);

    minC = str2double(get(handles.minC,'String'));
    maxC = str2double(get(handles.maxC,'String'));

    [minX maxX minY maxY] = getBounds(handles);
    res = getRes(handles);
    
    pxx = (maxX-minX)/res; pxy = (maxY-minY)/res;

    physDims.dimensions = pxx;
    physDims.dimensionUnits = 'nm';
    
    % To 16-bits
    density = uint16((density-minC)*2^16/(maxC-minC)); 
    
    if nodiplib()
        writeim(...
            density,...
            fullfile(path,filename),...
            'TIFF',0,physDims);
    else
        nslices = size(density,3);
        for slice = 1:size(density,3)
            imwrite(squeeze(density(:,:,slice)),...
                fullfile(path,sprintf([filename(1:end-4) '_%0' num2str(ceil(log(nslices+eps)/log(10))) 'd' filename(end-3:end)],slice)),'TIFF');
        end
    end
end

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
        msgbox('Not implemented yet, only works with KDE.');
        return
end  

a = getappdata(0,'KDE');
X = a{1}; Y = a{2}; density = a{3};

minC = str2double(get(handles.minC,'String'));
maxC = str2double(get(handles.maxC,'String'));

xxi=uint8((density'-minC)*2^8/(maxC-minC))';
ims = ImageSelection(im2java(xxi));
tk=javaMethod('getDefaultToolkit','java.awt.Toolkit');
cp=tk.getSystemClipboard;
cp.setContents(ims,[]);


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
end


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



