%  importprm(filename,delim)
%
%  Fast import of comma-separated or tab-separated values files.
%  
%    filename      the file to be imported
%    delim         the delimiter character
%
%  This function needs a java class PRMUtils.class. You can provide the
%  location at the first call.
%
%  It generates a .raw binary file which is used if present (any successive
%  call). If it imports an empty file, try deleting the .raw file.
%  Importing the .raw file is much faster.
%
% This software is released under the GPL v3. It is provided AS-IS and no
% warranty is given.
%
% Author: Thomas Pengo, 2012
function Nr = importprm(filename,delim)

failed = false; ok = false;
while ~failed && ~ok
    try
        PrintStdErrMonitor()
        ok = true;
    catch 
        pathname = uigetdir('','Please specify where I can find PrintStdErrMonitor.class');
        if pathname
            javaaddpath(pathname)
        else
            failed = true;
        end
    end
end

if failed
    return
end

if nargin<2
    delim = '\t';
end

environment = 'base';

fd = fopen(filename);

% Read headers
H = textscan(fgetl(fd),'%s','Delimiter',delim); 
Nc = size(H{1},1);

s = ftell(fd);
lin = fgetl(fd);
fseek(fd,0,'eof');
S = ftell(fd)-s;
fseek(fd,s,'bof');

fclose(fd);

% Count lines
disp(['Importing approximately ' num2str(round(S/length(lin))) ' lines.'])
%FILE = fread(fd,S,'*char'); fclose(fd);
%Nr = sum(FILE==10);

% Convert 
fin = filename;
fout = [fin(1:end-3) 'raw'];
if ~exist(fout,'file')
    d=PRMutils.convertToFloat(fin,fout,PrintStdErrMonitor(),delim);
else
    Nr = fsize(fout)/Nc/4;
    d=Dimension(Nr,Nc);
end
M=eval(PRMutils.getMATLABcommand(fout,d));
Nr=size(M,1);

% Import the data
%M = textscan(FILE,repmat('%f32',1,Nc),'Delimiter','\t');

idno = 1;
% Assign vectors to base environment
 for c = 1:Nc; 
     name = H{1}{c};
     if isempty(name)
         name=['ID' num2str(idno)];
         idno=idno+1;
     else
         uname = upper(name);
         name( ~(uname>='A' & uname<='Z' | uname>='0' & uname<='9') )='_';
         if name(1)>='0' && name(1)<='9'
             name=['a' name];
         end
     end
     if name(1)=='_'
         name = ['var' name];
     end
     assignin(environment,name,M(:,c));
 end
 