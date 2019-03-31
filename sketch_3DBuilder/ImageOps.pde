/*
Gets the similarity between the pixel in img1 at (x1,y1) and the pixel in img2 at (x2,y2)
based on the pixels around them
*/
float getSimilarity(PImage img1, int x1, int y1, PImage img2, int x2, int y2, int radius){
  if(x1<radius) return 0.0;
  if(y1<radius) return 0.0;
  if(x2<radius) return 0.0;
  if(y2<radius) return 0.0;
  if(x1+radius>=img1.width) return 0.0;
  if(y1+radius>=img1.height) return 0.0;
  if(x2+radius>=img2.width) return 0.0;
  if(y2+radius>=img2.height) return 0.0;
  
  if(img1.pixels==null) img1.loadPixels();
  if(img2.pixels==null) img2.loadPixels();
  
  float dot = 0.0, mag1 = 0.0, mag2 = 0.0;
  float totalDifference = 0.0;
  
  for (int i = -radius; i<radius; i++) {
    for (int j = -radius; j<radius; j++) {
      color c1 = img1.pixels[(y1+j)*img1.width+(x1+i)];
      color c2 = img2.pixels[(y2+j)*img2.width+(x2+i)];
      
      float r1 = c1>>16&0xFF, g1 = c1>>8&0xFF, b1 = c1&0xFF;
      float r2 = c2>>16&0xFF, g2 = c1>>8&0xFF, b2 = c2&0xFF;
      
      dot +=r1*r2+g1*g2+b1*b2;
      mag1+=r1*r1+g1*g1+b1*b1;
      mag2+=r2*r2+g2*g2+b2*b2;
      
      totalDifference += abs(r1-r2)+abs(g1-g2)+abs(b1-b2);
    }
  }
  dot=(dot*dot)/(mag1*mag2);
  if(Float.isNaN(dot)) return 0.0;
  assert dot<=1.0001: "Dot is "+dot;
  assert totalDifference>=0.0: "totalDifference is "+totalDifference;
  
  return abs(dot)-totalDifference/(radius*radius*3*256);
}

/*
Searches the pixels within a radius LARGE_SEARCH_RADIUS around the point (x2, y2)
in img2, and compares them with the pixel at (x1,y1) within img1

Returns a 3D PVector, where X and Y are the screen coordinates and Z is the 
*/
//PVector getMostSimilarPixel(PImage img1, int x1, int y1, PImage img2, int x2, int y2){
  
//}
