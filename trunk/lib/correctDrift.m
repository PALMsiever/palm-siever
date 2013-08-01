function [xc,yc,tDrift,xDrift,yDrift,zc,zDrift]  = correctDrift(driftTracks,nSpline,t, x,y, z)
if isfield(driftTracks{1},'z')
   isCorrectZ = true;
else
   isCorrectZ = false;
end

tUn = unique(sort(t));
tDrift=tUn;

%get cell of driftTracks from driftTracks
if ~isCorrectZ
   [xTr, yTr,tTr] = getTrackCell(driftTracks);
else
   [xTr, yTr,tTr,zTr] = getTrackCell(driftTracks);
end

%for each axis
xDrift = getDrift(xTr,tTr,tUn,nSpline);
xc = removeAxisDrift(x,t,xDrift,tUn);
yDrift = getDrift(yTr,tTr,tUn,nSpline);
yc = removeAxisDrift(y,t,yDrift,tUn);
if isCorrectZ
   zDrift = getDrift(zTr,tTr,tUn,nSpline);
   zc = removeAxisDrift(z,t,zDrift,tUn);
end

%-----------------------------------------------------
function xDrift = getDrift(xTr,tTr,tUn,nSpline)
nPts = numel(xTr);
nFrame = numel(tUn);
xAll = zeros(nFrame,nPts);
for ii = 1:numel(xTr)
   xAll(:,ii) = getSplineToData(tTr{ii},xTr{ii},tUn,nSpline);
end
xDrift = combineAllDriftTracks(xAll,tUn);

%-----------------------------------------------------
function x = getSplineToData(tTr,xTr,tUn,nSpline)
%returns NaN for tUn outside range of tTr

xTr0=xTr;tTr0=tTr;
%delete any nan's
xtNaN = find(isnan(tTr) | isnan(xTr));
tTr(xtNaN) =[];
xTr(xtNaN) =[];
%tidy up the vectors
[tTr ix] = sort(tTr);
xTr= xTr(ix);

[tTr ia] = unique(tTr);
xTr = xTr(ia);

xDr =splinefit(tTr,xTr,nSpline,'r');
xTrSpline = ppval(xDr,tTr);
x = interp1(tTr,xTrSpline,tUn);


%-----------------------------------------------------
function [xTr, yTr,tTr,zTr] = getTrackCell(driftTracks)

for ii = 1:numel(driftTracks)
   xTr{ii} = driftTracks{ii}.x;
   yTr{ii} = driftTracks{ii}.y;
   tTr{ii} = driftTracks{ii}.t;
   if isfield(driftTracks{ii},'z')
      zTr{ii} = driftTracks{ii}.z;
   end
end

