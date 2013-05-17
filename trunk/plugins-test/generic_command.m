% Generic command
function generic_command(handles)

txt=inputdlg;

evalin('base',txt{1});

