import java.util.LinkedList;


public class Feature { 
  CameraCoordinates cameraCoordinates;
  PVector positionInImage;
  Line locationInWorld;
  int type; //Identifies different kinds of points, e.g. corners could have a type of 1 and blobs could be type 2

  public Feature() {
  }

  public Feature(CameraCoordinates cameraCoordinates, PVector positionInImage) {
    this.cameraCoordinates=cameraCoordinates;
    this.positionInImage = positionInImage;
    updateLocationInWorld();
  }

  public Feature(CameraCoordinates cameraCoordinates, float imageX, float imageY) {
    this.cameraCoordinates=cameraCoordinates;
    this.positionInImage = new PVector(imageX, imageY);
    updateLocationInWorld();
  }
  
  public Feature(String cameraDimensions, String imageDimensions, String positionInImage){
    parseFromStrings(cameraDimensions, imageDimensions, positionInImage);
    updateLocationInWorld();
  }

  PVector estimatePosition(Feature alternateView) {
    return locationInWorld.pointClosestTo(alternateView.locationInWorld);
    //return locationInWorld.approximateIntersection(alternateView.locationInWorld);
  }
  
  public void updateLocationInWorld(){
    locationInWorld = cameraCoordinates.castRay(positionInImage);
  }

  private void parseFromStrings(String cameraDimensions, String imageDimensions, String positionOfPointInImage) {
    String[] cc = split(cameraDimensions, ' ');
    String[] id = split(imageDimensions, ' ');
    String[] pii= split(positionOfPointInImage, ' ');
    
    //File checking
    if(cc.length!=7){
      print("Error parsing camera directions in the following line\n     ");
      println(cameraDimensions);
      println("Expecting 7 values separated by a single space");
      println("Line should be: 'posX posY posZ dirX dirY dirZ angleOfViewInRadians'");
      throw new IllegalArgumentException();
    }
    if(id.length!=2){
      print("Error parsing image dimensions in the following line\n     ");
      println(imageDimensions);
      println("Expecting 2 values separated by a single space");
      println("Line should be: 'widthInPixels heightInPixels'");
      throw new IllegalArgumentException();
    }
    if(pii.length!=2){
      print("Error parsing image coordinates for feature in the following line\n     ");
      println(positionInImage);
      println("Expecting 2 values separated by a single space");
      println("Line should be: 'xInPixels yInPixels'");
      println("Also note that x and y are positive values relative to the upper left-hand corner of the image");
      throw new IllegalArgumentException();
    }

    PVector position = new PVector(float(cc[0]), float(cc[1]), float(cc[2]));
    PVector direction = new PVector(float(cc[3]), float(cc[4]), float(cc[5]));

    float angleOfView = float(cc[6]);

    PVector imageSize = new PVector(float(id[0]), float(id[1]));


    CameraCoordinates camera = new CameraCoordinates(
      imageSize, 
      angleOfView, 
      position, 
      direction
      );

    PVector posInImage = new PVector(float(pii[0]), float(pii[1]));
    
    cameraCoordinates=camera;
    positionInImage = posInImage;
  }
  
  public float distanceFrom(Feature other){
    if(locationInWorld==null) updateLocationInWorld();
    if(other.locationInWorld==null) other.updateLocationInWorld();
    
    return locationInWorld.distanceFrom(other.locationInWorld);
  }
  
  //Only returns a String representation of the PositionInImage vector.
  //To get a String representation of the camera coordinates use CamaeraCoordinates.toString()
  public String toString(){
    StringBuilder sb = new StringBuilder(64);
    sb.append(positionInImage.x);
    sb.append(" ");
    sb.append(positionInImage.y);
    return sb.toString();
  }
  
  public boolean equals(Object other){
      throw new UnsupportedOperationException("Method not implemented yet!");
  }
}
