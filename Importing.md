PALMsiever supports a variety of different file formats out-of-the-box. They are all imported using the "File/Import" menu (see Fig. 1). If your format is not present, you can easily extend it (see [ExtendingPALMsiever](ExtendingPALMsiever.md)).

> <img src='https://palm-siever.googlecode.com/svn/wiki/images/ImportMenu.png'>
<b>Fig. 1. The import menu in PALMsiever shows all supported formats.</b></li></ul>

Table 1 shows a list of all currently supported file formats. Please refer to <a href='ExtendingPALMsiever.md'>Extending PALMsiever</a> to find out how to add support for additional file formats.<br>
<br>
<b>Table 1. The list of supported file formats</b>
<table><thead><th> <i>Software</i> </th><th> <i>Extension</i> </th><th> <i>Notes</i> </th></thead><tbody>
<tr><td> Generic text file </td><td> </td><td> can be used on most tabular data </td></tr>
<tr><td> Leica_GSD </td><td> ascii </td><td> reads the 2D version, can be extended, please contact me if you need it </td></tr>
<tr><td> Octane </td><td> txt </td><td> -- </td></tr>
<tr><td> PeakSelector </td><td> prm </td><td> reads in all data. Note it's better to export it in nanometers, as the text looses precision if you export it in pixel units. </td></tr>
<tr><td> QuickPALM </td><td> txt </td><td> Make sure the saved file type is .txt not .xls (or change the ending of the filename if necessary). Trying to import .xls causes MATLAB to freak out! </td></tr>
<tr><td> RapidSTORM </td><td> txt </td><td> everything except the metadata </td></tr>
<tr><td> UTrack_Julia </td><td> -- </td><td> -- </td></tr>
<tr><td> Vutara </td><td> csv </td><td> reads all 3D data  </td></tr>