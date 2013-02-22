function [varargout] = fileIoAscii(fileSpec,ioMode, varargin)
% function fileIoAscii(fileSpec,varargin)
% Parses a fileSpec ini file, and uses it to read in PALM data
%***************
% ioMode: 'ReturnVarNames','Import', 'Export','FileType'
%For import:
%  Input arguments:
%    'Filename',fileName, (optional) ('Workspace', workspaceName)
%      workspaceName: Default = 'base'
%  Output arguments:
%    Assigns all variables in to workspaceName
%     varAssignment - cell containing:
%     {{'x',xColName},
%      {'y',yColName},
%      {'z',zColName}, (optional)
%      {'frame',frameColName} (optional)}
%      {'id',idColName} (optional)}
%For export:
%  Input arguments:
%     'Filename',fileName, (optional) ('Workspace', workspaceName), (optional), 'ColAssingment', colAssignHash
%      workspaceName: Default = 'base'
%      colAssignHash: 2xN cell array hash table, relating variable names expected by function, and actual variable names in workspace
%        ie {colName1, varName1;
%            colName2, varName2;
%            colName3, varName3}
%  Output arguments: 
%    None
%Get file information:
%  Input argumements:
%    
%  Output:
%    varNamesCell

fs = getAsciiFileSpec(fileSpec);

switch ioMode
case 'ReturnVarNames'
   [varNamesCell] = stringToVarName(fs.colNames);
   varargout = {varNamesCell};
case 'ReturnColNames'
   [colNamesCell] = fs.colNames;
   varargout = {colNamesCell};
case 'Import'
   [varAssignment] = importAscii(fs,varargin{:});
   varargout ={varAssignment};
case 'Export'
   exportAscii(fs,varargin{:});
case 'FileType'
   varargout = {fs.fileType};
otherwise
   error('Unrecognised file IO mode');
end

%------------------------------------------------------------
function varAssignment = importAscii(fs,varargin);
nn = numel(varargin);
ii=1;
filename ='';
workspaceName = 'base';
while ii <= nn
   if strcmp(varargin{ii},'Filename')
      filename = varargin{ii+1};
      ii = ii+2;
   elseif strcmp(varargin{ii},'Workspace')
      workspaceName = varargin{ii+1};
      ii = ii+2;
   end
end

if isempty(filename)
   error('File name not specified');
else
   fdata = importdata(filename, fs.delimiter, fs.nHeaderLines);
   fColNames = fdata.colheaders;
   varNames = stringToVarName(fColNames);
   assignToWorkSpace(fdata.data,varNames,workspaceName);
   varAssignment=assignVars(varNames,fs);
end
%------------------------------------------------------------
function exportAscii(fs,varargin);
nn = numel(varargin);
ii=1;
filename ='';
workspaceName = 'base';
useColHash= false;
while ii <= nn
   if strcmp(varargin{ii},'Filename')
      filename = varargin{ii+1};
      ii = ii+2;
   elseif strcmp(varargin{ii},'Workspace')
      workspaceName = varargin{ii+1};
      ii = ii+2;
   elseif strcmp(varargin{ii},'ColAssingment')
      useColHash = true;
      colAssignHash= varargin{ii+1};
      ii = ii+2;
   end
end

if isempty(filename)
   error('File name not specified');
else
   colNames = fs.colNames;
   varNames = stringToVarName(colNames);
   if useColHash
      [dataColNames, data] = getDataFromWS(workspaceName,colNames, varNames,colAssignHash);
   else
      [dataColNames, data] = getDataFromWS(workspaceName,colNames, varNames);
   end
end

writePalmAscii(filename, dataColNames,data,fs.delimiter, fs.numberFormat,fs.headerPrefix,fs.headerPostfix);

%---------------------------------------------
function writePalmAscii(filename,dataColNames,data,delimiter, numberFormat, headerPrefix,headerPostfix)
fid = fopen(filename,'w');
%header prefix
fprintf(fid,headerPrefix);
% column names 
nCol = numel(dataColNames);
for ii = 1:nCol
   fprintf(fid,dataColNames{ii});
   if ii < nCol
      fprintf(fid,delimiter);
   else
      fprintf(fid,'\n');
   end
end
%header postfix
fprintf(fid,headerPostfix);
fclose(fid);
dlmwrite(filename, data,'-append','delimiter',delimiter,'precision', numberFormat);





%---------------------------------------------
function [dataColNames, data] = getDataFromWS(workspaceName,fColNames, varNames,colAssignHash)

useColHash = false;
if exist('colAssignHash')
   useColHash = true;
end

dataColNames = {};
data =[];
%for now assume no col hash
for ii = 1: numel(varNames)
   %find each of those varNames in the base workspace
   if useColHash
      cMatch  = find(strcmp(colAssignHash(:,1), fColNames{ii} ));
      if ~isempty(cMatch)
         varNameCur = colAssignHash{cMatch,2};
      else
         varNameCur=[];
      end
   else
      varNameCur = varNames{ii};
   end

   if ~isempty(varNameCur)
      temp =[];
      evalString = ['if exist(''',varNameCur,''',''var'');assignin(''caller'',''temp'',',varNameCur,'); end'];
      evalin(workspaceName,evalString);
      %if found add the name to dataColNames and add the variable as a column in data
      if ~isempty(temp)
         dataColNames = {dataColNames{:},fColNames{ii}};
         data = [data,temp(:)];
      end
   end
end
%-------------------------------------------------
function varAssignment=assignVars(varNames,fs)
varAssignment={};
colNames = fs.colNames;
if isfield(fs,'xCol')&& any(strcmp(fs.xCol,colNames))
   matches = find(strcmp(fs.xCol,colNames));
   xVarName = varNames{matches(1)};
else
   xVarName = varNames{1};
end
varAssignment = {varAssignment{:},{'x',xVarName}};

if isfield(fs,'yCol')&& any(strcmp(fs.yCol,colNames))
   matches = find(strcmp(fs.yCol,colNames));
   yVarName = varNames{matches(1)};
else
   yVarName = varNames{2};
end
varAssignment = {varAssignment{:},{'y',yVarName}};

if isfield(fs,'zCol')&& any(strcmp(fs.zCol,colNames))
   matches = find(strcmp(fs.zCol,colNames));
   zVarName = varNames{matches(1)};
   varAssignment = {varAssignment{:},{'z',zVarName}};
end
if isfield(fs,'frameCol')&& any(strcmp(fs.frameCol,colNames))
   matches = find(strcmp(fs.frameCol,colNames));
   frameVarName = varNames{matches(1)};
   varAssignment = {varAssignment{:},{'frame',frameVarName}};
end
if isfield(fs,'idCol')&& any(strcmp(fs.frameCol,colNames))
   matches = find(strcmp(fs.idCol,colNames));
   frameVarName = varNames{matches(1)};
   varAssignment = {varAssignment{:},{'id',frameVarName}};
end

%-------------------------------------------------
function assignToWorkSpace(data,varNames,workspaceName)

if size(data,2)~=numel(varNames)
   error('Number of column names not equal to number of data columns');
else
   for ii = 1:numel(varNames)
      assignin(workspaceName,varNames{ii},data(:,ii));
   end
end
%---------------------------------------------
function [fs]= getAsciiFileSpec(fileSpec)
palmSieverPath = fileparts(which('palmsiever_setup'));
asciiPath = [palmSieverPath, filesep(),'fileIO',filesep(),'Ascii'];
fSpecPath = [asciiPath, filesep(),fileSpec];

run(fSpecPath);
if exist('fs','var')
   return;
else
   error('Variable ''fs'' does not exist in config file');
end
