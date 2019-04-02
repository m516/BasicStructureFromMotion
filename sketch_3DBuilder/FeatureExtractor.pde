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

  public void draw() {
    image(image, 0, 0);
    if (features==null) {
      text("No features processed yet", 8, 16);
    } else {
      text("Features found: "+features.size(), 8, 16);
      for (Feature f : features) {
        ellipse(f.positionInImage.x, f.positionInImage.y, 8, 8);
      }
    }
  }
  
  
}
