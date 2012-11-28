% Main entry point
setappdata(0,'usediplib',false)
setappdata(0,'staticplugins',isdeployed)

t = linspace(0,2*pi,1000)';
X = sin(t)*1000;
Y = cos(t)*1000;

X = X+randn(1000,1)*20;
Y = Y+randn(1000,1)*20;
Z = randn(1000,1)*20;

pluginsDir = fullfile(fileparts(which('palmsiever_setup')),'plugins');

PALMsiever('X','Y')

