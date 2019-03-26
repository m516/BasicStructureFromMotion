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
  }

  public Feature(CameraCoordinates cameraCoordinates, float imageX, float imageY) {
    this.cameraCoordinates=cameraCoordinates;
    this.positionInImage = new PVector(imageX, imageY);
  }

  PVector estimatePosition(Feature alternateView) {
    return locationInWorld.pointClosestTo(alternateView.locationInWorld);
    //return locationInWorld.approximateIntersection(alternateView.locationInWorld);
  }

  public Feature parseFromStrings(String cameraDimensions, String imageDimensions, String positionInImage) {
    Feature feature;
    String[] cc = split(cameraDimensions, ' ');
    String[] id = split(imageDimensions, ' ');
    String[] pii= split(positionInImage, ' ');

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

    return new Feature(camera, posInImage);
  }
}

public abstract class FeatureExtractor {
  CameraCoordinates coordinates;
  PImage image;
  LinkedList<Feature> features;

  void extractFeaturesFromView(String outputFile){
    
  }

    abstract boolean isFeature(int x, int y); //to be implemented by corner detectors, etc.
}






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
}
