%;//File specification for Leica GSD
fs.fileType = 'ascii';
fs.nHeaderLines = 1 ;
fs.delimiter = ',';
fs.headerPrefix = ''; 
fs.headerPostfix= ''; 
fs.colNames={'stackID',
	'frameID',
	'eventID',
	'x0',
	'y0',
	'photon_count',
	'z0',
	'type',
	'n_raw'};

fs.numberFormat='%g';
%[OptionalColumnAssignments]
fs.xCol='x0';
fs.yCol='y0';
fs.zCol='z0';
fs.frameCol='frame';

