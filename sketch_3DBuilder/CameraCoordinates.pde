public class CameraCoordinates {
  PVector position;
  PVector direction;
  float angleOfView;
  PVector imageResolution;

  public CameraCoordinates(PImage image, float angleOfView, PVector position, PVector direction) {
    imageResolution = new PVector(image.width, image.height);
    this.angleOfView = angleOfView;
    this.direction = direction;
    this.position = position;
  }

  public CameraCoordinates(PVector imageResolution, float angleOfView, PVector position, PVector direction) {
    this.imageResolution = imageResolution;
    this.angleOfView = angleOfView;
    this.direction = direction;
    this.position = position;
  }

  Line castRay(float imageX, float imageY) {
    Line ray = new Line();
    ray.position=position.copy();
    ray.direction=new PVector(0, 0, -1);
    //Set the vector's x and y values so that the point appears to be in
    // the same place as "imageCoordinates" when projected onto the image
    ray.direction.x=-(imageX-imageResolution.x/2.0)/2.0/imageResolution.x*ray.direction.z/QUARTER_PI*angleOfView;
    ray.direction.y =(imageY-imageResolution.x/2.0)/2.0/imageResolution.y*ray.direction.z/QUARTER_PI*angleOfView;

    //Apply the camera transformations
    //Rotate around the camera
    rotateX(ray.direction, direction.x);
    rotateY(ray.direction, direction.y);
    rotateZ(ray.direction, direction.z);

    ray.direction.setMag(1);

    return ray;
  }
  
  Line castRay(PVector imageCoords){return castRay(imageCoords.x,imageCoords.y);}
  Line castRay(Feature feature){return castRay(feature.positionInImage.x,feature.positionInImage.y);}

  public String toString() {
    StringBuilder sb = new StringBuilder(64);
    sb.append(position.x);
    sb.append(" ");
    sb.append(position.y);
    sb.append(" ");
    sb.append(position.z);
    sb.append(" ");
    sb.append(direction.x);
    sb.append(" ");
    sb.append(direction.y);
    sb.append(" ");
    sb.append(direction.z);
    sb.append(" ");
    sb.append(angleOfView);

    sb.append("\n");

    sb.append(imageResolution.x);
    sb.append(" ");
    sb.append(imageResolution.y);
    return sb.toString();
  }

  PVector toViewCoordinates(PVector point) {

    //Create a copy of the point to transform it
    PVector p = point.copy();

    //Undo the camera transformations
    //Get the relative position of the point relative to the camera
    p.sub(position);
    //Undo the camera's rotation to get where the point is in 3D
    //with camera coordinates.
    rotateZ(p, -direction.z);
    rotateY(p, -direction.y);
    rotateX(p, -direction.x);

    //Blender quirk--depth should be +z but was -z in Blender
    p.z=-p.z;

    return p;
  }

  PVector toWorldCoordinates(PVector point) {

    //Create a copy of the point to transform it
    PVector p = point.copy();

    //Blender quirk--depth should be +z but was -z in Blender
    p.z=-p.z;

    //Apply the camera transformations
    //Rotate around the camera
    rotateX(p, direction.x);
    rotateY(p, direction.y);
    rotateZ(p, direction.z);

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
  PVector projectPointToImage(PVector point) {
    //Get the view coordinates of the point
    PVector p = toViewCoordinates(point);


    //Create a new vector to return image coordinates
    PVector output = new PVector();


    //Flatten the point into 2D coordinates.
    output.x=p.x/p.z*QUARTER_PI/angleOfView*imageResolution.x*2.0+imageResolution.x/2.0;
    output.y=p.y/-p.z*QUARTER_PI/angleOfView*imageResolution.x*2.0+imageResolution.y/2.0;

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
  PVector projectImageToPoint(float imageX, float imageY, PVector guess) {
    //Create a new 3D point with camera-coordinates
    PVector p;
    if (guess==null) {
      //Take a blind guess
      p = new PVector(0, 0, 5);
    } else {
      //Get the view coordinates of the guess point
      p = toViewCoordinates(guess);
    }


    //Set the vector's x and y values so that the point appears to be in
    // the same place as "imageCoordinates" when projected onto the image
    p.x=(imageX-imageResolution.x/2.0)/2.0/imageResolution.x*p.z/QUARTER_PI*angleOfView;
    p.y=-(imageY-imageResolution.x/2.0)/2.0/imageResolution.y*p.z/QUARTER_PI*angleOfView;

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
  PVector projectImageToPoint(PVector imageCoordinates, PVector guess) {
    return projectImageToPoint(imageCoordinates.x, imageCoordinates.y, guess);
  }
  
  float angle(CameraCoordinates other){
    return PVector.angleBetween(direction, other.direction);
  }
}
