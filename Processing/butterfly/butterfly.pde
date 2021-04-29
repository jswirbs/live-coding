import processing.video.*;
import oscP5.*;
import netP5.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*;

OscP5 oscP5;

Movie[] movies = new Movie[10];
int curMovieIndex = -1;
float movieSpeed = 0.8;

Movie somedayMovie;

OpenCV opencv;

float house = 0;
float jungbass = 0;
float yoff = 0;
float xincr = 0.1;

int contourMode = 2;
int contourStroke = 1;


void setup() {
  // start oscP5, listening for incoming messages at port 3333
  oscP5 = new OscP5(this,3333);
  
  size(800, 450);
  background(0);
  frameRate(30);
  
  for (int i = 0; i < movies.length; i++) {
    movies[i] = new Movie(this, "blue" + str(i) + ".mp4");
    movies[i].volume(0);
  }
  
  opencv = new OpenCV(this, width, height);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  opencv.startBackgroundSubtraction(5, 3, 0.3);
  
  curMovieIndex = 2;
  movies[curMovieIndex].play();
    
  //somedayMovie = new Movie(this, "someday720.mp4");
  //somedayMovie.loop();
  //somedayMovie.play();
  
}

void draw() {
  blendMode(BLEND);
  if (curMovieIndex >= 0) {
    if (movies[curMovieIndex].available()) {
      movies[curMovieIndex].read();
      
      if (movieSpeed > 0 && movies[curMovieIndex].time() > movies[curMovieIndex].duration() - 0.5) {
        movieSpeed = -0.8;
      } else if (movieSpeed < 0 && movies[curMovieIndex].time() < movies[curMovieIndex].duration() * 0.75) {
        movieSpeed = 0.8;
      }
      movies[curMovieIndex].speed(movieSpeed);
    }
    
    image(movies[curMovieIndex], 0, 0, width, height);
    
    opencv.loadImage(movies[curMovieIndex]);
    image(opencv.getOutput(),0,0);
    drawContours();
    
    
  }
  
  //if (somedayMovie.available()) {
  //  somedayMovie.read();
  //  somedayMovie.speed(0.25);
  //}
  
  //image(somedayMovie, 0, 0, width, height);
  //opencv.loadImage(somedayMovie);
  //image(opencv.getSnapshot(),0,0);
  //image(opencv.getOutput(),0,0,width,height);
  
  
  //blendMode(DIFFERENCE);
  noStroke();
  
  fill(house);
  rect(0, 0, width, height);
  
  if (jungbass > 0) {
    color c = color(50 * jungbass/100, 0, (100 - 50 * jungbass/100) * jungbass/100);
    fill(c);
    perlinWave(width - jungbass/100 * width * 1.1, width * 1.1 - jungbass/100 * width);
  } else {
    jungbass = 100;
  }
  
  house = max(0, house - 1);
  jungbass = max(0, jungbass - 2);
}


void drawContours() {
  // normal contour with black background
  if (contourMode == 0) {
    background(0);
    blendMode(BLEND);
  // no background redraw
  } else if (contourMode == 1) {
    blendMode(BLEND);
  // no background redraw and difference (glitchier)
  } else if (contourMode == 2) {
    blendMode(DIFFERENCE);
  }
  
  opencv.updateBackground();
  
  opencv.dilate();
  opencv.erode();

  // noFill();
  float r = (sin(0.0007*millis()%(2*PI))+1)*128;
  float g = (sin(0.0007*millis()%(2*PI) + PI/3)+1)*128;
  float b = (sin(0.0007*millis()%(2*PI) + (2*PI)/3)+1)*128;
  if (contourStroke == 1) {
    strokeWeight(2);
    stroke(r, g, b);
  } else {
    noStroke();
  }
  fill(g, b, r);
  
  for (Contour contour : opencv.findContours()) {
    contour.draw();
  }
}

void perlinWave(float x1, float x2) {
  // We are going to draw a polygon out of the wave points
  beginShape(); 
  
  float xoff = 0;       // Option #1: 2D Noise
  // float xoff = yoff; // Option #2: 1D Noise
  
  // Iterate over vertical pixels
  for (float y = 0; y <= width; y += 10) {
    // Calculate a x value according to noise, map to 
    float x = map(noise(xoff, yoff), 0, 1, x1, x2); // width/4 - width/8, width/4 + width/8); // Option #1: 2D Noise
    // float y = map(noise(xoff), 0, 1, 200,300);    // Option #2: 1D Noise
    
    // Set the vertex
    vertex(x, y); 
    // Increment x dimension for noise
    // xoff += 0.05;
    xoff += xincr;
  }
  // increment y dimension for noise
  //yoff += 0.01;
  yoff += 0.05;
  vertex(0, height);
  vertex(0, 0);
  endShape(CLOSE);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    contourMode++;
    if (contourMode > 2) {
      contourMode = 0;
    }
  } else if (mouseButton == RIGHT) {
    if (contourStroke == 0) {
      contourStroke = 1;
    } else {
      contourStroke = 0;
    }
  }
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
  
  if (s.contains("blue")) {
    int index = Integer.parseInt(String.valueOf(s.charAt(4)));
    if (curMovieIndex < 0) { // curMovieIndex initialized at -1, so this is the case when the first video is played
      movies[index].play();
      curMovieIndex = index;
    } else if (index != curMovieIndex) {
      if (movies[curMovieIndex].available()) {
        movies[curMovieIndex].stop();
      }
      movies[index].jump(0);
      movies[index].play();
      curMovieIndex = index;
    }
  }
  
  switch(s) {
    case "house":
      if (gain > 0) {
        house = int(25 * gain);
      } else {
        house = int(25);
      }
      break;
    case "jungbass":
      if (n == 10) {
        jungbass = 100;
      }
      break;
    default:
      // TODO: do something simple for all other sounds?
  }
}
