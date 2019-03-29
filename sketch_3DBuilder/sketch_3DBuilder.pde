FeatureExtractorFactory loader;

FeatureExtractor extractor;
String[] viewDimensions;
int imageNum = 0;

final int numImages = 100;

void setup(){
  size(640,480);
  
  viewDimensions = loadStrings("sim1/positions.csv");
  loader = new FeatureExtractorFactory();
}

void draw() {
  if(extractor==null) {
    background(0,0,255);
    text("No FeatureExtractor loaded yet", 8,16);
  }
  else {
    background(32,32,48);
    extractor.draw();
    fill(255);
    text(imageNum, 8,30);
  }
}

void mouseReleased() {
  
  imageNum%=100;
  
  extractor = loader.createFeatureExtractors(viewDimensions[imageNum],imageNum-1)[0];
  
  
  imageNum++;
}
