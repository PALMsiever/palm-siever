function varargout = fileIoOther(fileSpec,ioMode, varargin)
% function fileIoAscii(fileSpec,varargin)
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
%      colAssignHash: Nx2 cell array hash table, relating variable names expected by function, and actual variable names in workspace
%  Output arguments: 
%    None
%Get file information:
%  Input argumements:
%    
%  Output:
%    varNamesCell

palmSieverPath = fileparts(which('palmsiever_setup'));
otherPath = [palmSieverPath, filesep(),'fileIO',filesep(),'Other'];
addpath(otherPath);
fSpecFunName = regexprep(fileSpec,'\.m$','');
[varargout{1:nargout}]= feval(fSpecFunName,ioMode,varargin{:});
