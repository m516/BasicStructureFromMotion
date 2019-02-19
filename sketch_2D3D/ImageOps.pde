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
      
      float r1 = red(c1), g1 = green(c1), b1 = blue(c1);
      float r2 = red(c2), g2 = green(c2), b2 = blue(c2);
      
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