%;//File specification for rainSTORM v3.x
fs.fileType = 'csv';
fs.nHeaderLines = 1 ;
fs.delimiter = ',';
fs.headerPrefix = ''; 
fs.headerPostfix= ''; 
fs.colNames={'idx',
   'frame_idx',
   'x_coord',
   'y_coord',
   'x_std',
   'y_std',
   'I',
   'sig_x',
   'sig_y'};
fs.numberFormat='%g';
%[OptionalColumnAssignments]
fs.xCol='x_coord';
fs.yCol='y_coord';
fs.frameCol='frame_idx';
fs.idCol='idx';
