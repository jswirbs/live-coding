import processing.video.*;
import oscP5.*;
import netP5.*;
import java.util.concurrent.CopyOnWriteArrayList;

OscP5 oscP5;

Movie movieFuk;
float movieSpeed = 0.872;

float house = 0;
CopyOnWriteArrayList<Circle> circleList = new CopyOnWriteArrayList<Circle>();
int totalNumCircles = 0;
int dropped = 0;

float kMax = 1;
float step = 0.01;
float n = 40; // number of blobs
float radius = 0; // diameter of the circle
float inter = 0.5; // difference between the sizes of two blobs
float maxNoise = 500;

int aliceReverse = 0;
int aliceAgain = 0;


void setup() {
  // start oscP5, listening for incoming messages at port 3333
  oscP5 = new OscP5(this,3333);
  
  size(800, 600);
  frameRate(30);
  movieFuk = new Movie(this, "fuk.mov");
  //movieFuk.speed(movieSpeed);
  //movieFuk.play();
  
}

void draw() {
  blendMode(BLEND);
  if (movieFuk.available()) {
    movieFuk.read();
    if (movieFuk.time() > 24.5 && movieSpeed > 0) { // movie is 25.045s long
      movieSpeed = -1.0;
    } else if (movieFuk.time() < 23.5 && movieSpeed < 0 && aliceReverse == 0 && aliceAgain == 0) {
      movieSpeed = 1.0;
    } else if (movieSpeed < 0 && aliceReverse == 1) {
      movieSpeed = -0.25;
    } else if (movieSpeed < 0 && aliceAgain == 1) {
      // calculate speed based on position in movie an how long it will take to get to datamosh
      float secondsTillDatamosh = 23 - movieFuk.time(); // datamosh is at about second 23
      movieSpeed = secondsTillDatamosh / 19.2; // about 19.2 seconds of build (8 cycles going from 80->120 cps)
      aliceAgain = 0;
    }
    movieFuk.speed(movieSpeed);
  }
  
  // fade in video with transparency (fades in in about 10 seconds, only first few seconds are really transparent though)
  float videoAlpha = min(256, movieFuk.time() * 10);
  tint(255, videoAlpha);
  image(movieFuk, 0, 0, width, height);
  noTint();
  
  blendMode(DIFFERENCE);
  noStroke();
  
  // very transparent background to give some movement to circles without house or video
  fill(30, 30, 30, 30);
  rect(0, 0, width, height);
  
  fill(house);
  rect(0, 0, width, height);
  
  for (Circle c : circleList) {
    c.draw();
    c.update();
  }
  
  for (int i = circleList.size() - 1; i >= 0; i--) {
    Circle c = circleList.get(i);
    if (!c.isValid()) {
      circleList.remove(i);
    }
  }
  house = max(0, house - 6);
}

class Circle {
  int strokeWeight = 60;
  float maxSize = sqrt(height*height + width*width) + strokeWeight/2;
  float size;
  int n;
  float dropped1UpdateRate = 10;
  
  Circle() {
    totalNumCircles++;
    if (dropped == 0) {
      this.size = maxSize;
    } else {
      this.size = 0;
    }
    this.n = totalNumCircles;
  }
  
  void update() {
    if (dropped == 0) {
      size = max(0 - strokeWeight, size - 10);
    } else if (dropped == 1) {
      size = max(0 - strokeWeight, size - dropped1UpdateRate);
      dropped1UpdateRate = max(0, dropped1UpdateRate - 0.4);
    } else if (dropped == 2) {
      size = min(maxSize, size + 20);
    } 
  }
  
  boolean isValid() {
    if (dropped == 0) {
      return (size > 0 - strokeWeight);
    } else {
      return (size < maxSize);
    }
  }
  
  void draw() {
    blendMode(EXCLUSION);
    float alpha = 40 + 110 * size/maxSize;
    if (dropped == 2) {
      blendMode(EXCLUSION);
      alpha = 80 + 150 * size/maxSize;
    }
    // color[] colors = new color[]{ color(250, 30, 210, alpha), color(0, 250, 210, alpha), color(250, 250, 20, alpha) };
    color[] colors = new color[]{ // pastel rainbow palette
      color(255, 173, 173, alpha), color(255, 214, 165, alpha), color(253, 255, 182, alpha), color(202, 255, 191, alpha), 
      color(155, 246, 255, alpha), color(160, 196, 256, alpha), color(189, 178, 255, alpha), color(255, 198, 255, alpha)
    };
    
    if (size < strokeWeight) {
      noStroke();
      fill(colors[n % colors.length]);
      circle(width/2, height/2, size + strokeWeight);
    } else {
      noFill();
      strokeWeight(strokeWeight);
      stroke(colors[n % colors.length]);
      circle(width/2, height/2, size);
    }
  }
}

void mousePressed() {
  ////movieFuk.jump(10);
  //if (speed > 0) {
  //  speed = -1.0;
  //} else {
  //  speed = 1.0;
  //}
  //movieFuk.speed(speed);
  //movieFuk.play();
  
  //println(movieFuk.time());
  //println(movieFuk.duration());
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
        house = int(60 * gain);
      } else {
        house = int(60);
      }
      break;
    case "supersaw":
      if (orbit == 3) {
        circleList.add(new Circle());
      }
      break;
    case "alice":
      if (n == 3) {
        movieFuk.play();
      }
      if (n == 4 && dropped == 0) {
        dropped = 1;
      }
      break;
    case "alicereverse":
      aliceReverse = 1;
      break;
    case "aliceagain":
      aliceReverse = 0;
      aliceAgain = 1;
      break;
    case "sn":
      dropped = 2;
      break;
    default:
      // TODO: do something simple for all other sounds?
  }
}
