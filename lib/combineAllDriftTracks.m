%%% Internal function for the drift correction plugin
function [xDrift, xAllCor] = combineAllDriftTracks(xAll,tUn)

xDrift = NaN*ones(numel(tUn),1);
xAllRaw = xAll;
nPts = size(xAll,2);
nTime = numel(tUn);
lastGoodVal = 0;
isLastValNaN = 1;
for ii = 1:nTime
   curRow = xAll(ii,:);
   goodCol = find(~isnan(curRow));
   if all(isnan(curRow))
      xDrift(ii) = lastGoodVal;
      isLastValNaN = 1;
   elseif ~isLastValNaN % no need for offset correction
      xDrift(ii) = mean(curRow(goodCol));
      lastGoodVal = xDrift(ii);
      isLastValNaN = 0;
   else %last val is nan, need to correct offset
      for jj = goodCol
         xAll(:,jj) = xAll(:,jj) - xAll(ii,jj) + lastGoodVal;
      end
      xDrift(ii) = lastGoodVal;
      isLastValNaN = 0;%ie next time we can just take the mean
   end
end
      
xAllCor = xAll;

%
%
%
%%%order the tracks by min timepoint
%%colStartIsOk = zeros(1,nTr); %keep track of which columns have been corrected
%%colEndIsOk = zeros(1,nTr); %keep 
%%
%%%do the starts
%%while any(colStartIsOk==0)
%%   [r,c,v] = findFirstGoodNum(xAll(:,~colStartIsOk));
%%
%%   if all(colStartIsOk==0)%ie if this is the first track to be corrected
%%      corVal = 0;
%%   else
%%      corVal = mean(xAll(r,find(colStartIsOk)),2);
%%      %need to check if corVal is NaN - if so interpolate from last known good value
%%      if isnan(corVal)
%%
%%
%%   end
%%   xAll(:,c) = xAll(:,c) - xAll(r,c) + corVal;
%%   xAll(1:r,c) = xAll(r,c);
%%   colStartIsOk(c) = 1;
%%end
%%
%%xDrift = xAll;
%%
%
%%------------------------------------------------
%function [r,c,v] = findFirstGoodNum(xAll)
%nTr = size(xAll,2);
%
%r = Inf; c = 1;
%for ii = 1:nTr
%   [rI,cI] = find(~isnan(xAll(:,ii)),1,'first');
%   if rI<r
%      r = rI;
%      c = ii;
%   end
%end
%v = xAll(r,c);
%%%------------------------------------------------
%%function [r,c,v] = findLastGoodNum(xAll)
%%nTr = size(xAll,2);
%%
%%r = Inf; c = 1;
%%for ii = 1:nTr
%%   [rI,cI] = find(~isnan(xAll(:,ii)),1,'last');
%%   if rI<r
%%      r = rI;
%%      c = ii;
%%   end
%%end
%%v = xAll(r,c);
