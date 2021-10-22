
import oscP5.*;
import netP5.*;

OscP5 oscP5;

Background background;
int bd = 0;

NastyWaves nastyWaves;

void setup() {
  size(1280,500);
  //fullScreen();
  frameRate(30);
  // start oscP5, listening for incoming messages at port 3333
  oscP5 = new OscP5(this,3333);
  
  background = new Background();
  nastyWaves = new NastyWaves();
}

void draw() {
  blendMode(BLEND);
  
  background.draw();
  
  nastyWaves.draw();
  
  filter();
}


public class Background {
  color[] colors = new color[]{color(0,200,255), color(255,0,0)};
  int count;
  int slide;
  
  public Background() {
    count = 0;
    slide = 0;
  }
  
  public void draw() {
    background(colors[count % 2]);
    
    if (slide > 0) {
      noStroke();
      fill(colors[(count + 1) % 2]);
      rect(width - slide, 0, slide, height);
      slide -= width/30;
    }
  }
  
  public void trigger() {
    count++;
    slide = width;
  }
}

// filter bassed on bd (making it birghter at each hit)
void filter() {
  blendMode(DIFFERENCE);
  noStroke();
  fill(200 + bd/2);
  rect(0, 0, width, height);
  
  bd = max(0, bd - 10);
}


public class NastyWaves {
  int nastii;
  float nasty;
  int nastier;
  float nastyLeft1;
  float nastyLeft2;
  float nastyRight1;
  float nastyRight2;
  float xincr;
  float yoff;
  
  public NastyWaves() {
    nastii = 0;
    nasty = 0;
    nastier = 0;
    nastyLeft1 = 0;
    nastyLeft2 = 0;
    nastyRight1 = width;
    nastyRight2 = width;
    xincr = 0.02;
    yoff = 0;
  }
  
  void enable() {
    nastii = (nastii + 1) % 2;
  }
  
  boolean enabled() {
    return nastii == 1;
  }
  
  void enableColor() {
    nastier = (nastier + 1) % 2;
  }
  
  void trigger() {
    nasty = 200;
  }
  
  void draw() {
    blendMode(DIFFERENCE);
    
    if (nasty > 0) {
      nastyLeft1 = min(nastyLeft1 + 0.5, width/7);
      nastyLeft2 = min(nastyLeft2 + 1, width/4);
      nastyRight1 = max(nastyRight1 - 0.5, width - width/7);
      nastyRight2 = max(nastyRight2 - 1, width - width/4);
      if (nastier == 0) {
        perlinWaveLeft(color(nasty), nastyLeft1, nastyLeft2);
        perlinWaveRight(color(nasty), nastyRight1, nastyRight2);
      } else {
        float rLeft = (sin(0.002*millis()%(2*PI))+1)*128 * (nasty/200);
        float gLeft = (sin(0.002*millis()%(2*PI) + PI/3)+1)*128 * (nasty/200);
        float bLeft = (sin(0.002*millis()%(2*PI) + (2*PI)/3)+1)*128 * (nasty/200);
        float rRight = (256 - (sin(0.002*millis()%(2*PI))+1)*128) * (nasty/200);
        float gRight = (256 - (sin(0.002*millis()%(2*PI) + PI/3)+1)*128) * (nasty/200);
        float bRight = (256 - (sin(0.002*millis()%(2*PI) + (2*PI)/3)+1)*128) * (nasty/200);
        perlinWaveLeft(color(rLeft, gLeft, bLeft), nastyLeft1*3, nastyLeft2*3);
        perlinWaveRight(color(rRight, gRight, bRight), nastyRight1 - nastyLeft1, nastyRight2 - nastyLeft2);
      }
      nasty = max(nasty - 1, 0);
    } else {
      nastyLeft1 = 0;
      nastyLeft2 = 0;
      nastyRight1 = width;
      nastyRight2 = width;
    }
    
    xincr = max(xincr - 0.007, 0.02);
  }
  
  void perlinWaveLeft(color c, float x1, float x2) {
    //// fill2(c);
    fill(c);
    stroke(min(256, c+20));
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
    yoff += 0.01;
    vertex(0, height);
    vertex(0, 0);
    endShape(CLOSE);
  }
  
  void perlinWaveRight(color c, float x1, float x2) {
    //// fill2(c);
    fill(c);
    stroke(min(256, c+20));
    beginShape(); 
    
    float xoff = 0;
    for (float y = 0; y <= width; y += 10) {
      float x = map(noise(xoff, yoff), 0, 1, x1, x2); // width - (width/4 - width/8), width - (width/4 + width/8)); // Option #1: 2D Noise
      vertex(x, y); 
      xoff += xincr;
    }
    yoff += 0.01;
    vertex(width, height);
    vertex(width, 0);
    endShape(CLOSE);
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
  
  switch(s) {
    case "SOPHIE_textures":
      print(n);
      if (n <= 0) {
        background.trigger();
      }
      break;
    case "nastii":  // enables nasty waves to start
      nastyWaves.enable();
      break;
    case "cyberpunk":
      if (nastyWaves.enabled() && (n == 3 || n == 4)) {
        nastyWaves.trigger();
      }
      break;
    case "nastier":  // turns nasty waves to color 
      nastyWaves.enableColor();
      break;
    default:
      if (s.contains("SOPHIE_kicks") || s == "SOPHIE_subs") {
        bd = 100;
      }
  }
}
