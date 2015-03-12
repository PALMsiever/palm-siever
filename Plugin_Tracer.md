# Introduction #

Tracer allows the user to create a trace along a structure in an image. It uses the underlying molecule positions, not the rendered image.

![https://palm-siever.googlecode.com/svn/wiki/images/Tracer_v1.0.png](https://palm-siever.googlecode.com/svn/wiki/images/Tracer_v1.0.png)

**The Tracer GUI.**

# Walktrough #

The protocol for tracing a filamentous structure is as follows:

  1. Choose a **Radius** and a **Step** size. Radius should roughly be twice the radius of the structure. Step should be roughly twice the Radius parameter. You might need to adjust them to your data.
  1. Press '**Trace!**'.
  1. Select a **first point** where to start the trace.
  1. Select a **second point**, roughly along the direction of the structure you want to trace.
  1. **Done**! The software will trace your structure, show the trace on the current rendering as a green line, and save it to the workspace as variable 'Trace'.

<img width='50%' src='https://palm-siever.googlecode.com/svn/wiki/images/Tracer_v1.0_trace.png'>

<b>Tracing the default example data using the default parameters.</b>

<h1>Additional Features</h1>

<ul><li>Generate <b>cumulative histograms</b> along the trace<br>
</li><li><b>Load</b> and <b>save</b> traces<br>
</li><li>Fit the histogram to a <b>single</b> or <b>double Gaussian</b> function</li></ul>

<img width='50%' src='https://palm-siever.googlecode.com/svn/wiki/images/Tracer_v1.0_trace_hist.png'>

<b>An example of fiting a single Gaussian function to the cumulative histogram.</b>

<pre><code>     General model:<br>
     fit(x) = a1*exp(-(x-b1).^2 / 2 /c1.^2 )<br>
     Coefficients (with 95% confidence bounds):<br>
       a1 =       79.23  (76.53, 81.93)<br>
       b1 =       1.582  (0.8155, 2.348)<br>
       c1 =       19.46  (18.69, 20.23)<br>
<br>
</code></pre>

<b>The results from the fitting are output to the command line.</b>

<h1>Algorithm</h1>

The tracing algorithm is given an initial position P0 (red cross) a direction dP, a search radius r and a step size s.<br>
<br>
<img src='https://palm-siever.googlecode.com/svn/wiki/images/Tracing%20algorithm.png' />

<ol><li>It first searches around the initial position for all points within the search radius (blue points);<br>
</li><li>then, it calculates their orientation by calculating the principal components of the covariance matrix (green ellipse).<br>
</li><li>It then sets the geometrical mean of the point cloud as the first point in the trace (green point) and moves along the strongest component (green arrow) for a distance s.<br>
</li><li>It repeats this process with unvisited points until there are not enough points along the trace (less than 20).</li></ol>
