FeatureExtractorFactory loader;

FeatureExtractor extractor1;
FeatureExtractor extractor2;
FeatureAssembler assembler;

String[] viewDimensions;
int imageNum = 2;

final int numImages = 100;

void setup() {
  size(1200, 640);

  viewDimensions = loadStrings("sim1/positions.csv");

  assembler = new FeatureAssembler();
  
  loader = new FeatureExtractorFactory();

  //Build the model

  /*
  println("Loading Assembler");
   
   int m = millis();
   for (int i = 0; i < 8; i++) {
   thread("loaderThread");
   }
   while (currentIndex<100) {
   delay(5000);
   }
   print("Time spent loading 100 FeatureExtractors: ");
   println(millis()-m);
   
   
   println("Assembling");
   m = millis();
   assembler.generatePointCloud("data/pointCloud", 7);
   print("Time spent assembling: ");
   println(millis()-m);
   */
}

volatile int currentIndex = 0;
void loaderThread() {

  FeatureExtractorFactory loader = new FeatureExtractorFactory();

  while (currentIndex<100) {
    int i = currentIndex++;
    int n = millis();
    FeatureExtractor featureExtractor = loader.createFeatureExtractors(viewDimensions[i], i)[0];
    assembler.addView(featureExtractor);
    synchronized(System.out) {
      print("\t");
      print(i);
      print(".) Found ");
      print(featureExtractor.features.size());
      print(" features in ");
      print(millis()-n);
      println(" milliseconds");
    }
  }
}

void draw() {
  if (extractor1==null) {
    background(0, 0, 255);
    text("No FeatureExtractor loaded yet", 8, 16);
  } else {
    background(32, 32, 48);
    extractor1.draw();
    pushMatrix();
    translate(extractor1.image.width, 0);
    extractor2.draw();
    popMatrix();
    fill(255);
    text(imageNum, 8, 30);
  }
}

void mouseReleased() {

  imageNum%=100;
  extractor1 = loader.createFeatureExtractors(viewDimensions[imageNum], imageNum-1)[0];
  extractor1.loadAllFeaturesFromImage();
  imageNum++;
  imageNum%=100;
  extractor2 = loader.createFeatureExtractors(viewDimensions[imageNum], imageNum-1)[0];
  extractor2.loadAllFeaturesFromImage();
}
