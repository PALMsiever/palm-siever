fileSpec='QuickPALM.m';
fname ='C:\Users\Holden.LEBPC15\Documents\data\121107PalmSieverTestData\QuickPALM.txt';
fname2 ='C:\Users\Holden.LEBPC15\Documents\data\121107PalmSieverTestData\QuickPALMOut.txt';

%varNames = fileIoAscii(fileSpec,'ReturnVarNames');
%fileIoAscii(fileSpec,'Import','Filename',fname);
%fileIoAscii(fileSpec,'Export','Filename',fname2);
%fileIoAscii(fileSpec,'Export','Filename',fname,'ColAssingment',colAssignHash);

%fSpec2 = 'RapidStorm.m';
%fname3= 'C:\Users\Holden.LEBPC15\Documents\data\121107PalmSieverTestData\RapidStorm txt output .txt';
%fileIoOther(fSpec2,'ReturnVarNames')
%varAssign = fileIoOther(fSpec2,'Import','Filename',fname3)
%
%fSpec2 = 'Octane.m';
%fname3= 'C:\Users\Holden.LEBPC15\Documents\data\121107PalmSieverTestData\Octane txt output Particles Table.txt';
%fname4= 'octaneTestExport.txt';
%fileIoOther(fSpec2,'ReturnVarNames')
%varAssign = fileIoOther(fSpec2,'Import','Filename',fname3);
%fileIoOther(fSpec2,'Export','Filename',fname4);
%
%fSpec2 = 'PeakSelector.m';
%fname3= '4_GPF.prm';
%fname4= 'prmtestExport.prm';
%fileIoAscii(fSpec2,'ReturnVarNames')
%varAssign = fileIoAscii(fSpec2,'Import','Filename',fname3);
%fileIoAscii(fSpec2,'Export','Filename',fname4);
%

fSpec2 = 'Vutara.m';
fname3= 'particles.csv';
fname4= 'particlesTestExport.csv';
fileIoAscii(fSpec2,'ReturnVarNames')
varAssign = fileIoAscii(fSpec2,'Import','Filename',fname3);
fileIoAscii(fSpec2,'Export','Filename',fname4);
