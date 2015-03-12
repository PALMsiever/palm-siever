PALMsiever has been designed with the idea of putting the data in the foreground and let you explore it in the easiest possible way.

This quick tour assumes you have installed PALMsiever. If not, please refer to the [Installation Guide](InstallationGuide.md) or follow the steps in the video.

The two videos below show you how to install and use PALMsiever:

<a href='http://www.youtube.com/watch?feature=player_embedded&v=IA-MEjS4Gp0' target='_blank'><img src='http://img.youtube.com/vi/IA-MEjS4Gp0/0.jpg' width='425' height=344 /></a>

<a href='http://www.youtube.com/watch?feature=player_embedded&v=0TLuuV6Z0ac' target='_blank'><img src='http://img.youtube.com/vi/0TLuuV6Z0ac/0.jpg' width='425' height=344 /></a>

PALMsiever has been designed specifically for single-molecule localization microscopy data, but can be used to analyze other spatial data too. For an introduction to single-molecule localization microscopy, refer to any good introductory material (e.g. ref. 1).

This data usually comes in the form of a table or list of localizations, stored in a text file (e.g. a CSV file). This can be generated from the single-molecule localization microscopy video sequence using other software packages such as RapidSTORM, QuickPALM, or many other. A list of available software packages has been redacted for the ISBI localization microscopy challenge in 2013 and is still growing [here](http://bigwww.epfl.ch/smlm/software/index.html).

You can import the tabular data using PALMsiever quite easily, through the FIle/Import menu items. If the software you used is supported directly, it will conveniently recognize, if present, a few standard columns corresponding to the X, Y, Z, Frame number for example. Otherwise, you can use the "Generic" menu item and then correct the columns. See the [Importing](Importing.md) document for more information on importing.

1- GH Patterson, M Davidson, S Manley, HF Hess and J Lippincott-Schwartz, “Superresolution imaging using single-molecule localization,” Annu Rev Phys Chem 61:345-367 (2010)


**Exercise 1: Import an example dataset.**
  1. Download the Tubulin example dataset from [here](https://palm-siever.googlecode.com/svn/example_data/Tubulin-Alexa647%20with%20fiducials.RapidStorm.txt).
  1. Open PALMsiever
  1. Go to "File/Import/RapidSTORM" and select the file you just downloaded.
  1. After a few seconds, an image is going to appear on the screen of the dataset.

Congratulations! You have just imported a dataset into PALMsiever. Most of the time, the data coming from the localization software is unclean: it contains many spurious or false localizations resulting from photon noise, localizations from planes outside the plane of focus or badly fitted localizations. These need to be discarded, or sieved out, in order to generate meaningful images. PALMsiever is especially designed for this.

The interface is divided into two parts: the viewport and the siever. The viewport is where your data is rendered (i.e. transformed into a density map of all the localizations), while the siever is where you can select what portion of the data is displayed.

![https://palm-siever.googlecode.com/svn/wiki/images/PALMsiever_Layout.png](https://palm-siever.googlecode.com/svn/wiki/images/PALMsiever_Layout.png)

### The viewport ###

The viewport provides a view on your current data. It renders the current subset of your data according to the limits specified on the sieving part.

There are a few fundamental controls:

  * the variable selection drop-down lists allow you to select what variable is used for X, Y, Z, frame and ID.
  * the resolution drop-down (256x256 by default) selects the image size
  * the rendering drop-down list selects which rendering algorithm to use
  * the Min, Max and Gamma decide what are the minimum and maximum densities to display, while the gamma box changes the linearity between the density and the color scale

For more information you can have a look at the [GUI reference](GUIreference.md).

### The siever ###

![https://palm-siever.googlecode.com/svn/wiki/images/SieverTable.png](https://palm-siever.googlecode.com/svn/wiki/images/SieverTable.png)

This part of the interface allows you to select what subset of the data to display. The main table provides a list of all the variables (columns) of your dataset and the limits for each one. It also displays some basic statistic on the variables.

Upon selecting a variable (by selecting the corresponding 'min' or 'max' column), a histogram appears below which shows the histogram of the selected variable. This allows to better decide the appropriate population, selected by directly changing the 'min' or the 'max' values in the table.

You can also decide to discard the upper and lower 5% of your data by using the 'Exclude u/l 5%' button. The effect is to modify the 'min' and 'max' for the selected variable, calculating the upper and lower 5% thresholds, also shown to the right, under 'q05' and 'q95'.

Once the limits are modified, the statistics are not updated until the button 'Update stats' is pressed.

**Exercise 2: Sieving.**
  1. Open the data from Example 1.
  1. On the siever side there is a table with a list of all the columns in the data you just loaded. Click on the 'Max' column of the 'chi2' row.
  1. See how the histogram window (below the table) indicates a histogram of the selected variable 'chi2'.
  1. Try modifying the value in that cell and press 'Enter' on the keyboard. See the effect on the data.
  1. Once you're satisfied with the set of localizations, choose 'Points/Sieve (no XYZ)!' to discard all points not within the limits you have specified in the table.

### Grouping ###

An important step in localization microscopy data anaysis is what is commonly referred to as 'grouping'. The photophysics of the fluorophore during the strong excitation causes it to 'blink' and thus appear as a bright spot in multiple successive frames. To correctly count the number of fluorophores, these multiple appearances need to be _grouped_ together.

Using PALMsiever, this can be easily done using the 'Points/Group' menu. For additional information, see the [Grouping](Grouping.md) wiki page.

**Excersise 3: Grouping**
  1. Open data from Example 1.
  1. Select the 'Points' menu and the 'Group' menu item.
  1. Put 0 as the first parameter and 50 in the second, then  'OK'. Now, grouping will start. You can monitor the progress in the log window that appears.
  1. After grouping, each localization will be assigned a sequential number identifying to which group it belongs. Tick the 'Grouped' check box in the lower part of the screen.

![https://palm-siever.googlecode.com/svn/wiki/images/GroupedCheckBox.png](https://palm-siever.googlecode.com/svn/wiki/images/GroupedCheckBox.png)

The viewport will now show a rendering of only the grouped localizations.

### The plugins ###

A great deal of extended functionality is included in the form of [plugins](Plugins.md), located in the menu bar. These allow several common tasks to be performed such as [drift correction](Plugin_DriftCorrectionFiducial.md) and [clustering](Plugin_DbscanClustering.md). You can also add additional functionality to PALMsiever by [writing new plugins](ExtendingPALMsiever.md).


## A few key concepts ##

|_The rendered image is of a constant size_|
|:-----------------------------------------|

That means that if your image is 256x256, when you zoom in using the '+' button, it'll still have 256x256, but each pixel will represent only a fraction of the area of the original pixel. You can check the size of the pixel in data units by reading the label at the top of the screen, next to the resolution drop-down list.

|_You keep the entire dataset until you decide to discard_|
|:--------------------------------------------------------|

You can filter using the siever (see below) and the corresponding fraction will be shown. The original data is still there, until you remove it with the menu 'Point/Sieve!'. Only after using the sieve menu item you effectively discard all points that have not been selected.

|_(advanced) PALMsiever works on the variables in the workspace_|
|:--------------------------------------------------------------|

You don't need to be a MATLAB expert, but if you know MATLAB, you can benefit from that idea. In other words, you can modify the variables in the workspace and you will see (after a Redraw) the effect in the viewport. You can also call PALMsiever with two arguments, specifying the names of the two variables in the workspace that correspond you the X (horizontal coordinate) and the Y (vertical coordinate). You can even add a new variable as a combination of the previous ones, and after the Refresh variables you will see it in the list.