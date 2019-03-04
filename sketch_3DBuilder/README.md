## Controls:

* Mouse click: Sets a manual point that can be visualized as a colored dot on the display:
  * Teal Dot: This point has been found on the display and is used for calculating the true 3D position of the point
  * Red Dot: This point cannot be found accurately anymore, so its position is being estimated with the 3D coordinates that this program found
* Space: Advance to the next image, loading it if necessary

## Simulations:

Simulations are each stored in a folder containing the images and a single "positions" file where the position
of the camera in each image is stored as a CSV, such that the first three rows are the camera's position and 
the last three rows are its direction.

The number of images in each simulation is 100 (though this may change with the creation of a configuration file).

The current simulation (the only one so far) is "sim1"