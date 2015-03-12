There are different ways you can extend the functionality of PALMsiever.

  * You can create a plugin
  * You can add support for an additional file format
  * You can add another rendering algorithm

## Plugin ##

A plugin can be a small script or a function that can be accessed from the Plugin menu and is automatically added at the start of PALMsiever, or when the "Refresh" menu item is selected.

A simple function is:

```
function myFirstPlugin(handles)

logger("Hello World!");
```

this simple function simply uses the log window to display the message "Hello World!".

The `handles` variable is passed to the function and is used to access all the elements of the user interface. Rather than modify or read the GUI fields directly, it is good practice to use a function from the library. For example, you can read the current `Sigma` by using the function `getSigma(handles)`. This way, your application is better protected against future GUI modifications.

You can do basically anything in a plugin, so take care.

## Additional File Format ##

You can add support for an additional file format by adding a file specification to the `fileIO` subdirectory of your PALMsiever installation.

A typical file specification looks like this (this is the Leica\_GSD format):

```
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
```

The definition for the various fields is the following:

| fileType | `'ascii'` indicates the file format is ascii-based. |
|:---------|:----------------------------------------------------|
| nHeaderLines | specifies how many rows it needs to skip at the beginning of the file before getting to the data |
| delimiter | this indicates what character delimits each consecutive field. |
| headerPrefix | specifies a special character that precedes the header. |
| headerPostfix | specifies a special character that follows the header. |
| colNames | this is a cell array of strings specifying the names of each column of the file |
| numberFormat | specifies how to read the numbers |

In addition, you can specify how to assign the `X`, `Y`, `Z` and `frame` variables to the corresponding columns in your data.

## Add another rendering algorithm ##

At the moment, the procedure is not the most user-friendly one. In the future, we plan to make it simpler. If you feel adventurous enough, you can try the following:

  1. Add an item to the drop-down menu, note down it's position (e.g. 5 for the 5th element)
  1. Add the specified handling mechanism to the `PALMsiever.m` file, in the `renderHelper` function, as an additional item of the `case`.

If you need assistance, don't hesitate to write to the [forum](https://groups.google.com/forum/#!forum/palm-siever-development).
