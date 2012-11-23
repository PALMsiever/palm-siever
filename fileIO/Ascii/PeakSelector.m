%;//File specification for PeakSelector
fs.fileType = 'prm';
fs.nHeaderLines = 1 ;
fs.delimiter = '\t';
fs.headerPrefix = ''; 
fs.headerPostfix= ''; 
fs.colNames={'Offset',
	'Amplitude',
	'X Position',
	'Y Position',
	'X Peak Width',
	'Y Peak Width',
	'6 N Photons',
	'ChiSquared',
	'FitOK',
	'Frame Number',
	'Peak Index of Frame',
	'Peak Global Index',
	'12 X PkW * Y PkW',
	'Sigma Amplitude',
	'Sigma X Pos rtNph',
	'Sigma Y Pos rtNph',
	'Sigma X Pos Full',
	'Sigma Y Pos Full',
	'18 Grouped Index',
	'Group X Position',
	'Group Y Position',
	'Group Sigma X Pos',
	'Group Sigma Y Pos',
	'Group N Photons',
	'24 Group Size',
	'Frame Index in Grp',
	'Label Set',
	'Amplitude L1',
	'Amplitude L2',
	'Amplitude L3',
	'30 FitOK Labels',
	'Zeta0',
	'Sigma Amp L2',
	'Sigma Amp L3',
	'Z Position',
	'Sigma Z',
	'36 Coherence',
	'Group A1',
	'Group A2',
	'Group A3',
	'Group Z Position',
	'Group Sigma Z',
	'42 Group Coherence',
	'XY Ellipticity',
	'Unwrapped Z',
	'Unwrapped Z Error',
	'XY Group Ellipticity',
	'Unwrapped Group Z',
	'Unwrapped Group Z Error'};

fs.numberFormat=' %1.5E';

%[OptionalColumnAssignments]
fs.xCol='X Position';
fs.yCol='Y Position';
fs.zCol='Z Position';
fs.frameCol='Frame Number';

