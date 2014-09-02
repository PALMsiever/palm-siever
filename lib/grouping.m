function grouping(handles)

x = getX(handles);
y = getY(handles);
frame = getF(handles);
subset = getSubset(handles);

%%%%%%  READ IN PARAMETERS %%%%%%%

prompt={'Maximum gap (off-time) between localizations [frames]: ','Maximum distance between two events [data units]:'};
name='Grouping/merging multiple events';
numlines=1;
defaultanswer={'0','50'};

answer=inputdlg(prompt,name,numlines,defaultanswer); 
drawnow; pause(0.05);  % this line prevents Matlab crash casued by inputdlg. See http://www.tuicool.com/articles/ZnuQnmq


if isempty(answer) 
    return
end

%SH140902
% Requested input above is the 'gap' between localizations
% For a non-blinking fluorophore this is 0 between adjacent frames.
% maxF is the _number of frames_ between adjacent localizations
% Ie minimum of 1 for a single non-blinking fluorophore.
% Since the 'gap' is more commonly asked for in SPT algorithms
% I have left the requested input, but modified maxF so that it
% is consistent with both the prompt and other SPT algs.
% ALSO - rephrased prompt to make meaning clearer
% : 'Maximum allowed gap between ''blinks'' [frames]: 
maxGap = str2double(answer{1});
maxF = maxGap +1; 
maxD = str2double(answer{2});
    
if isnan(maxF) || isnan(maxD)
    errordlg('Unable to understand your input..');
    return
end

%%%%%%%%%%%%%

maxD2 = maxD^2;

if maxF>max(frame)
    maxF=0;
end

t0 = cputime;
t00 = t0;
%cons is a linked list of points which are grouped
% contains addresses of other point within a track
cons = zeros(size(x));
for ff = min(frame):max(frame)-maxF
    ss = subset & frame>=ff & frame<=(ff+maxF);
    
    iss=find(ss)';
    
    xx = x(iss);
    yy = y(iss);
    
    %for all points
    for ii=1:length(iss)-1
        %find the nearest point
        [ mind2 imind2 ]= min((xx(ii)-xx(ii+1:end)).^2+(yy(ii)-yy(ii+1:end)).^2);
        %if its within the minimum radius, link it to the current point
        if mind2 < maxD2
            cons(iss(ii))=iss(ii+imind2);
        end
    end
    
    if cputime-t0 >1
       logger(sprintf('%d/%d frames done. ETA: %.2f secs',ff,max(frame)-maxF,(max(frame-maxF)-ff)/ff*(cputime-t00)));
       drawnow
       t0=cputime;
    end
end

% Remove self
cons(cons'==(1:length(cons)))=0;

% Calculate group frame IDs
N = size(cons,1);
curfg=1; group_frame_id=ones(N,1); group_id_=1:N;
while sum(group_frame_id==curfg)>0
    group_frame_id(cons(group_frame_id==curfg & cons>0))=group_frame_id(cons(group_frame_id==curfg & cons>0))+1;
    group_id_(cons(group_frame_id==curfg & cons>0))=group_id_(group_frame_id==curfg & cons>0);
    curfg=curfg+1;
end

[zzz_ zzz_ group_id]= unique(group_id_);

% Export
assignin('base','group_frame_ID',group_frame_id);
assignin('base','group_ID',group_id(:));
assignin('base','group_next__',cons);

waitfor(msgbox(['Done! Found ' num2str(max(group_id)) ' grouped particles. Toggle the ''Grouped'' button to show grouped data']));


