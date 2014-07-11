% Get file size.
function siz = fsize(filename)
% Get file size.
%
%   siz = fsize(filename)
% 
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012

fd = fopen(filename,'r');
fseek(fd,0,'eof');
siz = ftell(fd);
fclose(fd);
