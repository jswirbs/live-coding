import processing.video.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;

Movie movie;
float movieSpeed = 0.8;
float movieW;
float movieH;
float movieY;
PImage reverseXMovie;
PImage reverseYMovie;
PImage reverseXYMovie;

float kick = 0;


void setup() {
  // start oscP5, listening for incoming messages at port 3333
  oscP5 = new OscP5(this, 3333);

  //size(800, 450);
  fullScreen();
  background(0);
  frameRate(30);

  movie = new Movie(this, "forever.mp4");
  movie.volume(0.0);

  movieW = width/4;
  movieH = (1920.0 / 1280.0) * movieW;
  movieY = (((float) height)/2 - movieH);

  movie.loop();
}

void draw() {
  blendMode(BLEND);

  if (movie.available()) {
    if (movieSpeed > 0 && movie.time() > movie.duration() - 0.5) {
      movieSpeed = -0.8;
    } else if (movieSpeed < 0 && movie.time() < 0.5) {
      movieSpeed = 0.8;
    }
    movie.speed(movieSpeed);


    movie.read();


    reverseXMovie = getReverseXPImage(movie);
    reverseYMovie = getReverseYPImage(movie);
    reverseXYMovie = getReverseXPImage(reverseYMovie);

    for (int i = 0; i < 4; i++) {
      image(i % 2 == 0 ? movie : reverseXMovie, i * movieW, movieY, movieW, movieH);
      image(i % 2 == 0 ? reverseYMovie : reverseXYMovie, i * movieW, height / 2, movieW, movieH);
    }
  } else {
    println("unavailable!");
    resetMovie();
  }

  //blendMode(DIFFERENCE);
  //noStroke();

  //fill(kick);
  //rect(0, 0, width, height);

  //kick = max(0, kick - 4);
}

public PImage getReverseXPImage( PImage image ) {
  PImage reverse = new PImage( image.width, image.height );
  for ( int i=0; i < image.width; i++ ) {
    for (int j=0; j < image.height; j++) {
      reverse.set( image.width - 1 - i, j, image.get(i, j) );
    }
  }
  return reverse;
}

public PImage getReverseYPImage( PImage image ) {
  PImage reverse = new PImage( image.width, image.height );
  for (int j=0; j < image.height; j++) {
    for ( int i=0; i < image.width; i++ ) {
      reverse.set( i, image.height - 1 - j, image.get(i, j) );
    }
  }
  return reverse;
}

void resetMovie() {
  movie.stop();
  movie = new Movie(this, "forever.mp4");
  movie.volume(0.0);
  movieSpeed = 0.8;
  movie.speed(movieSpeed);
  movie.loop();
}

void mousePressed() {
  resetMovie();
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

  for (i = 0; i < m.typetag().length(); ++i) {
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
  case "ahhhh":
    //if (n == 10) {
    //  jungbass = 100;
    //}
    break;
  default:
    //if (s.contains("_kick")) {
    //  if (gain > 0) {
    //    kick = int(100 * gain);
    //  } else {
    //    kick = int(100);
    //  }
    //}
  }
}
