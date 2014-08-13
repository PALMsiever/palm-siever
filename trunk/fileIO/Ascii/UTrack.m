%;//File specification for QuickPALM
fs.fileType = 'txt';
fs.nHeaderLines = 1 ;
fs.delimiter = ',';
fs.headerPrefix = ''; 
fs.headerPostfix= ''; 
fs.colNames={'x',
   'y',
   't',
   'id',
   'd1',
   'd2'};
fs.numberFormat='%g';
%[OptionalColumnAssignments]
fs.xCol='x';
fs.yCol='y';
fs.frameCol='t';
fs.idCol='id';

