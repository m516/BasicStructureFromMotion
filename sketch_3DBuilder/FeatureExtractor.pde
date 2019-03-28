import java.io.FileWriter;
import java.io.*;

public abstract class FeatureExtractor {
  CameraCoordinates coordinates;
  PImage image;
  LinkedList<Feature> features;

  public FeatureExtractor(CameraCoordinates coordinates, PImage image) {
    this.coordinates = coordinates;
    this.image = image;
  }

  private void printFeaturesToFile(String outputFileName) {
    try {
      File file =new File(outputFileName);
      //chemin = dataPath;
      // positions.txt== your file;

      if (!file.exists()) {
        file.createNewFile();
      }

      FileWriter fw = new FileWriter(file, true);///true = append
      BufferedWriter bw = new BufferedWriter(fw);
      PrintWriter pw = new PrintWriter(bw);

      pw.write(coordinates.toString());
      for (Feature feature : features) {
        pw.write(feature.toString());
      }

      pw.close();
    }
    catch(IOException ioe) {
      System.err.println("Exception ");
      ioe.printStackTrace();
    }
  }

  void processImage(String outputFileName) {
    loadAllFeaturesFromImage();
    printFeaturesToFile(outputFileName);
  }



  void reset(CameraCoordinates coordinates, PImage image) {
    this.coordinates = coordinates;
    this.image = image;
    features.clear();
  }

  abstract void loadAllFeaturesFromImage(); //Potentially faster than searching pixel-by-pixel
}



public class FeatureExtractorLoader {
  FeatureExtractor featureExtractor;

  public FeatureExtractorLoader() {
  };

  public FeatureExtractor loadFeatureExtractor(String data, int imageNum) {
    
    
    //Get vectors
    String[] strings = split(data, ", ");
  assert strings.length==6: 
    "Failed to load view: expected vectors for position and rotation (6 values) but got "+strings.length;
    PVector position = new PVector(float(strings[0]), float(strings[1]), float(strings[2]));
    PVector direction = new PVector(float(strings[3]), float(strings[4]), float(strings[5]));

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
    PImage image=loadImage(imagePath.toString());
    
    CameraCoordinates cc = new CameraCoordinates(image, PI/9.0, position, direction);
    
    //FIXME
    FeatureExtractor f = new FeatureExtractor(cc, image);
  }
}
