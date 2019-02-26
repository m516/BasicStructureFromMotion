/*
Rotates a 3D vector v a given number of radians, locking the x-axis
<br>
Note: this method mutates the vector. If the current vector can't 
be changed, make a copy of it first!

@param v the vector to rotate
@param theta the number of radians to rotate the vector
*/
void rotateX(PVector v, float theta){
  float cos = cos(theta), sin = sin(theta);
  float tempY = v.y*cos-v.z*sin;
  v.z = v.y*sin+v.z*cos;
  v.y=tempY;
}

/*
Rotates a 3D vector v a given number of radians, locking the y-axis
<br>
Note: this method mutates the vector. If the current vector can't 
be changed, make a copy of it first!

@param v the vector to rotate
@param theta the number of radians to rotate the vector
*/
void rotateY(PVector v, float theta){
  float cos = cos(theta), sin = sin(theta);
  float tempX = v.x*cos+v.z*sin;
  v.z = -v.x*sin+v.z*cos;
  v.x=tempX;
}

/*
Rotates a 3D vector v a given number of radians, locking the x-axis
<br>
Note: this method mutates the vector. If the current vector can't 
be changed, make a copy of it first!

@param v the vector to rotate
@param theta the number of radians to rotate the vector
*/
void rotateZ(PVector v, float theta){
  float cos = cos(theta), sin = sin(theta);
  float tempX = v.x*cos-v.y*sin;
  v.y = v.x*sin+v.y*cos;
  v.x=tempX;
}

/*
Displays a 2-dimensional vector by drawing an ellipse in its location

@param vec the vector to display
*/
void drawVector(PVector vec){
  ellipse(vec.x,vec.y,8.0,8.0);
}


class Line{
  PVector position, direction;
  
  public Line(PVector position, PVector direction){
    this.position=position;
    this.direction=direction;
  }
  
  public Line(){
    this(new PVector(), new PVector());
  }
  
  /**
  * Returns the point closest to the line "line"
  **/
  public PVector pointClosestTo(Line line){
    PVector n2 = new PVector();
    PVector.cross(direction, line.direction, n2);
    PVector.cross(line.direction, n2, n2);
    
    PVector output = direction.copy();
    output.setMag(direction.mag()*PVector.sub(line.position, position, new PVector()).dot(n2)/direction.dot(n2));
    output.add(position);
    
    return output;
  }
  
  /**
  * Returns the intersection of two lines in 3D space
  * or approximates it if the lines don't intersect
  * See Wikipedia article about skew lines
  **/
  public PVector approximateIntersection(Line line){
    PVector n1 = line.direction.cross(direction, new PVector());
    line.direction.cross(n1, n1);
    
    PVector n2 = direction.cross(line.direction, new PVector());
    line.direction.cross(n2, n2);
    
    PVector c1 = direction.copy();
    c1.setMag(PVector.sub(line.position, position, new PVector()).dot(n2)/direction.dot(n2));
    c1.add(position);
    
    PVector c2 = line.direction.copy();
    c2.setMag(PVector.sub(position, line.position, new PVector()).dot(n1)/line.direction.dot(n1));
    c2.add(line.position);
    
    return c1.lerp(c2, 0.5);
  }
}
