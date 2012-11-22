function [varargout ]= RapidStorm(ioMode,varargin)
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

FILETYPE = 'txt';


switch ioMode
case 'ReturnVarNames'
   [varNamesCell] = getVarNames();
   varargout = {varNamesCell};
case 'ReturnColNames'
   [varNamesCell,semanticCell] = getVarNames();
   varargout = {semanticCell};
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

semanticCell={...
'x',
'y',
'frame',
'chi2'
};

varNamesCell = semanticCell;

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
   data = importdata(filename);
   varNames =  getVarNames();
   assignToWorkSpace(data,varNames,workspaceName);
   varAssignment=assignVars();
end
%-------------------------------------------------
function varAssignment=assignVars()

varAssignment={{'x','x'},
               {'y','y'},
               {'frame','frame'}};

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
   [data] = getDataFromWS(workspaceName);
   writeOctane(filename,data);
end
%---------------------------------------------
function [data] = getDataFromWS(workspaceName)

varNames = getVarNames();
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

if ~all(strcmp(varNames(:),dataColNames(:)))
   error('Octane output format requires all 4 default colums to be present');
end

%------------------------------------------------
%---------------------------------------------
function writeOctane(filename,data);
fid = fopen(filename,'w');
dlmwrite(filename, data,'-append','delimiter',',');

