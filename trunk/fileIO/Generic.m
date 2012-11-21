function [varargout ]= Generic(ioMode,varargin)
% function RapidStorm(ioMode,varargin)
% Parses a fileSpec ini file, and uses it to read in PALM data
%***************
% ioMode: 'ReturnVarNames','Import', 'Export'
%For import:
%  Input arguments:
%    'Filename',fileName, (optional) ('Workspace', workspaceName)
%      workspaceName: Default = 'base'
%  Output arguments:
%    Assigns all variables in to workspaceName
%     varAssignment - cell containing:
%     {'x',xColName,
%      'y',yColName,
%      'z',zColName, (optional)
%      'frame',frameColName, (optional)}
%For export:
%  Input arguments:
%     'Filename',fileName, (optional) ('Workspace', workspaceName), (optional), 'ColAssingment', colAssignHash
%      workspaceName: Default = 'base'
%      colAssignHash: 2xN cell array hash table, relating variable names expected by function, and actual variable names in workspace
%        ie {{colName1, colName2,colName3},{varName1,varName2,varName3}}
%  Output arguments: 
%    None
%Get file information:
%  Input arguments:
%     'ReturnVarNames'
%  Output:
%    varNamesCell
%  Returns the list of variable names for the 'standard' file contents according to the file specification

FILETYPE = '*';


switch ioMode
case 'ReturnVarNames'
case 'ReturnColNames'
   varargout = {{}};
case 'Import'
   [varAssignment] = import(varargin{:});
   varargout ={varAssignment};
case 'Export'
   export(varargin{:});
case 'FileType'
   varargout={FILETYPE};
otherwise
   error('Unrecognised file IO mode');
end

%-----------------------------------------------
function [varNamesCell,semanticCell] = getVarNames()

%Give the "Standard" semantic columns short variable names

semanticCell={};

varNamesCell = {};

%-----------------------------------------------
function varNames = parseVarNames(fileSemanticCell)

varNames = fileSemanticCell;
%get the standard var names
[varNamesStd,semanticStd] = getVarNames();
% replace any names that match with the standard var name
for ii = 1:numel(fileSemanticCell)
   cMatch = find(strcmp(fileSemanticCell{ii},semanticStd));
   if ~isempty(cMatch)
      varNames{ii} = varNamesStd{cMatch(1)};
   end
end

%then turn anything left over into an acceptable matlab variable name
varNames = stringToVarName(varNames);
%-----------------------------------------------
function [varAssignment] = import(varargin)
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
   [data colheader] = readFile(filename);
   varNames =  parseVarNames(colheader);
   assignToWorkSpace(data,varNames,workspaceName);
   varAssignment=assignVars(varNames);
end
%-------------------------------------------------
function varAssignment=assignVars(varNames)

varAssignment = {};
xVarName = varNames{1};
varAssignment = {varAssignment{:},{'x',xVarName}};
yVarName = varNames{2};
varAssignment = {varAssignment{:},{'y',yVarName}};

%-------------------------------------------------
%-------------------------------------------------
function assignToWorkSpace(data,varNames,workspaceName)

if size(data,2)~=numel(varNames)
   error('Number of column names not equal to number of data columns');
else
   for ii = 1:numel(varNames)
      assignin(workspaceName,varNames{ii},data(:,ii));
   end
end
%-----------------------------------------------
function export(varargin);

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
      useColAssign = true;
      varNames= varargin{ii+1};
      ii = ii+2;
   end
end

if isempty(filename)
   error('File name not specified');
else
   if ~useColAssign
      error('Must specify variables to be exported');
   else
      [dataColNames, data] = getDataFromWS(workspaceName, varNames);
      delimiter = '\t';
      writeGenericAscii(filename,dataColNames,data,delimiter)
   end
end
%---------------------------------------------
function [dataColNames, data] = getDataFromWS(workspaceName, varNames)

dataColNames = {};
data =[];
%for now assume no col hash
for ii = 1: numel(varNames)
      temp =[];
      evalString = ['if exist(''',varNames{ii},''',''var'');assignin(''caller'',''temp'',',varNames{ii},'); end'];
      evalin(workspaceName,evalString);
      %if found add the name to dataColNames and add the variable as a column in data
      if ~isempty(temp)
         dataColNames = {dataColNames{:},varNames{ii}};
         data = [data,temp(:)];
      end
end
%------------------------------------------------
%---------------------------------------------
function writeGenericAscii(filename,dataColNames,data,delimiter)
fid = fopen(filename,'w');
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
fclose(fid);
dlmwrite(filename, data,'-append','delimiter',delimiter);


%-----------------------------------------------------------
function [data colheader]= readFile(fname)

%import the localisations file
srFileStruct = importdata(fname);

if ~isstruct(srFileStruct)
   data=srFileStruct;
   colheader = makeUpHeader(size(data,2));
else
   data=srFileStruct.data;
   if isfield(srFileStruct,'colheaders')
      colheader = srFileStruct.colheaders;
   else
      colheader = makeUpHeader(size(data,2));
   end
end
%-----------------------------------------------------
function colheader = makeUpHeader(nCol);

colheader = cell(1,nCol);
for ii = 1:nCol
   colheader{ii} = num2str(ii);
end





