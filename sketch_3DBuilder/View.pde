class View {
  PImage image;
  PVector position;
  PVector rotation;

  void loadView(String data, int imageNum) {
    //Get vectors
    String[] strings = split(data, ", ");
  assert strings.length==6: 
    "Failed to load view: expected vectors for position and rotation (6 values) but got "+strings.length;
    position = new PVector(float(strings[0]), float(strings[1]), float(strings[2]));
    rotation = new PVector(float(strings[3]), float(strings[4]), float(strings[5]));

    //Get image
    StringBuilder imagePath = new StringBuilder(12);
    imagePath.append("sim1/");
    imageNum++;
    imagePath.append(imageNum/1000);
    imageNum%=1000;
    imagePath.append(imageNum/100);
    imageNum%=100;
    imagePath.append(imageNum/10);
    imageNum%=10;
    imagePath.append(imageNum);
    imagePath.append(".png");
    image=loadImage(imagePath.toString());
  }
  
  PVector toViewCoordinates(PVector point){
    
    //Create a copy of the point to transform it
    PVector p = point.copy();
    
    //Undo the camera transformations
    //Get the relative position of the point relative to the camera
    p.sub(position);
    //Undo the camera's rotation to get where the point is in 3D
    //with camera coordinates.
    rotateZ(p, -rotation.z);
    rotateY(p, -rotation.y);
    rotateX(p, -rotation.x);
    
    //Blender quirk--depth should be +z but was -z in Blender
    p.z=-p.z;
    
    return p;
  }
  
  PVector toWorldCoordinates(PVector point){
    
    //Create a copy of the point to transform it
    PVector p = point.copy();
    
    //Blender quirk--depth should be +z but was -z in Blender
    p.z=-p.z;
    
    //Apply the camera transformations
    //Rotate around the camera
    rotateX(p, rotation.x);
    rotateY(p, rotation.y);
    rotateZ(p, rotation.z);
    
    //Get the total position of the point and the camera
    p.add(position);
    
    return p;
  }
  
  /**
  *Projects a point in 3D space onto this image.
  *Assumes:
  *  +z is up in 3D space
  *  +y is depth in 3D space
  *  and -y is up in image coordinates
  *@param point the point to project to the image
  *@return a 2D PVector in image coordinates that
  *is the projection of the point "point"
  **/
  PVector projectPointToImage(PVector point){
    //Get the view coordinates of the point
    PVector p = toViewCoordinates(point);
    
    
    //Create a new vector to return image coordinates
    PVector output = new PVector();
    
    
    //Flatten the point into 2D coordinates.
    output.x=p.x/p.z*QUARTER_PI/angleOfView*image.width*2.0+image.width/2.0;
    output.y=p.y/-p.z*QUARTER_PI/angleOfView*image.width*2.0+image.height/2.0;
    
    //Return the output vector
    return output;
  }
  
  /**
  *Projects a point in this image onto 3D space.
  *Assumes:
  *  +z is up in 3D space
  *  +y is depth in 3D space
  *  and -y is up in image coordinates
  *@param imageCoordinates the point to project into 3D space
  *@param guess a 3D point that might be similar in coordinates
  *with the projected point
  *@return a 3D PVector in 3D coordinates that
  *is the projection of the point "imageCoordinates"
  **/
  PVector projectImageToPoint(float imageX, float imageY, PVector guess){
    //Create a new 3D point with camera-coordinates
    PVector p;
    if(guess==null){
      //Take a blind guess
      p = new PVector(0,0,5);
    }
    else{
      //Get the view coordinates of the guess point
      p = toViewCoordinates(guess);
    }
    
    
    //Set the vector's x and y values so that the point appears to be in
    // the same place as "imageCoordinates" when projected onto the image
    p.x=(imageX-image.width/2.0)/2.0/image.width*p.z/QUARTER_PI*angleOfView;
    p.y=-(imageY-image.width/2.0)/2.0/image.height*p.z/QUARTER_PI*angleOfView;
    
    //Return the output vector
    return toWorldCoordinates(p);
  }

  /**
  *Projects a point in this image onto 3D space.
  *Assumes:
  *  +z is up in 3D space
  *  +y is depth in 3D space
  *  and -y is up in image coordinates
  *@param imageCoordinates the point to project into 3D space
  *@param guess a 3D point that might be similar in coordinates
  *with the projected point
  *@return a 3D PVector in 3D coordinates that
  *is the projection of the point "imageCoordinates"
  **/
  PVector projectImageToPoint(PVector imageCoordinates, PVector guess){
    return projectImageToPoint(imageCoordinates.x, imageCoordinates.y, guess);
  }
  
  boolean isSimilarTo(View view, float tolerance){
    return (abs(view.position.x-position.x)+
    abs(view.position.y-position.y)+
    abs(view.position.y-position.z)+
    abs(view.rotation.y-rotation.x)+
    abs(view.rotation.y-rotation.y)+
    abs(view.rotation.y-rotation.z))<tolerance;
  }
} //<>// //<>//

View initializeView(String data, int index) {
  View view = new View();
  view.loadView(data, index);
  return view;
}

void drawView(View view) {
  image(view.image, 0, 0);
}
