import processing.video.*;
import oscP5.*;
import netP5.*;
import java.util.concurrent.CopyOnWriteArrayList;

OscP5 oscP5;

Movie myMovie;
float speed = 1.0;

float house = 0;
CopyOnWriteArrayList<Circle> circleList = new CopyOnWriteArrayList<Circle>();
int totalNumCircles = 0;
boolean dropped = false;

float kMax = 1;
float n = 40; // number of blobs
float inter = 0.5; // difference between the sizes of two blobs
float maxNoise = 500;
float t = 0;


void setup() {
  // start oscP5, listening for incoming messages at port 3333
  oscP5 = new OscP5(this,3333);
  
  size(800, 600);
  frameRate(30);
  myMovie = new Movie(this, "fuk.mov");
  myMovie.speed(speed);
  myMovie.play();
  
}

void draw() {
  blendMode(BLEND);
  if (myMovie.available()) {
    myMovie.read();
  }
  
  if (myMovie.time() > 25 && speed > 0) { // movie is 25.045s long
    speed = -1.0;
    myMovie.speed(speed);
    myMovie.frameRate(4);
  } else if (myMovie.time() < 24 && speed < 0) {
    speed = 1.0;
    myMovie.speed(speed);
  }
  
  image(myMovie, 0, 0, width, height);
  
  blendMode(DIFFERENCE);
  noStroke();
  
  fill(house);
  rect(0, 0, width, height);
  
  blendMode(BLEND);
  t = frameCount/100.0;
  kMax = noise(t/2);
  
  //stroke(0);
  //strokeWeight(2);
  //for (Circle c : circleList) {
  //  c.draw();
  //  c.shrink();
  //}
  int numCirclesRemoved = 0;
  for (int i = circleList.size() - 1; i >= 0; i--) {
    Circle c = circleList.get(i);
    if (c.isValid()) {
      c.draw();
      c.shrink();
      c.n = c.n - numCirclesRemoved;
    } else {
      circleList.remove(i);
    }
  }
  
  house = max(0, house - 5);
}

//void blob(float size, float xCenter, float yCenter, float k, float t, float noisiness) {
//  beginShape();
//  float angleStep = 360 / 50.0;
//  for (float theta = 0; theta <= 360 + angleStep * 2; theta += angleStep) {
//    float r1 = cos(theta)+1;
//    float r2 = sin(theta)+1;
//    float r = size + noise(k * r1,  k * r2, t) * noisiness;
//    float x = xCenter + r * cos(theta);
//    float y = yCenter + r * sin(theta);
//    curveVertex(x, y);
//  }
//  endShape();
//}

class Circle {
  int strokeWeight = 60;
  float size;
  int n;
  
  float k;
  float noisiness;
  
  Circle() {
    totalNumCircles++;
    this.size = 200; //sqrt(height*height + width*width) + strokeWeight/2;
    this.n = circleList.size() + 1;
    println(n);
    
    this.k = kMax * sqrt((circleList.size()+1)/this.n);
    this.noisiness = maxNoise * ((circleList.size()+1)/this.n);
  }
  
  void shrink() {
    size = max(0, size - 1);
  }
  
  boolean isValid() {
    return (size > 0);
  }
  
  void draw() {
    //blendMode(dropped ? DIFFERENCE : EXCLUSION);
    
    //float alpha = dropped ? 250 : 100;
    //color[] colors = new color[]{ color(150, 30, 120, alpha), color(0, 150, 120, alpha), color(150, 150, 20, alpha) };
    
    //if (size < strokeWeight) {
    //  noStroke();
    //  fill(colors[n % colors.length]);
    //  circle(width/2, height/2, size + strokeWeight);
    //} else {
    //  noFill();
    //  strokeWeight(60);
    //  stroke(colors[n % colors.length]);
    //  circle(width/2, height/2, size);
    //}
    noStroke();
    if (n % 2 == 0) {
      fill(255);
    } else {
      fill(0);
    }
    
    beginShape();
    float angleStep = 360 / 50.0;
    for (float theta = 0; theta <= 360 + angleStep * 2; theta += angleStep) {
      float r1 = cos(theta)+1;
      float r2 = sin(theta)+1;
      float r = size + noise(k * r1,  k * r2, t) * noisiness; // + noise(k * r1,  k * r2, t) * noisiness;
      float x = (width/2) + r * cos(theta);
      float y = (height/2) + r * sin(theta);
      curveVertex(x, y);
    }
    endShape();
  }
}

void mousePressed() {
  ////myMovie.jump(10);
  //if (speed > 0) {
  //  speed = -1.0;
  //} else {
  //  speed = 1.0;
  //}
  //myMovie.speed(speed);
  //myMovie.play();
  
  //println(myMovie.time());
  //println(myMovie.duration());
}

void oscEvent(OscMessage m) {
  float t = millis();
  int i;
  
  float cps = -1;
  float cycle = -1;
  float n = -1;
  float gain = -1;
  int orbit = -1;
  String s = "";
  float distort = -1;
  
  for(i = 0; i < m.typetag().length(); ++i) {
    String name = m.get(i).stringValue();
    switch(name) {
      case "cps":
        cps = m.get(i+1).floatValue();
        break;
      case "cycle":
        cycle = m.get(i+1).floatValue();
        break;
      case "n":
        n = m.get(i+1).floatValue();
        break;
      case "gain":
        gain = m.get(i+1).floatValue();
        break;
      case "orbit":
        orbit = m.get(i+1).intValue();
        break;
      case "s":
        s = m.get(i+1).stringValue();
        break;
      case "distort":
        distort = m.get(i+1).floatValue();
      default:
        break;
    }
    ++i;
  }
  
  switch(s) {
    case "house":
      if (gain > 0) {
        house = int(40 * gain);
      } else {
        house = int(40);
      }
      break;
    case "supersaw":
      if (orbit == 3) {
        circleList.add(new Circle());
      }
      break;
    case "sn":
      dropped = true;
      break;
    default:
      // TODO: do something simple for all other sounds?
  }
}
