public class HarrisCornerDetector extends FeatureExtractor {
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


    float[][] M1 = new float[image.width][image.height];
    float[][] M2 = new float[image.width][image.height];
    float[][] M3 = new float[image.width][image.height];
    
    //Compute the structure tensor for each pixel
    for (int i = 1+WINDOW_SIZE; i < image.width-1-WINDOW_SIZE; i++) {
      for (int j = 1+WINDOW_SIZE; j < image.height-1-WINDOW_SIZE; j++) {
        M1[i][j] = M2[i][j] = M3[i][j] = 0.0;
        for (int p = i-WINDOW_SIZE; p < i+WINDOW_SIZE; p++) {
          for (int q = j-WINDOW_SIZE; q < j+WINDOW_SIZE; q++) {
            M1[i][j]+=Ix[p][q]*Ix[p][q]; //*(float(p*p+q*q)/float(2*WINDOW_SIZE*WINDOW_SIZE))
            M2[i][j]+=Iy[p][q]*Iy[p][q];
            M3[i][j]+=Ix[p][q]*Iy[p][q];
          }
        }
      }
    }


    //Debug
    for (int i = 0; i < image.width; i++) {
      for (int j = 0; j < image.height; j++) {
        float determinant = M1[i][j]*M2[i][j]-M3[i][j]*M3[i][j];
        float trace = M1[i][j]+M2[i][j];
        set(i, j, color(determinant/trace*mouseY*0.1));
      }
    }
    
    //TODO create new Feature objects at local maxima
    //TODO implement the window function
  }

  float toGrayscale(color c) {
    return ((c >> 16 & 0xFF) + (c >> 8 & 0xFF) + (c & 0xFF))/3.0;
  }

  @Override public void draw() {
    super.draw();
    loadAllFeaturesFromImage();
  }
}
