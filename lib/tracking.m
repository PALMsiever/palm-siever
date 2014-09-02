function grouping(handles)

x = getX(handles);
y = getY(handles);
frame = getF(handles);
subset = getSubset(handles);

%%%%%%  READ IN PARAMETERS %%%%%%%

prompt={'Maximum allowed gap between ''blinks'' [frames]: ','Maximum distance between two events [data units]:'};
name='Grouping/merging multiple events';
numlines=1;
defaultanswer={'0','50'};

answer=inputdlg(prompt,name,numlines,defaultanswer);
drawnow; pause(0.05);  % this line prevents Matlab crash casued by inputdlg. See http://www.tuicool.com/articles/ZnuQnmq

if isempty(answer) 
    return
end

maxF = str2double(answer{1});
maxD = str2double(answer{2});
    
if isnan(maxF) || isnan(maxD)
    errordlg('Unable to understand your input..');
    return
end

%%%%%%%%%%%%%%
%
%maxD2 = maxD^2;
%
%if maxF>max(frame)
%    maxF=0;
%end
%
%t0 = cputime;
%t00 = t0;
%%cons is a linked list of points which are grouped
%% contains addresses of other point within a track
%cons = zeros(size(x));
%for ff = min(frame):max(frame)-maxF
%    ss = subset & frame>=ff & frame<=(ff+maxF);
%    
%    iss=find(ss)';
%    
%    xx = x(iss);
%    yy = y(iss);
%    
%    %for all points
%    for ii=1:length(iss)-1
%        %find the nearest point
%        [ mind2 imind2 ]= min((xx(ii)-xx(ii+1:end)).^2+(yy(ii)-yy(ii+1:end)).^2);
%        %if its within the minimum radius, link it to the current point
%        if mind2 < maxD2
%            cons(iss(ii))=iss(ii+imind2);
%        end
%    end
%    
%    if cputime-t0 >1
%       logger(sprintf('%d/%d frames done. ETA: %.2f secs',ff,max(frame)-maxF,(max(frame-maxF)-ff)/ff*(cputime-t00)));
%       drawnow
%       t0=cputime;
%    end
%end
%
%% Remove self
%cons(cons'==(1:length(cons)))=0;
%
%% Calculate group frame IDs
%N = size(cons,1);
%curfg=1; group_frame_id=ones(N,1); group_id_=1:N;
%while sum(group_frame_id==curfg)>0
%    group_frame_id(cons(group_frame_id==curfg & cons>0))=group_frame_id(cons(group_frame_id==curfg & cons>0))+1;
%    group_id_(cons(group_frame_id==curfg & cons>0))=group_id_(group_frame_id==curfg & cons>0);
%    curfg=curfg+1;
%end
%
%[zzz_ zzz_ group_id]= unique(group_id_);

[group_id,group_frame_id] = gtrack_PSwrapper(x,y,frame,subset,maxF,maxD)
% Export
assignin('base','group_frame_ID',group_frame_id);
assignin('base','group_ID',group_id(:));
%assignin('base','group_next__',cons);

waitfor(msgbox(['Done! Found ' num2str(max(group_id)) ' grouped particles. Toggle the ''Grouped'' button to show grouped data']));

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function [group_id,group_frame_id] = gtrack_PSwrapper(x,y,frame,subset,blink_memory,max_displacement)
%function [group_id,group_frame_id] = gtrack_PSwrapper(x,y,frame,subset,blink_memory,max_displacement)
% Wrapper for the Crocker and Grier tracking algorithm.

nMol = sum(subset);
id = (1:nMol)';
xyit_subset = [x(subset),y(subset),id, frame(subset)];
%optional parameters
param.mem = blink_memory;
param.dim = 2;
param.good= false;
param.quiet = false;

res = gtrack(xyt_subset,max_displacement,param);
%FROM gtrack doc:
% ;     
% ;     For the input data structure (positionlist):
% ;         (x)      (y)      (t)
% ;     pos = 3.60000      5.00000      0.00000
% ;           15.1000      22.6000      0.00000
% ;           4.10000      5.50000      1.00000 
% ;           15.9000      20.7000      2.00000
% ;           6.20000      4.30000      2.00000
% ;
% ;     IDL> res = track(pos,5,mem=2)
% ;
% ;     track will return the result 'res'
% ;         (x)      (y)      (t)          (id)
% ;     res = 3.60000      5.00000      0.00000      0.00000
% ;           4.10000      5.50000      1.00000      0.00000
% ;           6.20000      4.30000      2.00000      0.00000
% ;           15.1000      22.6000      0.00000      1.00000
% ;           15.9000      20.7000      2.00000      1.00000
% 
% We need to do some hacking to get the required PS output 
% We need
%   a) a proper frame count column 'group_frame_id'
%   b) the particles reset in the order they came in

%remember we're still dealing with subsets
x_s = res(:,1);
y_s = res(:,2);
id_s = res(:,3);
frame_s = res(:,4);
group_id_s = res(:,5);

%put them back in the correct order
[id_s idx]= sort(id_s);
x_s = x_s(idx);
y_s = y_s(idx);
frame_s = frame_s(idx);
group_id_s = group_id_s(idx);

%group_frame_id is the frame # "within the track"
% Ie for each track, first localization group_frame_id = 1
% %then next loc group_frame_id=2, etc.
group_frame_id_s = zeros(size(x_s));
nTrack = max(group_id_s);
for ii =1:nTrack
   molCur = (group_id_s == ii);
   group_frame_id_s(molCur) = frame_s(molCur)-min(frame_s(molCur))+1;%group_frame_id starts at 1
end

group_id = zeros(size(x));
group_frame_id = zeros(size(x));

group_id(subset) = group_id_s;
group_frame_id(subset) = group_frame_id_s;


