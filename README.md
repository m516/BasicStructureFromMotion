# BasicStructureFromMotion
Right now this repo just contains a sketch of an idea for a SFM algorithm; 
it doesn't actually reconstruct 3D objects yet, but that's the goal!

Right now, the program can find and track several points in a generated "video feed"
comprised of 100 3D renders of a solid, textured object. However, as it builds a point cloud,
it fails to distinguish good data from bad. Most notably, it "tracks" points in a solid 
background where all points look the same, and it assumes they are parts of the
object because they don't move (when really they do but are just replaced by identical points).


## Installation Instructions

Right now this program isn't quite at the point where it would make sense to make a binary release.
However, Processing makes it easy to download and run the source code:

1. Download [Processing](https://processing.org/) [here](https://processing.org/download/)
2. Clone this repository
3. Use Processing to open a source code (.pde) file in your local repostory. 
The rest of the files will be displayed on different tabs in the IDE.
4. Press ctr+R or the "run sketch" button in the top left corner
