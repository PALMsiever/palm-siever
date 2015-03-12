| **Filename** | **Output** | **Function name** | **Parameters** | **Description** |
|:-------------|:-----------|:------------------|:---------------|:----------------|
| add\_colorbar.m |  | add\_colorbar | handles  col | Add colorbar |
| add\_scalebar.m | mask  |  add\_scalebar | handles cbcol img | Adding a scalebar |
| autoIso.m | isoVal  |  autoIso | vol | Automatic calculation of iso-surface value for volumetric data using Otsu's method |
| calcFIRE.m |  FIRE se frcprofile frcprofile\_f |  calcFIRE | X  Y  res  minX  maxX  minY  maxY  nTrials | Calculate the FIRE value from the specified X and Y vectors. |
| calcFIREh.m |  frcprofile linx |  calcFIREh | handles  nTrials | Calculate the FIRE fetching the parameters from the GUI |
| calcFIRE\_1D.m |  FIRE se frcprofile frcprofile\_f F frcprofile\_est fSNR fSNR\_RE |  calcFIRE\_1D | X  res  minX  maxX  nTrials | Calculate a variation of the FIRE for 1-dimensional data |
| calcHistogram.m | density n m X  |  calcHistogram | handles | Calculate histogram |
| calcHistogram_.m_| density n m X  |  calcHistogram| XPosition  YPosition  res  minX  maxX  minY  maxY | Calculates the histogram from the two vectors, within the specified bounds and with 'res' number of bins. |
| dbscan.m | class typ | dbscan | x k Eps | Clustering the data with Density-Based Scan Algorithm with Noise (DBSCAN) |
| dg\_fit.m | fitresult  go |  dg\_fit | x  y  w0 | Performs a double-gaussian fit on the x and y vectors, with an optional initial estimation of the width w0. |
| double\_gaussian\_fit\_1D.m | mu sigma w gof fit |  double\_gaussian\_fit\_1D  | xs ys | Fits the data to a double Gaussian function |
| double\_gaussian\_fit\_1D\_plot.m | f | double\_gaussian\_fit\_1D\_plot | xs ys | Plots a gaussian fit for datapoints (xs,ys) in a new figure and returns the handle |
| fetch.m | varargout  |  fetch | varargin | Fetch variables from the workspace by name |
| freedmanDiaconis.m | nBins |  freedmanDiaconis | data | Calculates the Freedman-Diaconis choice for the bin width. 'data' is assumed to be a single column vector. |
| fsize.m | siz  |  fsize | filename | Get file size. |
| gammaAdjust.m | imG  |  gammaAdjust | im gammaVal | Calculates gamma-adjusted image |
| gaussian\_fit\_1D.m | mu sigma gof fit |  gaussian\_fit\_1D  | xs ys |  ---  |
| gaussian\_fit\_1D\_plot.m |  |  |  | Plots a gaussian fit for datapoints (xs,ys) in a new figure and returns |
| getBounds.m | minX  maxX  minY  max |  getBounds | handles |  ---  |
| getColHash.m | varargout  |  getColHash | varargin |  ---  |
| getColormapName.m | cmap  |  getColormapName | handles |  ---  |
| getDensity.m | density X  |  getDensity | handles |  ---  |
| getF.m | frame  |  getF | handles |  ---  |
| getFramebounds.m |  |  |  | [maxFrame](minFrame.md) = getFramebounds(handles) |
| getGamma.m | gamma  |  getGamma | handles | Get the current gamma |
| getID.m | frame  |  getID | handles |  ---  |
| getLength.m | L  |  getLength | handles | Get the current radius |
| getPalmSiever.m | h  |  getPalmSiever | handles |  ---  |
| getPeakPosCentroid.m | pos amplitud |  getPeakPosCentroid | im  posGuess  windowRadius |  ---  |
| getPeakPosGauss2d.m | pos amplitud |  getPeakPosGauss2d | im  zeroCoord   windowSize |  ---  |
| getRadius.m | R  |  getRadius | handles | Get the current radius |
| getRes.m |  |  |  | This function gets the chosen image size in the resolution box |
| getSelectedRendering.m | str  |  getSelectedRendering | handles |  ---  |
| getStormDrift3.m | drift corAmplitude |  getStormDrift3 | stormData minImPointPerArea minFrame stormPixSize SccfWindowArea imSize |  ---  |
| getSubset.m | subset  |  getSubset | handles |  ---  |
| getVariables.m | rows2 data  |  getVariables | handles N |  ---  |
| getX.m | X  |  getX | handles |  ---  |
| getY.m | Y  |  getY | handles |  ---  |
| getZ.m | Z  |  getZ | handles |  ---  |
| getZbounds.m | minZ max |  getZbounds | handles | Given the figure's handles, the function returns the minimum and maximum values for the Z variable. |
| get\_static\_plugins.m | plugins  |  get\_static\_plugin | function plugins = get\_static\_plugin | Returns a list of plugins which should be |
| groupBy.m | gX  |  groupBy | X  ID |  ---  |
| grouping.m |  | grouping | handles |  ---  |
| importprm.m |  |  |  |  importprm(filename,delim) |
| jdg\_fit.m | coeff scoeff fitresul |  jdg\_fit | x  y  amount  N |  ---  |
| jhist.m |  |  |  | Jittered histogram |
| kde2d.m | bandwidth density X  | kde2d | data n MIN\_XY MAX\_XY |  ---  |
| limit80.m |  | limit80 | handles  variable | Limits to central 80% of the data |
| logger.m |  |  |  | Logger function |
| matrix2html.m | str  |  matrix2html | M precision | Matrix to HTML table |
| nodiplib.m | ndl  |  nodiplib |  |  ---  |
| ppdiff.m | qq  |  ppdiff | pp j |  ---  |
| ppint.m | output  |  ppint | pp a b |  ---  |
| q05.m | q  |  q05 | x | q05 |
| q10.m | q  |  q10 | x | q10 |
| q90.m | q  |  q90 | x | q90 |
| q95.m | q  |  q95 | x | q95 |
| quantile.m | q  |  quantile | data quantiles | QUANTILE |
| quantization.m |  |  |  | Quantization of signal x between xmin and xmax in N segments, indexed |
| radialSpectrum.m |  PR PRx |  radialSpectrum | X1 Y1 pxSize imSize | Calculate radial spectrum |
| removeAxisDrift.m | xc  |  removeAxisDrift | x t xDrift tUn | ---------------------------------------------------- |
| render\_gauss.m | im  |  render\_gauss | pxSize  peaks  sigma  offsets  outSize  bounds |  ---  |
| render\_histogram.m | density X  |  render\_histogram | handles | Render a histogram of the current view |
| serialize.m | ohandles | serialize | handles filename |  ---  |
| setBounds.m |  |  |  | Sets the X,Y bounds |
| setFramebounds.m |  |  |  | Sets the Frame bounds |
| setMax.m |  | setMax | handles  variable  maximum | Set maximum for a specified variable |
| setMin.m |  | setMin | handles  variable  minimum | Set minimum for a specified variable |
| setPSVar.m |  | setPSVar | handles  varAssignment |  ---  |
| setX.m |  | setX | handles X |  ---  |
| setY.m |  | setY | handles Y |  ---  |
| setZ.m |  | setZ | handles Z |  ---  |
| setZbounds.m |  |  |  | Sets the Z bounds |
| sg\_fit.m |  |  |  | Single Gaussian fit |
| splinefit.m | pp  |  splinefit | varargin |  ---  |
| stringToVarName.m | varNames  |  stringToVarName | strings |  ---  |
| sumsqr.m |  |  |  | Elementwise sum of squares. |
| testImportAscii.m |  |  |  |  ---  |
| trace.m |  |  |  | Tracing algorithm |
| trace\_collect.m |  |  |  | Straighten and collect points along trace |
| trace\_histogram.m |  |  |  | Calculate the histogram along a trace |
| trace\_sigmas.m |  |  |  | Calculate sigmas along trace |

> Automatically generated (2014-07-11)