

Movie[] movies = new Movie[10];
int curMovieIndex = -1;
float movieSpeed = 0.8;

float house = 0;
float jungbass = 0;
float yoff = 0;
float xincr = 0.1;


void setupProgress() {
  for (int i = 0; i < movies.length; i++) {
    movies[i] = new Movie(this, "blue" + str(i) + ".mp4");
    movies[i].volume(0);
  }
  
}

void drawProgress() {
  blendMode(BLEND);
  //for (Movie movie : movies) {
  //  if (movie.available()) {
  //    movie.read();
  //    // movie.speed(movieSpeed);
  //  }
  //}
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
  }
  
  blendMode(DIFFERENCE);
  noStroke();
  
  fill(house);
  rect(0, 0, width, height);
  
  //if (jungbass > 0) {
  //  color c = color(50 * jungbass/100, 0, 50 * jungbass/100);
  //  fill(c);
  //  perlinWave(width - jungbass/100 * width * 1.1, width * 1.1 - jungbass/100 * width);
  //}
  
  house = max(0, house - 1);
  jungbass = max(0, jungbass - 2);
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

void mousePressedProgress() {
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

void oscEventProgress(OscMessage m) {
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
        house = int(40 * gain);
      } else {
        house = int(40);
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
