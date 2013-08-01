function grouping(handles)

x = getX(handles);
y = getY(handles);
frame = getF(handles);
subset = getSubset(handles);

%%%%%%  READ IN PARAMETERS %%%%%%%

prompt={'Maximum allowed gap between ''blinks'' [frames]: ','Maximum distance between two events [data units]:'};
name='Grouping/merging multiple events';
numlines=1;
defaultanswer={'3','50'};

answer=inputdlg(prompt,name,numlines,defaultanswer);

if isempty(answer) 
    return
end

maxF = str2double(answer{1});
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
cons = zeros(size(x));
for ff = min(frame):max(frame)-maxF
    ss = subset & frame>=ff & frame<=(ff+maxF);
    
    iss=find(ss)';
    
    xx = x(iss);
    yy = y(iss);
    
    for ii=1:length(iss)-1
        [ mind2 imind2 ]= min((xx(ii)-xx(ii+1:end)).^2+(yy(ii)-yy(ii+1:end)).^2);
        if mind2 < maxD2
            cons(iss(ii))=iss(ii+imind2);
        end
    end
    
    if cputime-t0 >1
       progress(ff,max(frame)-maxF); drawnow;
       t0=cputime;
    end
end

% Remove self
cons(cons'==(1:length(cons)))=0;

% % Assign ID
% cur = 1; curID = 1; 
% IDs = zeros(N,1);
% while cur <= N
%     if IDs(cur) > 0 % already assigned to a group
%         if cons(cur)==0 % last member of the group
%             IDs(cons(cur))=IDs(cur); 
%         end
%     else
%         IDs(cur)=curID;
%         curID=curID+1;
%     end    
%     cur = cur + 1;
% end

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


