import java.util.LinkedList;

public class FeatureAssembler {
  public ArrayList<AnnotatedView> views;

  public FeatureAssembler() {
  }

  public FeatureAssembler(FeatureExtractor[] featureExtractors) {
    for (FeatureExtractor f : featureExtractors) {
      AnnotatedView newView = new AnnotatedView(f);
      views.add(newView);
    }
  }

  public FeatureAssembler(String[] inputViewFiles) {
    for (String s : inputViewFiles) {
      AnnotatedView newView = new AnnotatedView(s);
      views.add(newView);
    }
  }

  public void generatePointCloud(String extensionlessOutputFileName) {
    PointCloudWriter output = new PointCloudWriter(extensionlessOutputFileName);

    //Go through each Feature in each AnnotatedView
    for (int i = 0; i < views.size(); i++) {
      AnnotatedView a = views.get(i);
      for (Feature f : a.features) {
        for (int j = i+1; j < views.size(); j++) {
          AnnotatedView b = views.get(i);
          for (Feature g : b.features) {
            if(f.equals(g)) {
              PVector guessedPoint = f.estimatePosition(g);
              output.printVector(guessedPoint);
            }
          }
        }
      }
    }
    
    output.close();
  }



  public class AnnotatedView {
    CameraCoordinates coordinates;
    LinkedList<Feature> features;

    public AnnotatedView(FeatureExtractor featureExtractor) {
      coordinates = featureExtractor.coordinates;
      features = featureExtractor.features;
    }
    public AnnotatedView(String inputFileName) {
      loadFeaturesFromFile(inputFileName);
    }
    public AnnotatedView(PImage image, PVector cameraPosition, PVector cameraDirection) {
      throw new UnsupportedOperationException("Method not implemented yet!");
    }
    public AnnotatedView(PImage image, CameraCoordinates cameraCoordinates) {
      throw new UnsupportedOperationException("Method not implemented yet!");
    }

    private void loadFeaturesFromFile(String inputFileName) {
      String[] lines = loadStrings(inputFileName);
      for (int i = 2; i < lines.length; i++) {
        Feature newFeature = new Feature(lines[0], lines[1], lines[i]);
        features.add(newFeature);
      }
    }
  }
}
