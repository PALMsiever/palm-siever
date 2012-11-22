%;//File specification for QuickPALM
fs.fileType = 'txt';
fs.nHeaderLines = 1 ;
fs.delimiter = '\t';
fs.headerPrefix = ''; 
fs.headerPostfix= ''; 
fs.colNames={' ',
   'Intensity',
   'X (px)',
   'Y (px)',  
   'X (nm)',  
   'Y (nm)',  
   'Z (nm)',  
   'Left-Width(px)'
   'Right-Width (px)'
   'Up-Height (px)'
   'Down-Height (px)', 
   'X Symmetry (%%)',   
   'Y Symmetry (%%)',
   'Width minus Height (px)',
   'Frame Number'};
fs.numberFormat='%g';
%[OptionalColumnAssignments]
fs.xCol='X (px)';
fs.yCol='Y (px)';
fs.zCol='Z (nm)';
fs.frameCol='Frame Number';

