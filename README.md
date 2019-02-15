# BasicStructureFromMotion
Right now this repo just contains a sketch of an idea for a SFM algorithm; 
it doesn't actually reconstruct 3D objects yet, but that's the goal!

It's getting close though: right now it does estimate where a single point is in 
3D space based on two or more images and the location/orientation of the camera.
In theory, if it did the same thing for thousands of points per image, then a point
cloud could be generated to make a 3D object.

## Installation Instructions

Right now this program isn't quite at the point where it would make sense to make a binary release.
However, Processing makes it easy to download and run the source code:

1. Download [Processing](https://processing.org/) [here](https://processing.org/download/)
2. Clone this repository
3. Use Processing to open a source code (.pde) file in your local repostory. 
The rest of the files will be displayed on different tabs in the IDE.
4. Press ctr+R or the "run sketch" button in the top left corner
