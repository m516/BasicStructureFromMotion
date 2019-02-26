class TrackablePoint2 { //<>// //<>// //<>//
  public static final int SMALL_SEARCH_RADIUS = 10;
  public static final int LARGE_SEARCH_RADIUS = 16;
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
  public static final float SENSITIVITY = 0.9;

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
      if (newAccuracy>accuracy) {
        println("Failed");
        isLive = false;
        return false;
      }
      println(newAccuracy);
      accuracy = newAccuracy;
      if(iterations>=ITERATIONS_TO_FINE_TUNE) position.lerp(newPosition, SENSITIVITY);
      else position=newPosition;

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
        position.lerp(locations[0].estimatePosition(locations[1]), SENSITIVITY);
      }
    }

    return true;
  }

  void trackAt(int x, int y) {
    if (locations[0]==null) {
      throw new IllegalStateException("No views with this trackable point have been found, so it's impossible to start tracking");
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



class TrackablePoint {
  public static final int SMALL_SEARCH_RADIUS = 10;
  public static final int LARGE_SEARCH_RADIUS = 16;
  public static final float SIMILARITY_THRESHOLD = 0.8;

  PVector position;

  View view;
  int imageX = 0, imageY = 0;

  View firstView;
  int imageX0 = 0, imageY0 = 0;

  void trackAt(int x, int y) {
    imageX = x;
    imageY = y;
  }

  boolean update(View newView) {
    if (newView==null) throw new NullPointerException();


    if (firstView==null) {
      firstView = newView;
      imageX0 = imageX;
      imageY0 = imageY;
    }


    if (view==null) {
      view = newView;
      position = view.projectImageToPoint(view.image.width/2, view.image.height/2, null);
    }
    boolean found = false;
    int newX = imageX, newY = imageY;

    float similarity = 0.0, maxSimilarity = SIMILARITY_THRESHOLD;

    for (int r = 1; r < LARGE_SEARCH_RADIUS; r++) {
      for (int i = 0; i < 2*r; i++) {
        similarity=getSimilarityTo(newView.image, imageX-r+i, imageY-r)-0.01*float(r)/SMALL_SEARCH_RADIUS;
        if (similarity>maxSimilarity) {
          found=true;
          maxSimilarity = similarity;
          newX=imageX-r+i;
          newY=imageY-r;
        }
        similarity=getSimilarityTo(newView.image, imageX+r, imageY-r+i);
        if (similarity>maxSimilarity) {
          maxSimilarity = similarity;
          found=true;
          newX=imageX+r;
          newY=imageY-r+i;
        }
        similarity=getSimilarityTo(newView.image, imageX+r-i, imageY+r);
        if (similarity>maxSimilarity) {
          maxSimilarity = similarity;
          found=true;
          newX=imageX+r-i;
          newY=imageY+r;
        }
        similarity=getSimilarityTo(newView.image, imageX-r, imageY+r-i);
        if (similarity>maxSimilarity) {
          maxSimilarity = similarity;
          found=true;
          newX=imageX-r;
          newY=imageY+r-i;
        }
      }
    }

    if (found) {
      if (firstView.image!=newView.image && 
        getSimilarity(firstView.image, imageX0, imageY0, newView.image, newX, newY, 8)<0.5) return false;
      firstView=view;
      imageX0=imageX;
      imageY0=imageY;
      imageX = newX;
      imageY = newY;
      view = newView;
      position = newView.projectImageToPoint(imageX, imageY, position);
      return true;
    } else return false; //Search failed
  }


  float getSimilarityTo(PImage image, int x, int y) {
    if (image==null) throw new NullPointerException();
    if (view.image==null) throw new IllegalStateException();

    if (view.image.pixels==null) view.image.loadPixels();
    if (image.pixels==null) image.loadPixels();

    return getSimilarity(view.image, imageX, imageY, image, x, y, 8);

    /*
    
     //Compare individual pixels
     
     color c1 = view.image.pixels[imageY*view.image.width+imageX];
     color c2 = image.pixels[y*image.width+x];
     float errHue = abs(hue(c2)-hue(c1))*brightness(c1)/65536.0;
     float errBrightness = abs(brightness(c2)-brightness(c1))/255.0;
     float errSaturation = abs(saturation(c2)-saturation(c1))/255.0;
     float error1 = (errHue+errBrightness+errSaturation)/3.0;
     
     float dot = 0.0, t1 = 0.0, t2 = 0.0; //Dot product variables
     float totalDifference = 0.0, weight = 0.0; //Cumulative similarity variables
     
     for (int i = -SMALL_SEARCH_RADIUS; i<SMALL_SEARCH_RADIUS; i++) {
     for (int j = -SMALL_SEARCH_RADIUS; j<SMALL_SEARCH_RADIUS; j++) {
     color c3 = view.image.pixels[(imageY+j)*view.image.width+imageX+i];
     color c4 = image.pixels[(y+j)*image.width+x+i];
     
     //Calculate the dot product of
     //the vectors formed by the areas
     //around the two pixels
     dot+=hue(c3)*hue(c4)+brightness(c3)*brightness(c4)+saturation(c3)*saturation(c4);
     t1+=hue(c3)*hue(c3)+brightness(c3)*brightness(c3)+saturation(c3)*saturation(c3);
     t2+=hue(c4)*hue(c4)+brightness(c4)*brightness(c4)+saturation(c4)*saturation(c4);
     
     //Calculate the similarity of two subimages
     //by subtracting one picture from the other and
     //comparing the net HSV with the one from the
     //first image
     totalDifference+=abs(saturation(c4)-saturation(c3))+abs(brightness(c4)-brightness(c3))/255.0;
     weight+=255.0;
     }
     }
     //Evaluate the dot and constrain it between -1 and 1
     dot = abs(dot*dot/(t1*t2));
     if (Float.isNaN(dot)) return 0.0;
     assert dot<=1.0: 
     "Dot is "+dot;
     
     
     //print(1.0-error1);
     //print("     ");
     //print(5.0*dot-4.0);
     //print("     ");
     //print((1.0-totalDifference/weight));
     //print("     ");
     
     float similarity = ((1.0-error1)+max(0,(5.0*dot-4.0))+(1.0-totalDifference/weight))/3.0;
     
     //println(similarity);
     
     //Get an average-ish value of pixel-comparison, dot product, and pixel field
     return similarity;
     */
  }
}
