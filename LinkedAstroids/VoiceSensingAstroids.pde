import ddf.minim.*;

import ddf.minim.analysis.*;

import ddf.minim.effects.*;

import ddf.minim.signals.*;

import ddf.minim.spi.*;

import ddf.minim.ugens.*;

Minim minim;
AudioInput input;
Circle c;

ArrayList<Circle> circles = new ArrayList<Circle>();
int InitCircileNum = 50;
float VelDump = 0.99;
int SoundSensitivity = 100;
int initWidth = 5;
int initHeight = 5;
int radius = 100;

boolean IsInMiddleCircle(int x, int y){
  int xlength = x-width/2;
  int ylength = y-height/2;
  if (xlength*xlength+ylength*ylength <= radius*radius)
    return true;
  return false;
}



void setup(){

  size (1680, 1050);

  minim = new Minim(this);

  input = minim.getLineIn();

  for (int i=0;i<InitCircileNum; i++){

    int circle_x = (int)random(width/2-initWidth/2, width/2+initWidth/2);

    int circle_y = (int)random(height/2-initHeight/2, height/2+initHeight/2);

    while (!IsInMiddleCircle(circle_x, circle_y)){

      circle_x = (int)random(width/2-initWidth/2, width/2+initWidth/2);

      circle_y = (int)random(height/2-initHeight/2, height/2+initHeight/2);

    }

    c = new Circle(circle_x, circle_y);

    circles.add(c);

  }

  

}



void draw() {

  background(0);

  for (int i = 0; i < circles.size(); ++i) {

    for (int k = 0; k < circles.size(); ++k) {

      if (i!=k) {

        PVector f = circles.get(k).attract(circles.get(i));

        circles.get(i).applyForce(f);

        circles.get(i).link(circles.get(k));

      }

    }

    circles.get(i).update();

    circles.get(i).display();

    circles.get(i).checkEdges();

  }

}



void mouseClicked(){

  c = new Circle();

  circles.add(c);

}



void mouseDragged(){

  c = new Circle();

  circles.add(c);

}



class Circle{

  PVector location,velocity,acceleration;

  float G,mass,size;



  Circle(){

    location = new PVector(mouseX, mouseY);

    velocity = new PVector(0,0);

    acceleration = new PVector(0,0);

    G = 0.6;

    mass = random(2,5);

    size = mass;

  }

  

  Circle(float x, float y){

    location = new PVector(x, y);

    velocity = new PVector(0,0);

    acceleration = new PVector(0,0);

    G = 0.6;

    mass = random(2,5);

    size = mass;

  }



  void applyForce(PVector force){

    PVector f = force.get();

    f.div(mass);

    acceleration.add(f);

  }



  void update(){

    velocity.add(acceleration);

    location.add(velocity);

    acceleration.mult(0);

    velocity.mult(VelDump);

  }



  void display(){

    noStroke();

    fill(255);

    ellipse(location.x, location.y,size,size);

  }



  void link(Circle c){

    stroke(255, 75);

    PVector dist = PVector.sub(c.location,location);

    if (dist.mag()<150) {

      line(location.x, location.y, c.location.x, c.location.y);

    }

  }



  PVector attract(Circle c){

    PVector force = PVector.sub(location,c.location);

    float distance = force.mag();

    distance = constrain(distance, 20, 25);

    force.normalize();

    float strength = (G*mass*c.mass)/(distance*distance) * (SoundSensitivity*input.right.get(input.bufferSize()-1));

    force.mult(strength);

    return force;

  }



  void checkEdges(){

    if (location.x < size/2) {

      location.x = size/2;

      velocity.x *= -1;

    } else if (location.x > width-size/2){

      location.x = width-size/2;

      velocity.x *= -1;

    }



    if (location.y < size/2) {

      location.y = size/2;

      velocity.y *= -1;

    } else if (location.y > height-size/2){

      location.y = height-size/2;

      velocity.y *= -1;

    }

  }

}