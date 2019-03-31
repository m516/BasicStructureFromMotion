FeatureExtractorFactory loader;

FeatureExtractor extractor;
FeatureAssembler assembler;

String[] viewDimensions;
int imageNum = 0;

final int numImages = 100;

void setup() {
  size(640, 480);

  viewDimensions = loadStrings("sim1/positions.csv");
  loader = new FeatureExtractorFactory();
  
  assembler = new FeatureAssembler();

  //Build the model
  
  println("Loading Assembler");

  int m = millis();
  for (int i = 0; i < 100; i++) {
    int n = millis();
    extractor = loader.createFeatureExtractors(viewDimensions[i], i)[0];
    assembler.addView(extractor);
    print("\t");
    print(i);
    print(".) Found ");
    print(extractor.features.size());
    print(" features in ");
    print(millis()-n);
    println(" milliseconds");
  }
  print("Time spent loading 100 FeatureExtractors: ");
  println(millis()-m);
  
  println("Assembling");
  m = millis();
  assembler.generatePointCloud("data/pointCloud", 7);
  print("Time spent assembling: ");
  println(millis()-m);
}

void draw() {
  if (extractor==null) {
    background(0, 0, 255);
    text("No FeatureExtractor loaded yet", 8, 16);
  } else {
    background(32, 32, 48);
    extractor.draw();
    fill(255);
    text(imageNum, 8, 30);
  }
}

void mouseReleased() {

  imageNum%=100;

  extractor = loader.createFeatureExtractors(viewDimensions[imageNum], imageNum-1)[0];


  imageNum++;
}
