fileSpec='QuickPALM.m';
fname ='C:\Users\Holden.LEBPC15\Documents\data\121107PalmSieverTestData\QuickPALM.txt';
fname2 ='C:\Users\Holden.LEBPC15\Documents\data\121107PalmSieverTestData\QuickPALMOut.txt';

%varNames = fileIoAscii(fileSpec,'ReturnVarNames');
%fileIoAscii(fileSpec,'Import','Filename',fname);
%fileIoAscii(fileSpec,'Export','Filename',fname2);
%fileIoAscii(fileSpec,'Export','Filename',fname,'ColAssingment',colAssignHash);

fSpec2 = 'RapidStorm.m';
fname3= 'C:\Users\Holden.LEBPC15\Documents\data\121107PalmSieverTestData\RapidStorm txt output .txt';
fileIoOther(fSpec2,'ReturnVarNames')
varAssign = fileIoOther(fSpec2,'Import','Filename',fname3)