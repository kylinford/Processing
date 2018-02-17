float x;
float y;
PImage img;
PImage img1;
 
void setup(){
  size(1024,576);
  img = loadImage("A.jpg"); 
  img1 = loadImage("A.jpg"); 
  frameRate(60); // animation goes this many frames per second
  x=-width;
  y=0;
}
 
void draw(){
  background(107,17,77);
  x = x+2; // image goes up this many pixels per frame
  image(img,x,y);
}