# Introduction #

This plugin calculates and renders 3D iso-surface volumes for 3D PALM data. The iso-surface value is automatically calculated using [Outsu's method](http://en.wikipedia.org/wiki/Otsu%27s_method), and can also be manually adjusted.

# Details #

Test data: "example\_data/FtsZ-Dendra2 C crescentus live 3D 10 ms frame.mat"

The plugin calculates a 3D iso-surface for the entire area displayed in the current window. Usually it is best not to do this over the whole acquired field of view, since this is very slow (and generally not very useful). In this case we are going to zoom in on one Z-ring and render it in 3D.

Load the test data, and zoom in on the indicated area:

<img src='https://palm-siever.googlecode.com/svn/wiki/images/Render3Dvol_FtsZ_example_data_screenshot_withZoom.png' width='400px' />

to get something like this:

<img src='https://palm-siever.googlecode.com/svn/wiki/images/Render3D_vol_PS_Z-ring_zoom.png' width='150px' />

Open the 3D rendering plugin. You should see something like the following (the ring here has been rotated a little bit to show it off):

<img src='https://palm-siever.googlecode.com/svn/wiki/images/Render3D_vol_plugin_screenshot.png' width='400px' />

The [MATLAB camera toolbar](http://www.mathworks.ch/ch/help/matlab/visualize/view-control-with-the-camera-toolbar.html#f4-54139toolbar) at the top of the plugin allows rotation and zoom of the volume and manipulation of the lighting.

2D snapshots of the volume can be copied to the clipboard via the menu (Edit>Copy).

Adjustable parameters:
  * _Sigma XY_, _Sigma Z_: Set these to the XY and Z localization uncertainty, respectively.
  * _Voxel size XY_, _Voxel size Z_: This is the voxel (3D pixel) size in XY and Z, respectively (together they define a cuboid box). Usually a little bit less than the localization uncertainty works well, but for sparsely sampled data (ie few points in the dataset), a larger voxel size should be used.
  * _Iso-surface value_ (also via the slider): An initial (usually pretty good) iso-surface has been calculated via Otsu's method. Manually selected iso-surfaces can also be viewed by adjusting this parameter.