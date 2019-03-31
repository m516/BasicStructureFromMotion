public class HarrisCornerDetector extends FeatureExtractor { //<>//
  final int WINDOW_SIZE = 4;



  public HarrisCornerDetector(CameraCoordinates coordinates, PImage image) {
    super(coordinates, image);
  }

  public void loadAllFeaturesFromImage() {
    //TODO implement

    //Inspired by Cornel lecture notes
    //http://www.cs.cornell.edu/courses/cs4670/2015sp/lectures/lec07_harris_web.pdf

    //convert to greyscale
    float[][] grayImg = new float[image.width][image.height];
    if (image.pixels==null)image.loadPixels();
    for (int i = 0; i < image.width; i++) {
      for (int j = 0; j < image.height; j++) {
        grayImg[i][j] = toGrayscale(image.pixels[j*image.width + i])/255.0;
      }
    }

    //convert to x- and y-derivatives via the Sobel operator
    //See https://en.wikipedia.org/wiki/Image_derivatives
    float[][] Ix = new float[image.width][image.height];
    float[][] Iy = new float[image.width][image.height];

    for (int i = 1; i < image.width-1; i++) {
      for (int j = 1; j < image.height-1; j++) {
        Ix[i][j] = grayImg[i-1][j-1]+
          2.0*grayImg[i][j-1]+
          grayImg[i+1][j-1]-
          grayImg[i-1][j+1]-
          2.0*grayImg[i][j+1]-
          grayImg[i+1][j+1];

        Iy[i][j] = grayImg[i-1][j-1]+
          2.0*grayImg[i-1][j]+
          grayImg[i-1][j+1]-
          grayImg[i+1][j-1]-
          2.0*grayImg[i+1][j]-
          grayImg[i+1][j+1];
      }
    }

    float[][] harrisCornerness = new float[image.width][image.height];

   
    for (int i = 1+WINDOW_SIZE; i < image.width-1-WINDOW_SIZE; i++) {
      for (int j = 1+WINDOW_SIZE; j < image.height-1-WINDOW_SIZE; j++) {
         //Compute the structure tensor for each pixel
        float M1 = 0.0, M2 = 0.0, M3 = 0.0;
        for (int p = i-WINDOW_SIZE; p < i+WINDOW_SIZE; p++) {
          for (int q = j-WINDOW_SIZE; q < j+WINDOW_SIZE; q++) {
            int dp = p-i, dq = q-j;
            M1+=Ix[p][q]*Ix[p][q]*(2.0*float(dp*dp+dq*dq)/float(WINDOW_SIZE*WINDOW_SIZE)); //*(float(p*p+q*q)/float(WINDOW_SIZE*WINDOW_SIZE/2))
            M2+=Iy[p][q]*Iy[p][q]*(2.0*float(dp*dp+dq*dq)/float(WINDOW_SIZE*WINDOW_SIZE));
            M3+=Ix[p][q]*Iy[p][q]*(2.0*float(dp*dp+dq*dq)/float(WINDOW_SIZE*WINDOW_SIZE));
          }
        }
        //Estimate eigenvalues
        float determinant = M1*M2-M3*M3;
        float trace = M1+M2;
        harrisCornerness[i][j] = determinant-0.1*trace;
        //set(i, j, color(determinant/trace*mouseY/height*255.0,0,0));
        if (int(mouseX)==i&&int(mouseY)==j) {
          fill(color(255, 0, 0));
          text(harrisCornerness[i][j], 8, 42);
          fill(color(0, 255, 0));
          text(Ix[i][j], 8, 52);
          text(Iy[i][j], 8, 62);
          fill(color(0, 0, 255));
          text(M1, 8, 72);
          text(M2, 8, 82);
          text(M3, 8, 92);
        }
      }
    }

    //Find local maxima
    boolean[][] maximumCornerness = new boolean[image.width][image.height];
    for (int i = 1+WINDOW_SIZE; i < image.width-1-WINDOW_SIZE; i++) {
      for (int j = 1+WINDOW_SIZE; j < image.height-1-WINDOW_SIZE; j++) {

        //Use a greedy algorithm to look for maxima
        if (harrisCornerness[i][j]<1000.0) continue;
        int p = i, q = j;
        boolean maxFound = false;

        while (!maxFound) {
          byte dir = -1;
          float max = harrisCornerness[p][q];
          if (harrisCornerness[p-1][q]>max) {
            dir=0;
            max=harrisCornerness[p-1][q];
          }
          if (harrisCornerness[p+1][q]>max) {
            dir=1;
            max=harrisCornerness[p+1][q];
          }
          if (harrisCornerness[p][q-1]>max) {
            dir=2;
            max=harrisCornerness[p][q-1];
          }
          if (harrisCornerness[p][q+1]>max) {
            dir=3;
            max=harrisCornerness[p][q+1];
          }
          switch(dir) {
          case 0:
            p--;
            break;
          case 1:
            p++;
            break;
          case 2:
            q--;
            break;
          case 3:
            q++;
            break;
          default:
            //Maximum is at the current point. No need to search further
            maxFound=true;
          }
        }
        maximumCornerness[p][q]=true;
        set(p,q,color(255,0,0));
      }
    }
    
    //Instantiate the Features list
    if(features==null){
      features = new LinkedList<Feature>();
    }
    else{
      features.clear();
    }
    
    //Iterate one last time through the image and find points marked as corners
    for (int i = 1+WINDOW_SIZE; i < image.width-1-WINDOW_SIZE; i++) {
      for (int j = 1+WINDOW_SIZE; j < image.height-1-WINDOW_SIZE; j++) {
        if(maximumCornerness[i][j]){
          Feature f = new Feature(coordinates, new PVector(i,j));
          f.type=1;
          features.add(f);
        }
      }
    }
  }

  float toGrayscale(color c) {
    return float((c >> 16 & 0xFF) + (c >> 8 & 0xFF) + (c & 0xFF))/3.0;
  }

  @Override public void draw() {
    super.draw();
    loadAllFeaturesFromImage();
  }
}
