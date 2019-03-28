public class PointCloudWriter {
  private String ssvFile = "data/pointList.ssv";
  private String plyFile = "data/pointCloud.ply";


  PrintWriter outputSSV, outputPLY;
  
  public PointCloudWriter(String extensionlessFileName){
    ssvFile = extensionlessFileName + ".ssv";
    plyFile = extensionlessFileName + ".ply";
    initializeOutputFiles();
  }
  
  public PointCloudWriter(){
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
