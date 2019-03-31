# BasicStructureFromMotion
Right now this repo just contains a sketch of an idea for a SFM algorithm; 
it doesn't actually reconstruct 3D objects yet, but that's the goal!


## Installation Instructions

Right now this program isn't quite at the point where it would make sense to make a binary release.
However, Processing makes it easy to download and run the source code:

1. Download [Processing](https://processing.org/) [here](https://processing.org/download/)
2. Clone this repository
3. Use Processing to open a source code (.pde) file in your local repostory. 
The rest of the files will be displayed on different tabs in the IDE.
4. Press ctr+R or the "run sketch" button in the top left corner


#Usage

## Simulations:

Simulations are each stored in a folder containing the images and a single "positions" file where the position
of the camera in each image is stored as a CSV, such that the first three rows are the camera's position and 
the last three rows are its direction.

The number of images in each simulation is 100 (though this may change with the creation of a configuration file).

The current simulation (the only one so far) is "sim1"

## Startup:
At the start of the program, a point cloud will automatically be generated from the simulation
and saved into data/pointCloud.ply. This is only for testing purposes and will likely change in
the future

## Display
On the screen is a view of a FeatureExtractor with all the features it has detected in that view.
Again, this is for testing purposes and will probably change.

## Controls:

* Mouse click: Advances the view to the next image in the simulated video
* Mouse position: the numbers on the sides of the image are values that are specific to the Harris corner 
detection algorithm. 
	* The red number is the value of the Harris corner function
	* The green numbers the x- and y- derivatives of the brightness of the image via the Sobel filter
	* The blue numbers are elements of the matrix used to estimate the Harris corner funtion

