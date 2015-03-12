Sometimes it is useful to discard isolated localization or localizations in low density regions. This plugin allows you to do just that.

It operates in the following way.

  1. Reads the most recently calculated density map (depends on the current rendering)
  1. Calculates the density of each localization using Nearest Neighbour
  1. Adds a new parameter for each localization containing the calculated density

After excecution, you can filter/sieve the points based on the additional density parameter.