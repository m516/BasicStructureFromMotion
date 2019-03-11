class TrackablePoint2 { //<>// //<>// //<>//
  public static final int SMALL_SEARCH_RADIUS = 8;
  public static final int LARGE_SEARCH_RADIUS = 8;
  public static final float SIMILARITY_THRESHOLD = 0.8;

  int iterations = 0; //Count of the number of views found
  //This tracker begins tracking pixels in a different image
  //by starting at the same pixel position in the previous
  //image, e.g. if a trackable point was found at (3,2) in
  //image 1, it will begin to look for that pixel in image 2
  //in the position (3,2).
  //After the number of iterations specified by ITERATIONS_TO_FINE_TUNE,
  //the tracking mechanism begins searching for pixels by
  //estimating where they would be in the new image, e.g.
  //if a trackable point was found at (3,2) in image 1, it may or 
  //may not begin to look for that pixel in image 2 in the 
  //position (3,2). This shouldn't be a low number like 2 because
  //it may take some time for the location in 3D space to be where
  //it should be. However, this can be changed with the SENSITIVITY.
  public static final int ITERATIONS_TO_FINE_TUNE = 2;

  //Adjusts how sensitive this tracker is to tracked points.
  //Expected values are between 0 and 1, though exception handling
  //may not be provided and it's not a good idea to use either extremity
  //for the sensitivity value: to get the location of the point
  //in 3D space, it mixes the previously estimated position with the
  //current one, with more weight on the previous one when the sensitivity
  //is closer to 0 and more weight on the current one when the sensitivity
  //is closer to 1
  public static final float SENSITIVITY = 0.8;
  
  //For each update() call, the accuracy field is updated. To find points
  //that can't converge to one place, the update() method will calculate
  //the distance between the new location found and the original one. 
  //TrackablePoints will die if their current accuracy values are greater
  //than the original ones multiplied by this PRESISION value
  public static final float PRECISION = 0.9;

  //True if this trackable point can still track its object in images
  boolean isLive = true; 

  //The amount of error found while estimating where the point in 3D space is
  float accuracy = Float.POSITIVE_INFINITY;

  //List of locations where the tracked object could be found
  Location[] locations = new Location[3];

  PVector position = new PVector();

  /**
   * Does the bookkeeping for this trackable point. 
   * 
   * This method: 
   *   1) finds where this point is in the image provided in the new view.
   *   2) updates an internal list of views.
   *   3) approximates the location in 3D space of this coordinate
   * 
   * 
   **/
  boolean update(View newView) {
    if (newView==null) throw new IllegalArgumentException();

    if (!isLive) return false;

    //If no view exists
    if (locations[0]==null) {
      //Create a new location
      //Create a new one in the center of the screen
      Location newLocation = new Location(newView, newView.image.width/2, newView.image.height/2);
      //Make a guess on where the position is. This likely won't
      //be a good one because at this point in the code there 
      //is only one view to work with. It might just be a good idea
      //to guess that the point is five or so units away from the view
      newLocation.updateLine();
      position = newView.projectImageToPoint(newLocation.imageX, newLocation.imageY, null);

      //Add this new Location to the front of the list of Locations
      locations[0]=newLocation;


      //Increment the iteration count
      iterations++;
    } else if (locations[0].view!=newView && !locations[0].view.isSimilarTo(newView, 0.1)) {//If this view is different from the previous one
      //Push back the stack of views to make room for this one
      for (int i = 0; i < locations.length-1 && locations[i]!=null; i++) {
        locations[i+1]=locations[i];
      }//End for
      //Get the new screen coordinates
      PVector newImageCoordinates = match(locations[1].view.image, locations[1].imageX, locations[1].imageY, newView.image, locations[1].imageX, locations[1].imageY);
      if (newImageCoordinates==null) {
        isLive=false;
        return false;
      }
      //TODO estimate point when fine-tuning

      //Create a new Location
      Location newLocation = new Location(newView, int(newImageCoordinates.x), int(newImageCoordinates.y));
      //Make a guess on where the position is. This likely won't
      //be a good one because at this point in the code there 
      //is only one view to work with. It might just be a good idea
      //to guess that the point is five or so units away from the view
      newLocation.updateLine();

      //Add this new Location to the front of the list of Locations
      locations[0]=newLocation;

      //Points on the edges of surfaces against a plain background
      //tend to "ride" the edge, i.e. they track the edges rather 
      //than the actual features on those edges. One way to negate
      //this is by checking how far the point has moved since the last
      //time it was computed. If this tracking point is riding an edge,
      //the calculated location in 3D space will change dramatically more
      //than if it doesn't.
      PVector newPosition = locations[0].estimatePosition(locations[1]);
      float newAccuracy = position.dist(newPosition);
      if (newAccuracy>accuracy*PRECISION) {
        if(debugStatus==1) println("Failed");
        isLive = false;
        return false;
      }
      if(debugStatus==1) println(newAccuracy);
      accuracy = newAccuracy;
      position = newPosition;

      //Increment the iteration count
      iterations++;
    }//End if
    //If this is an old view
    else {
      //Update its coordinates and re-evaluate if possible
      locations[0].updateLine();
      //If there's only one view
      if (locations[1]==null) {
        position = newView.projectImageToPoint(locations[0].imageX, locations[0].imageY, null);
      }
      //If multiple views
      else {
        position=locations[0].estimatePosition(locations[1]);
      }
    }

    return true;
  }

  void trackAt(int x, int y) {
    if (locations[0]==null) {
      throw new IllegalStateException("Can't track this point without a location first. Please call my update() method with the current view and then I'll start tracking.");
    }
    locations[0].imageX = x;
    locations[0].imageY = y;

    position = locations[0].view.projectImageToPoint(locations[0].imageX, locations[0].imageY, null);

    if (!isLive) revive();
  }

  //Brings this tracker back to life by resetting necessary fields
  void revive() {
    for (int i = 0; i < locations.length; i++) locations[i]=null;
    isLive=true;
    accuracy=Float.POSITIVE_INFINITY;
    iterations=0;
  }

  PVector match(PImage img1, int pixelX, int pixelY, PImage img2, int guessX, int guessY) {
    int newX = 0, newY = 0;

    float similarity = 0.0, maxSimilarity = SIMILARITY_THRESHOLD;
    boolean found = false;

    for (int r = 1; r < LARGE_SEARCH_RADIUS; r++) {
      for (int i = 0; i < 2*r; i++) {
        similarity=getSimilarity(img1, pixelX, pixelY, img2, guessX-r+i, guessY-r, SMALL_SEARCH_RADIUS)-0.01*float(r)/SMALL_SEARCH_RADIUS;
        if (similarity>maxSimilarity) {
          found=true;
          maxSimilarity = similarity;
          newX=guessX-r+i;
          newY=guessY-r;
        }
        similarity=getSimilarity(img1, pixelX, pixelY, img2, guessX+r, guessY-r+i, SMALL_SEARCH_RADIUS)-0.01*float(r)/SMALL_SEARCH_RADIUS;
        if (similarity>maxSimilarity) {
          maxSimilarity = similarity;
          found=true;
          newX=guessX+r;
          newY=guessY-r+i;
        }
        similarity=getSimilarity(img1, pixelX, pixelY, img2, guessX+r-i, guessY+r, SMALL_SEARCH_RADIUS)-0.01*float(r)/SMALL_SEARCH_RADIUS;
        if (similarity>maxSimilarity) {
          maxSimilarity = similarity;
          found=true;
          newX=guessX+r-i;
          newY=guessY+r;
        }
        similarity=getSimilarity(img1, pixelX, pixelY, img2, guessX-r, guessY+r-i, SMALL_SEARCH_RADIUS)-0.01*float(r)/SMALL_SEARCH_RADIUS;
        if (similarity>maxSimilarity) {
          maxSimilarity = similarity;
          found=true;
          newX=guessX-r;
          newY=guessY+r-i;
        }
      }
    }

    if (found) {
      return new PVector(newX, newY);
    } else return null; //Search failed
  }

  //Locations are views that contain the point (2D image coordinates) that is
  //tracked by this TrackablePoint. They can cast rays (Line objects) that can
  //be used to estimate the location (3D world coordinates) of the line.
  class Location {

    View view; //The view containing the point
    int imageX, imageY; //Coordinate of the point in the view
    Line line;

    Location(View view, int imageX, int imageY) {
      this.view = view;
      this.imageX = imageX;
      this.imageY = imageY;
      updateLine();
    }

    private void updateLine() {
      if (line==null) {
        line = new Line();
      }
      line.position=view.position.copy();
      line.direction=new PVector(0, 0, -1);
      //Set the vector's x and y values so that the point appears to be in
      // the same place as "imageCoordinates" when projected onto the image
      line.direction.x=-(imageX-view.image.width/2.0)/2.0/view.image.width*line.direction.z/QUARTER_PI*angleOfView;
      line.direction.y=(imageY-view.image.width/2.0)/2.0/view.image.height*line.direction.z/QUARTER_PI*angleOfView;

      //Apply the camera transformations
      //Rotate around the camera
      rotateX(line.direction, view.rotation.x);
      rotateY(line.direction, view.rotation.y);
      rotateZ(line.direction, view.rotation.z);

      line.direction.setMag(1);
    }

    PVector estimatePosition(Location stereoView) {
      return line.pointClosestTo(stereoView.line);
      //return line.approximateIntersection(stereoView.line);
    }
  }
}
