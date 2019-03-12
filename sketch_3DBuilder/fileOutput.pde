String ssvFile = "data/pointList.ssv";
String plyFile = "data/pointCloud.ply";


PrintWriter outputSSV, outputPLY;

void initializeOutputFiles() {
  outputSSV = createWriter(ssvFile);
}

void printVector(PVector v) {
  outputSSV.print(v.x);
  outputSSV.print(" ");
  outputSSV.print(v.y);
  outputSSV.print(" ");
  outputSSV.println(v.z);
}

void printPointCloud() {
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
  
  for(String s: points){
    outputPLY.println(s);
  }
  
  outputPLY.close();
}

void exit() {
  printPointCloud();
  super.exit();
}
