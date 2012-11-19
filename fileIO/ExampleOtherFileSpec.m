function [varargout ]= ExampleOtherFileSpec(ioMode,varargin)
% function ExampleOtherFileSpec(ioMode,varargin)
% Reads in/out arbitrary PALM data
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

switch ioMode
case 'ReturnVarNames'
   [varNamesCell] = getVarNames();
   varargout = {varNamesCell};
case 'Import'
   [varAssignment] = import(varargin{:});
   varargout ={varAssignment};
case 'Export'
   export(varargin{:});
otherwise
   error('Unrecognised file IO mode');
end

%-----------------------------------------------
function [varNamesCell] = getVarNames()

%TODO : implement function logic
error('Function not implemented yet');
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
   %TODO : implement function logic
   error('Function not implemented yet');
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
      useColHash = true;
      colAssignHash= varargin{ii+1};
      ii = ii+2;
   end
end

if isempty(filename)
   error('File name not specified');
else
   %TODO : implement function logic
   error('Function not implemented yet');
end
