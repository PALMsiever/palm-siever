% Fetch variables from the workspace by name
function varargout = fetch(varargin)
% Fetch variables from the workspace by name
%
%  varargin : list of variables to read
%
%  varargout : the requested variables

for i=1:nargin
    varargout{i} = evalin('base',varargin{i});
end

