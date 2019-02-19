float angleOfView = PI/9.0;

int numImages = 100;

TrackablePoint trackablePoint = new TrackablePoint();
TrackablePoint2 trackablePoint2 = new TrackablePoint2();
PVector point = new PVector(0, 0, 0);

PVector[] cube = {
  new PVector(0, 0, 0), 
  new PVector(0, 0, 1), 
  new PVector(0, 1, 0), 
  new PVector(0, 1, 1), 
  new PVector(1, 0, 0), 
  new PVector(1, 0, 1), 
  new PVector(1, 1, 0), 
  new PVector(1, 1, 1)
};

View[] views = new View[numImages];
String[] data;

int currentView = 20;

void setup() {
  frameRate(20);

  size(512, 512);

  data = loadStrings("positions.csv");
  views[currentView] = initializeView(data[currentView], currentView);

  stroke(200, 32, 0);
  strokeWeight(4);

  colorMode(HSB);

  View view = new View();
  view.position = new PVector(0, 0, 5);
  view.rotation = new PVector(0, 0, 0);
  view.image=loadImage("0001.png");
  println(view.projectPointToImage(point));

  trackablePoint.trackAt(256, 256);
  
  thread("imageLoaderThread");
  //noLoop();
}

void draw() {
  drawView(views[currentView]);
  
  /*
  float h = -0;
  for (PVector v : cube) {
    colorMode(HSB);
    stroke((h+=30), 255, 255);
    drawVector(views[currentView].projectPointToImage(v));
  }
  */
  if (keyPressed) {
    currentView=(currentView+1)%numImages;
    if (views[currentView]==null) {
      views[currentView]=initializeView(data[currentView], currentView);
    }
  }

  

  if (mousePressed) {

    //PVector mouseCoordinates = new PVector(mouseX, mouseY);
    //point=views[currentView].projectImageToPoint(mouseCoordinates,point);
    //println(point);         

    /*
    PVector mouseCoordinates = new PVector(mouseX, mouseY);
     trackablePoint.position = views[currentView].projectImageToPoint(mouseCoordinates,point);
     trackablePoint.imageX = mouseX;
     trackablePoint.imageY = mouseY;
     trackablePoint.view = views[currentView];
     trackablePoint.firstView = views[currentView];
     println(trackablePoint.position);
     */


    trackablePoint2.trackAt(mouseX, mouseY);
    //println(trackablePoint2.position);
  }
  boolean trackablePointIsLive = trackablePoint2.update(views[currentView]);
  
  //stroke(200,255,255);
  //ellipse(trackablePoint2.locations[0].imageX,trackablePoint2.locations[0].imageY,8.0,8.0);
  
  if (trackablePointIsLive) stroke(128, 255, 255);
  else stroke(0, 255, 255);
  PVector v = views[currentView].projectPointToImage(trackablePoint2.position);
  drawVector(v);
  //line(trackablePoint2.locations[0].imageX,trackablePoint2.locations[0].imageY,v.x,v.y);
  

  //stroke(0,255,255);
  //drawVector(views[currentView].projectPointToImage(point));
  //stroke(128,255,255);
  //drawVector(views[currentView].projectPointToImage(views[currentView].toWorldCoordinates(views[currentView].toViewCoordinates(point))));

  /*
  if(trackablePoint.update(views[currentView])) stroke(64,255,255);
   else stroke(0,255,255);
   drawVector(views[currentView].projectPointToImage(trackablePoint.position));
   */

  fill(255);
  text(trackablePoint2.position.x, 2, 10);
  text(trackablePoint2.position.y, 2, 30);
  text(trackablePoint2.position.z, 2, 50);
}

void mouseReleased() {
}

void imageLoaderThread(){
  for(int i = 0; i < numImages; i++){
    if (views[i]==null) {
      views[i]=initializeView(data[i], i);
    }
  }
}