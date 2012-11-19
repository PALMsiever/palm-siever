function varNames = stringToVarName(strings)
% function varNames = stringToVarName(strings)
% Utility function to convert arbitary strings into acceptable matlab variable names

%if it's just a single string, rather than a cell, turn it into a cell temporarily for simplicity
if iscell(strings)
   varNames = strings;
elseif ischar(strings);
   varNames = {strings};
else
   error('Input variable must be string or cell of strings');
end

%strip any preceding non-alphanumerics
varNames =regexprep(varNames,'^[^a-zA-Z]+','');
%turn any character that is not alphabetic, numeric, or underscore to _
varNames = regexprep(varNames,'\W+','_');
%strip trailing '_'
varNames = regexprep(varNames,'_$','');
%test if any of the varNames are empty
kk=1;
for ii = 1:numel(varNames)
   if isempty(varNames{ii})
      varNames{ii} = ['a',num2str(kk)];
      kk = kk+1;
   end
end
for ii = 1:numel(varNames)
   for jj = 1:numel(varNames)
      kk = 1;
      if ii~=jj && strcmp(varNames{ii},varNames{jj})
         varNames{jj} = [varNames{jj},num2str(kk)];
         kk = kk+1;
      end
   end
end


%if the input was just a single string, convert the output back to a string
if ~iscell(strings) && ischar(strings)
   varNames = varNames{1};
end
