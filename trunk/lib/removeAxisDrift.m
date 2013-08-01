%-----------------------------------------------------
function xc = removeAxisDrift(x,t,xDrift,tUn);
%first, sort x,t in time
%then unsort at end

[tSort ix]= sort(t);
xSort=x(ix);

kk=1;
tCur = tUn(kk);
for ii = 1:numel(tSort)
   while tSort(ii)~=tCur  
       kk = kk+1;
       tCur = tUn(kk);
   end
   xDriftCur = xDrift(kk);
   xSort(ii) = xSort(ii) - xDriftCur;
end

xc = unsort(xSort,ix);


%-----------------------------------------------------
function xOut = unsort(x,ix)

unsorted = 1:numel(ix);
newIx(ix) = unsorted;
xOut = x(newIx);

%-----------------------------------------------------
