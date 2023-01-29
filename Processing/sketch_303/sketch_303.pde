
import oscP5.*;
import netP5.*;

OscP5 oscP5;

int[] haromColors = new int[]{0, 36, 72, 108, 144, 180, 216, 242};
int haromDepth = 7;
float rectSize = 30; 
float superzowSize = 40;
float superzowX = -superzowSize;
float superzowY = -superzowSize;
float yoff = 0;

float cps = 0;
float cycle = 0;
boolean colorActive = true;
float house = 0;
float hh = 0;
float m1 = 0;
float m2 = 0;
float m3 = 0;
float m4 = 0;
float m5 = 0;
float m6 = 0;
float superzow = 0;
float sn = 0;
float nasty = 0;
int nastier = 0;
float nastyLeft1 = 0;
float nastyLeft2 = 0;
float nastyRight1 = width;
float nastyRight2 = width;
float xincr = 0.02;
float print = 0;
int printColor = 0;
float scifi = 0;
float scifi2 = 0;
float scifiMultiplier = 0; 
float radio = 0;

void setup() {
  size(1300,400);
  //fullScreen();
  frameRate(30);
  // start oscP5, listening for incoming messages at port 3333
  oscP5 = new OscP5(this,3333);
}

void draw() {
  blendMode(BLEND);
  background(house); 
  
  // harom triangle
  strokeWeight(2);
  stroke(150);
  harom(width/2+height/2.75 + sn, height-height/3.5 + sn/sqrt(3), width/2-height/2.75 - sn, height-height/3.5 + sn/sqrt(3), haromDepth, (sin(0.0005*millis()%(2*PI))+1)/2);
  // harom(width/2+height/2.75 + sn, height-height/3.5 + sn/sqrt(3), width/2-height/2.75 - sn, height-height/3.5 + sn/sqrt(3), haromDepth, (sin(cycle%(2*PI))+1)/2);
  
  blendMode(DIFFERENCE);
  
  drawTriangles();
  
  drawMidi();
  
  drawRects();
  
  drawSuperzow();
  
  drawNasty();
  
  drawStatic();
  
  
  // update values
  house = max(house - 10, 0);
  hh = max(hh - 10, 0);
  m1 = max(m1 - 2.3, 0);
  m2 = max(m2 - 2, 0);
  m3 = max(m3 - 1.7, 0);
  m4 = max(m4 - 1.4, 0);
  m5 = max(m5 - 1.2, 0);
  m6 = max(m6 - 1, 0);
  sn = max(sn - 2, 0);
  xincr = max(xincr - 0.007, 0.02);
  print = max(print - 1, 0);
  scifiMultiplier = max(scifiMultiplier - 0.015, 0);
}


void drawStatic() {
  float rand = random(10);
  if (radio > 0) {
    noStroke();
    for (int i = 0; i < 2000; i++) {
      float x = random(width);
      float y = random(height);
      float w = random(2, 10);
      float h = random(2, 10);
      
      float r = (sin(0.01*x%(2*PI))+1)*128;
      float g = (sin(0.01*x%(2*PI))+1 + PI/3)*128;
      float b = (sin(0.01*x%(2*PI))+1 + 2*PI/3)*128;
      if (i % 4 == 0) {  
        fill2(0, g, b);
      } else if (i % 4 == 1) {
        fill2(r, 0, g);
      } else { // twice as likely
        fill2(255, 255, 255);
      }
      rect(x, y, w, h);
    }
    radio = max(radio - 0.068, 0);
  }
}


void drawNasty() {
  if (nasty > 0) {
    nastyLeft1 = min(nastyLeft1 + 0.5, width/5);
    nastyLeft2 = min(nastyLeft2 + 1, width/3);
    nastyRight1 = max(nastyRight1 - 0.5, width - width/5);
    nastyRight2 = max(nastyRight2 - 1, width - width/3);
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
      perlinWaveLeft(color(rLeft, gLeft, bLeft), nastyLeft1*2, nastyLeft2*2);
      perlinWaveRight(color(rRight, gRight, bRight), nastyRight1 - nastyLeft1, nastyRight2 - nastyLeft2);
    }
    nasty = max(nasty - 1, 0);
  } else {
    nastyLeft1 = 0;
    nastyLeft2 = 0;
    nastyRight1 = width;
    nastyRight2 = width;
  }
}


void drawSuperzow() {
  // superzow random dots blinking with gradual color gradient
  if (superzow > 0) {
    if (superzow == 3) {
      superzowX = random(width);
      superzowY = random(height);
    }
    noStroke();
    float r = (sin(0.001*millis()%(2*PI))+1)*128;
    float g = (sin(0.001*millis()%(2*PI) + PI/3)+1)*128;
    float b = (sin(0.001*millis()%(2*PI) + (2*PI)/3)+1)*128;
    fill2(r, g, b);
    ellipse(superzowX, superzowY, superzowSize * superzow/2, superzowSize * superzow/2);
    superzow = max(superzow - 1, 0);
  }
}


void drawMidi() {
  noStroke();
  
  fill2(256, 0, 0);
  ellipse(width/2, height/2, m1 * (min(width, height)/85), m1 * (min(width, height)/85));
  
  fill2(0, 256, 0);
  ellipse(width/2, height/2, m2 * (min(width, height)/85), m2 * (min(width, height)/85));
  
  fill2(0, 0, 256);
  ellipse(width/2, height/2, m3 * (min(width, height)/85), m3 * (min(width, height)/85));
  
  fill2(256, 40, 120);
  ellipse(width/2, height/2, m4 * (min(width, height)/85), m4 * (min(width, height)/85));
  //strokeWeight(10);
  //stroke(256, 40, 120);
  //noFill();
  //ellipse(width/2, height/2, m4 * (min(width, height)/85), m4 * (min(width, height)/85));
  //noStroke();
  //strokeWeight(10);
  
  fill2(0, 250, 200);
  ellipse(width/2, height/2, m5 * (min(width, height)/85), m5 * (min(width, height)/85));
  
  fill2(150, 256, 40);
  ellipse(width/2, height/2, m6 * (min(width, height)/85), m6 * (min(width, height)/85));
}

void drawTriangles() {
  noStroke();
  
  float ax1 = width/2+height/2.75 + sn;
  float ay1 = height-height/3.5 + sn/sqrt(3);
  float bx1 = width/2;
  float by1 = height-height/3.5 + sn/sqrt(3);
  float vx1=bx1-ax1;
  float vy1=by1-ay1;
  float nx1=cos(PI/3)*vx1-sin(PI/3)*vy1; 
  float ny1=sin(PI/3)*vx1+cos(PI/3)*vy1; 
  float cx1=ax1+nx1;
  float cy1=ay1+ny1;
  
  float ax2 = width/2;
  float ay2 = height-height/3.5 + sn/sqrt(3);
  float bx2 = width/2-height/2.75 - sn;
  float by2 = height-height/3.5 + sn/sqrt(3);
  float vx2=bx2-ax2;
  float vy2=by2-ay2;
  float nx2=cos(PI/3)*vx2-sin(PI/3)*vy2; 
  float ny2=sin(PI/3)*vx2+cos(PI/3)*vy2; 
  float cx2=ax2+nx2;
  float cy2=ay2+ny2;
  
  
  float ax3 = cx1;
  float ay3 = cy1;
  float bx3 = cx2;
  float by3 = cy2;
  float vx3=bx3-ax3;
  float vy3=by3-ay3;
  float nx3=cos(PI/3)*vx3-sin(PI/3)*vy3; 
  float ny3=sin(PI/3)*vx3+cos(PI/3)*vy3; 
  float cx3=ax3+nx3;
  float cy3=ay3+ny3;
  
  int[] triangleColors = new int[] { 
    color((scifiMultiplier) * (sin(0.001*millis()%(2*PI))+1)*128, 0, (scifiMultiplier) * (256 - (sin(0.001*millis()%(2*PI))+1)*128)), 
    color((scifiMultiplier) * (256 - (sin(0.001*millis()%(2*PI))+1)*128), (scifiMultiplier) * (sin(0.001*millis()%(2*PI))+1)*128, 0),
    color(0, (scifiMultiplier) * (256 - (sin(0.001*millis()%(2*PI))+1)*128), (scifiMultiplier) * (sin(0.001*millis()%(2*PI))+1)*128)
  };
  
  if (scifi2 + 1 > cycle) {
    fill2(triangleColors[floor(cycle)%3]);
    triangle(
      ax1, 
      ay1, 
      bx2*(1-scifiMultiplier) + ax1*scifiMultiplier, 
      by2*(1-scifiMultiplier) + ay1*scifiMultiplier, 
      cx3*(1-scifiMultiplier) + ax1*scifiMultiplier, 
      cy3*(1-scifiMultiplier) + ay1*scifiMultiplier
    );
    fill2(triangleColors[(floor(cycle)%3+1)%3]);
    triangle(
      ax1*(1-scifiMultiplier) + cx3*scifiMultiplier, 
      ay2*(1-scifiMultiplier) + cy3*scifiMultiplier, 
      bx2*(1-scifiMultiplier) + cx3*scifiMultiplier, 
      by2*(1-scifiMultiplier) + cy3*scifiMultiplier, 
      cx3, 
      cy3
    );
    fill2(triangleColors[(floor(cycle)%3+2)%3]);
    triangle(
      ax1*(1-scifiMultiplier) + bx2*scifiMultiplier, 
      ay2*(1-scifiMultiplier) + by2*scifiMultiplier, 
      bx2, 
      by2,
      cx3*(1-scifiMultiplier) + bx2*scifiMultiplier, 
      cy3*(1-scifiMultiplier) + by2*scifiMultiplier
    );
  } else {
    if (floor(cycle)%3 == 0) {
      fill2(triangleColors[floor(cycle)%3]);
      triangle(
        ax1, 
        ay1, 
        bx2*(1-scifiMultiplier) + ax1*scifiMultiplier, 
        by2*(1-scifiMultiplier) + ay1*scifiMultiplier, 
        cx3*(1-scifiMultiplier) + ax1*scifiMultiplier, 
        cy3*(1-scifiMultiplier) + ay1*scifiMultiplier
      );
    } else if (floor(cycle)%3 == 1) {
      fill2(triangleColors[(floor(cycle)%3+1)%3]);
      triangle(
        ax1*(1-scifiMultiplier) + cx3*scifiMultiplier, 
        ay2*(1-scifiMultiplier) + cy3*scifiMultiplier, 
        bx2*(1-scifiMultiplier) + cx3*scifiMultiplier, 
        by2*(1-scifiMultiplier) + cy3*scifiMultiplier, 
        cx3, 
        cy3
      );
    } else if (floor(cycle)%3 == 2) {
      fill2(triangleColors[(floor(cycle)%3+2)%3]);
      triangle(
        ax1*(1-scifiMultiplier) + bx2*scifiMultiplier, 
        ay2*(1-scifiMultiplier) + by2*scifiMultiplier, 
        bx2, 
        by2,
        cx3*(1-scifiMultiplier) + bx2*scifiMultiplier, 
        cy3*(1-scifiMultiplier) + by2*scifiMultiplier
      );
    }
  }
}

float convertGreyscale(float r, float g, float b) {
  return (0.299*r + 0.587*g + 0.114*b);
}
void fill2(color c) {
  if (colorActive) {
    fill(c);
  } else {
    float r = red(c);
    float g = green(c);
    float b = blue(c);
    fill(convertGreyscale(r, g, b));
  }
}
void fill2(float c) {
  if (colorActive) {
    fill(c);
  } else {
    float r = red(int(c));
    float g = green(int(c));
    float b = blue(int(c));
    fill(convertGreyscale(r, g, b));
  }
}
void fill2(float r, float g, float b) {
  if (colorActive) {
    fill(r, g, b);
  } else {
    fill(convertGreyscale(r, g, b));
  }
}

void drawRects() {
  strokeWeight(2);
  if (print > 0) {
    fill2(printColor);
    stroke(200);
  } else if (radio > 0) {
    fill2(220);
  } else {
    noFill();
    stroke(175);
  }
  
  rect(
    min(height/4 - hh/2, height/4 - rectSize/2), 
    min(height/2 - hh, height/2 - rectSize/2), 
    max(width/2 * hh/(height/2), rectSize), 
    max(hh*2, rectSize)
  );
  rect(
    min(width - (height/4 - hh/2 + (width/2 + rectSize/2) * hh/(height/2)) + rectSize/2, width - height/4 - rectSize/2), 
    min(height/2 - hh, height/2 - rectSize/2), 
    max(width/2 * hh/(height/2), rectSize),
    max(hh*2, rectSize)
  );
}

// helper function for harom distortion
// based off of linear regression + existing p5.map function
float logMap(float value, float start1, float stop1, float start2, float stop2) {
  start2 = log(start2);
  stop2 = log(stop2);
  return exp(start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1)));
}


void harom(float ax, float ay, float bx, float by, int level, float ratio) {
  if(level!=0){
    float vx,vy,nx,ny,cx,cy;
    vx=bx-ax;
    vy=by-ay;
    nx=cos(PI/3)*vx-sin(PI/3)*vy; 
    ny=sin(PI/3)*vx+cos(PI/3)*vy; 
    cx=ax+nx;
    cy=ay+ny;

    // on snare, we add layers of distortion to largest triangle (three R, G, B layers of randomly shifted triangles)
    if (sn > 0 && level == haromDepth) {
    
      for (int i = 0; i < 3; i++) {
        blendMode(ADD);
        noStroke();
        // offset g a little so distorted triangles look more centered
        float g = sn - random(sn*3);
        
        if (i == 0) {
          fill2(haromColors[level], 0, 0);
        } else if (i == 1) {
          fill2(0, haromColors[level], 0);
        } else if (i == 2) {
          fill2(0, 0, haromColors[level]);
        }
        
        beginShape();
        float bias = dist(width/2, height/2, ax, ay);
        float dx = 1000;
        float dy = 1000;
        vertex(ax + dx / logMap(bias, width, 0, dx, 45) + g, ay + dy / logMap(bias, height, 0, dy, 45) + g);
        bias = dist(width/2, height/2, bx, by);
        dx = 1200;
        dy = 1500;
        vertex(bx + dx / logMap(bias, width, 0, dx, 45) + g, by + dy / logMap(bias, height, 0, dy, 45) + g);
        bias = dist(width/2, height/2, cx, cy);
        dx = 2000;
        dy = 1700;
        vertex(cx + dx / logMap(bias, width, 0, dx, 45) + g, cy + dy / logMap(bias, height, 0, dy, 45) + g);
        //vertex(30, 75);
        endShape(CLOSE);
      }
    }
    
    blendMode(BLEND);
    strokeWeight(2);
    stroke(150);
    fill2(haromColors[level]);
    beginShape();
    vertex(ax, ay);
    vertex(bx, by);
    vertex(cx, cy);
    //vertex(30, 75);
    endShape(CLOSE);
    
    harom(ax*ratio+cx*(1-ratio),ay*ratio+cy*(1-ratio),ax*(1-ratio)+bx*ratio,ay*(1-ratio)+by*ratio,level-1,ratio);
  }
}

void perlinWaveLeft(color c, float x1, float x2) {
  fill2(c);
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
  fill2(c);
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


void oscEvent(OscMessage m) {
  float t = millis();
  int i;
  
  // float cps = -1;
  // float cycle = -1;
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
    case "color":
      if (n == 1) {
        colorActive = false;
      } else {
        colorActive = true;
      }
    case "house":
      if (gain > 0) {
        house = int(90 * gain);
      } else {
        house = int(90);
      }
      break;
    case "sn":
      sn = 20;
      break;
    case "electro1":
      hh = height /2;
      break;
    case "808":
      hh = height /2;
      break;
    case "m1":
      m1 = 60;
      break;
    case "m2":
      m2 = 60;
      break;
    case "m3":
      m3 = 60;
      break;
    case "m4":
      m4 = 60;
      break;
    case "m5":
      m5 = 60;
      break;
    case "m6":
      m6 = 60;
      break;
    case "supersaw":
      if (orbit == 1) {
        m5 = 60;
      } else if (orbit == 2) {
        m4 = 60;
      } else if (orbit == 3) {
        m2 = 60;
      } else {
        m1 = 60;
      }
      break;
    case "superzow":
      if (gain >= 0) {
        superzowSize = 40 * gain;
      }
      superzow = 4;
      break;
    case "default":
      if (gain >= 0) {
        superzowSize = 40 * gain;
      }
      superzow = 4;
      break;
    case "superhammond":
      m1 = 60;
      break;
    case "superpiano":
      superzow = 4;
      break;
    case "nasty":
      nasty = 200;
      break;
    case "nastier":
      if (nastier == 0) {
        nastier = 1;
      } else {
        nastier = 0;
      }
      break;
    case "choir":
      nasty = 200;
      break;
    case "kyle":
      xincr = 0.07;
      break;
    case "print":
      print = 16;
      int[] printColors = new int[] { #ffadad, #ffd6a5, #fdffb6, #caffbf, #9bf6ff, #a0c4ff, #bdb2ff, #ffc6ff };
      printColor = printColors[floor(random(printColors.length))];
      if(distort > 0) {
        hh = min(hh + 30 * (distort/2+1), width/2);
      } else {
        hh = min(hh + 30, width/2);
      }
      break;
    case "scifi":
      scifi = cycle;
      scifiMultiplier = 1;
      break;
    case "scifi2":
      scifi2 = cycle;
      scifiMultiplier = 1;
      break;
    case "tvradio":
      radio = 1;
      break;
    case "SOPHIE_textures":   // 140
      if (gain < 0) {
        gain = 1;
      }
      
      if (n % 3 == 1) {
        m1 = 60 * gain;
      } else if (n % 3 == 2) {
        m2 = 60 * gain;
      } else {
        m3 = 90 * gain;
      }
      break;
    case "cyberpunk": // 140
      if (n == 3 || n == 4) {
        nasty = 200;
      }
      break;
    default:
      // TODO: do something simple for all other sounds?
  }
  
  // substring check for 140
  if (s.contains("SOPHIE_kicks")) {
    if (gain > 0) {
      house = int(90 * gain);
    } else {
      house = int(90);
    }
  }
  if (s.contains("_hats") || s.contains("_hihats") || s.contains("_hh")) {
    hh = height /2;
  }
  if (s.contains("_sn") || s.contains("_snare") || s.contains("_clap")) {
    sn = 20;
  }
}


//void oscEvent(OscMessage theOscMessage) {
//  /* check if theOscMessage has the address pattern we are looking for. */
  
//  //if(theOscMessage.checkAddrPattern("/test")==true) {
//    /* check if the typetag is the right one. */
//    if(theOscMessage.checkTypetag("ifs")) {
//      /* parse theOscMessage and extract the values from the osc message arguments. */
//      int firstValue = theOscMessage.get(0).intValue();  
//      float secondValue = theOscMessage.get(1).floatValue();
//      String thirdValue = theOscMessage.get(2).stringValue();
//      print("### received an osc message /test with typetag ifs.");
//      println(" values: "+firstValue+", "+secondValue+", "+thirdValue);
//      return;
//    }  
//  //} 
//  println("~~~~~~~~");
//  println("### received an osc message: "+theOscMessage);
//  println(" addrpattern: "+theOscMessage.addrPattern());
//  println(" typetag: "+theOscMessage.typetag());
//  println(" 0: "+theOscMessage.get(0).intValue());
//  println(" 1: "+theOscMessage.get(1).intValue());
//  println(" 2: "+theOscMessage.get(2).stringValue());
//}
