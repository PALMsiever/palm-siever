%;//File specification for PeakSelector
fs.fileType = 'prm';
fs.nHeaderLines = 1 ;
fs.delimiter = '\t';
fs.headerPrefix = ''; 
fs.headerPostfix= ''; 
fs.colNames={'Offset',
	'Amplitude',
	'X_Position',
	'Y_Position',
	'X_Peak_Width',
	'Y_Peak_Width',
	'6_N_Photons',
	'ChiSquared',
	'FitOK',
	'Frame_Number',
	'Peak_Index_of_Frame',
	'Peak_Global_Index',
	'12_X_PkW_*_Y_PkW',
	'Sigma_Amplitude',
	'Sigma_X_Pos_rtNph',
	'Sigma_Y_Pos_rtNph',
	'Sigma_X_Pos_Full',
	'Sigma_Y_Pos_Full',
	'18_Grouped_Index',
	'Group_X_Position',
	'Group_Y_Position',
	'Group_Sigma_X_Pos',
	'Group_Sigma_Y_Pos',
	'Group_N_Photons',
	'24_Group_Size',
	'Frame_Index_in_Grp',
	'Label_Set',
	'Amplitude_L1',
	'Amplitude_L2',
	'Amplitude_L3',
	'30_FitOK_Labels',
	'Zeta0',
	'Sigma_Amp_L2',
	'Sigma_Amp_L3',
	'Z_Position',
	'Sigma_Z',
	'36_Coherence',
	'Group_A1',
	'Group_A2',
	'Group_A3',
	'Group_Z_Position',
	'Group_Sigma_Z',
	'42_Group_Coherence',
	'XY_Ellipticity',
	'Unwrapped_Z',
	'Unwrapped_Z_Error',
	'XY_Group_Ellipticity',
	'Unwrapped_Group_Z',
	'Unwrapped_Group_Z_Error'};

fs.numberFormat=' %1.5E';

%[OptionalColumnAssignments]
fs.xCol='X_Position';
fs.yCol='Y_Position';
fs.zCol='Z_Position';
fs.frameCol='Frame_Number';

