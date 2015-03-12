# Introduction #

This plugin uses image cross-correlation to correct sample drift, which does not require the presence of fiducial markers in the sample. Briefly, multiple super-resolved images are constructed for short time intervals (less than the total acquisition time), and each subsequent image is cross-correlated with the first image. The shift of the cross-correlation peak corresponds to the sample drift.

This method is described in detail in several publications, eg. Wang et al, Opt. Express 2014. In the nomenclature of Wang et al. this implementation essentially corresponds to "direct cross-correlation". (Side note: the redundant cross-correlation method presented in that paper looks very cool - but is not yet implemented in PALMsiever!).

One very minor innovation of the implementation presented here is that the time interval is not fixed - for each sub-image, it is constantly expanded until the minimum density of localizations per image is met. This is useful for the final frames of a dataset, where the number of localization per frame will usually drop.

NB: Cross-correlation based drift correction is generally less reliable than the fiducial approach, and works best for structures that contain lots of narrow lines (such as microtubules). In particular, I have found that for samples containing mainly sparse point-like structures (such as E. col RNA polymerase) the method often performs poorly.

# Details #

Let's drift correct some microtubules! Example dataset: "Tubulin-Alexa647 with fiducials.mat"

<img src='https://palm-siever.googlecode.com/svn/wiki/images/DriftCorrectionXCor_microtubulesExample.png' alt='Cross-correlation drift correction example data' />

Opening up the plugin we see the following dialogue:

<img src='https://palm-siever.googlecode.com/svn/wiki/images/DriftCorrectionXCor_screenshot.png' alt='Drift correction screenshot' />

To perform drift correction, you need to set the following parameters:
  * **Min Pts/ Area**: This is the minimum density of localizations required to form a sub-image. If there are not enough localizations, the cross-correlation amplitude will be very low, and it will not be possible to localize the peak. If this happens the drift graph will usually (but not always!) show lots of random spikes in measured drift. Generally **50 - 100 locs/ um<sup>2</sup>** works reasonable well. The units here are locs/ (unit area)<sup>2</sup> so depending on your data format you may need to convert this value to the appropriate distance units. Here, the data was analysed using RapidStorm, which outputs distance units of nm, so the right value is 50E-6 locs/ nm<sup>2</sup>.
  * **Min Frames**: Even if there are plenty of localizations per frame, it does not make sense to calculate too many sub-images compared with the timescale of the drift (normally slow). So set a minimum number of frames for each sub-image. As a rule of thumb, the minimum number of frames should correspond to about 5 s.
  * **Cross corr pixel size**: Pixel size of the super-resolved sub-image used for cross-correlation. Usually leave at 20 nm.
  * **XCor fit window sz**: Size of the fit window around the cross-correlation peak for a Gaussian fit to the peak to be performed. Usually leave at 100 (pixels).

If you leave "Show drift graph" ticked, and click "Correct drift", the data will be drift corrected and you should see the resulting drift graph:

<img src='https://palm-siever.googlecode.com/svn/wiki/images/DriftCorrectionXCor_DriftPlot.png' alt='Cross-correlation drift estimate' />


Notes:
  * For 3D data there is the option to correct Z drift using the same approach (2D cross-correlation). I have found this to be much more unreliable than X,Y correction (hence the "Experimental!" warning), and have mainly left it in for testing purposes.