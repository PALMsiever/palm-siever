% Fetch variables from the workspace by name
%
%  varargin : list of variables to read
%
%  varargout : the requested variables
function varargout = fetch(varargin)

for i=1:nargin
    varargout{i} = evalin('base',varargin{i});
end

