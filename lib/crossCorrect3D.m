function [xc,yc,tDrift,xDrift,yDrift,zc,zDrift] = crossCorrect3D(stormData, minImPointPerArea,minFrame,stormPixSize,SccfWindowArea,plotOn)

if ~exist('plotOn','var')
   plotOn = false;
end

t = stormData(:,1);
x = stormData(:,2);
y = stormData(:,3);
is3d = false;
if size(stormData,2) ==4 
   is3d=true;
   z = stormData(:,4);
end

fprintf('Calculating drift XY...\n');
[driftXY] = getStormDrift3([t,x,y],minImPointPerArea,minFrame,stormPixSize,SccfWindowArea);
fprintf('Done\n');

drift.t = driftXY(:,1);
drift.x = driftXY(:,2);
drift.y = driftXY(:,3);
tDrift = drift.t;
xDrift = drift.x;
yDrift = drift.y;

if is3d
   fprintf('Calculating drift XZ...\n');
   [driftXZ] = getStormDrift3([t,x,z],minImPointPerArea,minFrame,stormPixSize,SccfWindowArea);
   fprintf('Done\n');
   fprintf('Calculating drift YZ...\n');
   [driftYZ] = getStormDrift3([t,y,z],minImPointPerArea,minFrame,stormPixSize,SccfWindowArea);
   fprintf('Done\n');
   drift.z= mean([driftXZ(:,3),driftYZ(:,3)],2);
   zDrift = drift.z;
end


%correct drift
fprintf('Subtacting drift...\n');
xc = removeAxisDrift(x,t,drift.x,drift.t);
yc = removeAxisDrift(y,t,drift.y,drift.t);
if is3d
   zc = removeAxisDrift(z,t,drift.z,drift.t);
end

if plotOn
   figure;
   hold all
   plot(drift.t,drift.x);
   plot(drift.t,drift.y);
   if isfield(drift,'z')
      plot(drift.t,drift.z);
      legend('x','y','z');
   else
      legend('x','y');
   end
   title('Drift (xCor estimated)');
   xlabel('Time');
   ylabel('Drift');
end

