float angleOfView = PI/9.0;

int numImages = 100;

int debugStatus = 
  //1; // Tracking points, their accuracies, and failures
  //2; //Multiple output points, prints all points with their accuracies
3; //Multiple output points, prints all accurate (accuracy<0.05) points

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

int numTrackedPoints = 0;
TrackablePoint2[] currentPoints = new TrackablePoint2[50];

void setup() {
  frameRate(20);

  size(512, 512);

  data = loadStrings("sim1/positions.csv");
  views[currentView] = initializeView(data[currentView], currentView);
  
  initializeOutputFiles();
  

  stroke(200, 32, 0);
  strokeWeight(4);

  colorMode(HSB);

  View view = new View();
  view.position = new PVector(0, 0, 5);
  view.rotation = new PVector(0, 0, 0);
  view.image=loadImage("sim1/0001.png");
  println(view.projectPointToImage(point));

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


  //Update all tracked points 
  for (int i = 0; i < currentPoints.length; i++) {
    if (currentPoints[i]==null)
    {
      currentPoints[i] = new TrackablePoint2();
      currentPoints[i].update(views[currentView]);
    } else if (!currentPoints[i].update(views[currentView])) {
      if (currentPoints[i].accuracy<0.05 && debugStatus==3 || debugStatus==2) {
        println(currentPoints[i].position);
        printVector(currentPoints[i].position);
        if (debugStatus==2) {
          print("\t(");
          print(currentPoints[i].accuracy);
          println(")");
        }
      }
      currentPoints[i] = new TrackablePoint2();
      currentPoints[i].update(views[currentView]);
      currentPoints[i].trackAt(int(random(width)), int(random(height)));
    } else {
      stroke(100.0-100.0*currentPoints[i].accuracy, 255, 180);
      v = views[currentView].projectPointToImage(currentPoints[i].position);
      drawVector(v);
    }
  }


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

void imageLoaderThread() {
  for (int i = 0; i < numImages; i++) {
    if (views[i]==null) {
      views[i]=initializeView(data[i], i);
    }
  }
}
