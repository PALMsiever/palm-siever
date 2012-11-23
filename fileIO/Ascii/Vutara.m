%;//File specification for Vutara
fs.fileType = 'csv';
fs.nHeaderLines = 1 ;
fs.delimiter = ',';
fs.headerPrefix = ''; 
fs.headerPostfix= ''; 
fs.colNames={'image-ID',
	'cycle',
	'z-step',
	'frame',
	'particle-ID',
	'accum',
	'probe',
	'photon-count',
	'photon-count11',
	'photon-count12',
	'photon-count21',
	'photon-count22',
	'psfx',
	'psfy',
	'psfz',
	'psf-photon-count',
	'x',
	'y',
	'z',
	'amp',
	'background11',
	'background12',
	'background21',
	'background22',
	'chisq',
	'valid'};

fs.numberFormat='%g';
%[OptionalColumnAssignments]
fs.xCol='x';
fs.yCol='y';
fs.zCol='z';
fs.frameCol='frame';

