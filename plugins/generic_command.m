% Opens a mini-prompt to perform a generic MATLAB command
function generic_command(handles)

txt=inputdlg;

evalin('base',txt{1});

