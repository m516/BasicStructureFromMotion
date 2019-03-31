public class PointCloudWriter {
  private String ssvFile = "data/pointList.ssv";
  private String plyFile = "data/pointCloud.ply";


  PrintWriter outputSSV;
  PrintWriter outputPLY;

  public PointCloudWriter(String extensionlessFileName) {
    ssvFile = extensionlessFileName + ".ssv";
    plyFile = extensionlessFileName + ".ply";
    initializeOutputFiles();
  }

  public PointCloudWriter() {
    initializeOutputFiles();
  }


  private void initializeOutputFiles() {
    outputSSV = createWriter(ssvFile);
  }

  public void printVector(PVector v) {
    outputSSV.print(v.x);
    outputSSV.print(" ");
    outputSSV.print(v.y);
    outputSSV.print(" ");
    outputSSV.println(v.z);
  }

  private void printPointCloud() {
    outputSSV.flush();
    outputSSV.close();

    String[] points = loadStrings(ssvFile);
    outputPLY = createWriter(plyFile);

    outputPLY.println("ply");
    outputPLY.println("format ascii 1.0");
    outputPLY.print("element vertex ");
    outputPLY.println(points.length);
    outputPLY.println("property float x");
    outputPLY.println("property float y");
    outputPLY.println("property float z");
    outputPLY.println("end_header");

    for (String s : points) {
      outputPLY.println(s);
    }

    outputPLY.flush();
    outputPLY.close();
  }

  public void close() {
    printPointCloud();
  }
}

public class FeatureExtractorFactory {
  FeatureExtractor[] featureExtractors;

  public FeatureExtractorFactory() {
  };

  public FeatureExtractor[] createFeatureExtractors(String data, int imageNum) {


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

    FeatureExtractor[] f = new FeatureExtractor[1];
    f[0] = new HarrisCornerDetector(cc, image);

    featureExtractors = f;
    return f;
  }
}
