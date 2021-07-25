
import oscP5.*;
import netP5.*;

OscP5 oscP5;

float scale = 0.5;

float theta = 0;
float thetaNegative = 0;
float thetaVelocity = 0.05;

float circleWidth = 100;
float numRings = 6; 
float ringDensity = 3;

PImage movementSymbol;
int movementSymbolSize = 320;

int mode = 0;
float shift = 0;
float shiftDelta = 0.002;


void setup() {
  size(1280,500);
  //fullScreen();
  frameRate(30);
  // start oscP5, listening for incoming messages at port 3333
  oscP5 = new OscP5(this,3333);
  
  movementSymbol = loadImage("movementSymbol.png");
  
  background(0);
}

void draw() {
  // blurred motion on black
  //blendMode(BLEND); 
  // glitchy difference
  blendMode(DIFFERENCE); 
  
  noStroke();
  // doesn't do anything with black background and DIFFERENCE blendMode
  fill(0, 0, 0, 20);
  rect(0, 0, width, height);
  
  // Translate the origin point to the center of the screen
  translate(width/2, height/2);
  
  // glitchy af scaling
  //scale(4*sin(millis()*0.05));  
  // normal scaling
  scale(2.2 + 1.5*sin(millis()*0.0005));
  
  
  for (float i = 0; i < numRings; i++) {
    for (float j = 0; j < ringDensity; j++) {
      // density of center point is always 1
      if (i == 0 && j > 0) {
        continue;
      }
      
      //fill(i/numRings * 256, 0, 256 - i/numRings * 256);
      //fill(i/numRings * 256, 0, 256 - j/ringDensity * 256);
      //fill(128 + 128 * sin(millis()*0.0005), 0, 128 + 128 * sin(millis()*0.0005 + PI));
      //fill(i/numRings * 128 + 64 * sin(millis()*0.0005), 0, 256 - i/numRings * 128);
      
      
      // MODE 0
      // blendy w DIFFERENCE
      int circleAlpha = 100;
      // color
      fill(i/numRings * 64 + 192 * sin(millis()*0.0005 + PI), 100 - i/numRings * 50, 256 - i/numRings * 64, circleAlpha);
      if (mode == 1) {
        // glitchy w DIFFERENCE
        circleAlpha = 256; 
        // more vibrant color
        fill((i/numRings * 64 + 192 * sin(millis()*0.05 + PI)) * 0.7, (100 - i/numRings * 50) * 0.7, (256 - i/numRings * 64) * 0.7, circleAlpha);
      } else if (mode == 2) {
        // blendy w DIFFERENCE
        circleAlpha = 100;
        // color
        fill(
          (256 - (256 - i/numRings * 64))/2 + (i/numRings * 64 + 128 * sin(millis()*0.0005 + PI))/2, 
          i/numRings * 64 + 128 * sin(millis()*0.0005 + PI), 
          125 - i/numRings * 50, 
          circleAlpha
        );
      } else if (mode == 3) {
        // glitchy w DIFFERENCE
        circleAlpha = 256; 
        // more vibrant color
        fill(
          ((256 - (256 - i/numRings * 64))/2 + (i/numRings * 64 + 128 * sin(millis()*0.0005 + PI))/2) * 0.7, 
          (i/numRings * 64 + 128 * sin(millis()*0.05 + PI)) * 0.7, 
          (125 - i/numRings * 50) * 0.7, 
          circleAlpha
        );
      } else if (mode == 4 || mode == 5) {
        blendMode(BLEND); 
        float r = 200 + random(50);
        float g = 200 + random(50);
        float b = 200 + random(50);
        fill(max(r - shift, 0), max(g - shift, 0), max(b - shift, 0), circleAlpha);
        shift += shiftDelta;
      }
      

      
      // fixed r
      //float r = height * 0.45 * i/numRings;
      // oscillating r
      float r = height * 0.45 * sin(i/numRings * millis() * 0.001);
      
      // Convert polar to cartesian
      
      // MODE 0 || MODE 2
      // all rotating the same direction
      float x = r * cos((i*theta)/numRings + (2*PI*j/ringDensity));
      float y = r * sin((i*theta)/numRings + (2*PI*j/ringDensity));
      if (mode == 1 || mode == 3) {
        // alternating reverse rotation
        if (i % 2 == 0) {
          x = r * cos((i*theta)/numRings + (2*PI*j/ringDensity));
          y = r * sin((i*theta)/numRings + (2*PI*j/ringDensity));
        } else { 
          x = r * cos((i*thetaNegative)/numRings + (2*PI*j/ringDensity));
          y = r * sin((i*thetaNegative)/numRings + (2*PI*j/ringDensity));
        }
      }
      
      circle(x, y, circleWidth * (i + numRings*0.8)/(numRings + numRings*0.8));
      // make center circle twice as big
      //if (i == 0) {
      //  circle(x, y, circleWidth * 2 * (i + numRings*0.8)/(numRings + numRings*0.8));
      //} else {
      //  circle(x, y, circleWidth * (i + numRings*0.8)/(numRings + numRings*0.8));
      //}
    }
  }

  theta += thetaVelocity;
  thetaNegative -= thetaVelocity;
  
  blendMode(BLEND); 
  
  if (mode == 5) {
    
  } else {
    // scale the inverse of the scale above to keep it still
    scale(1.1/(2.2 + 1.5*sin(millis()*0.0005)*0.9));
    image(movementSymbol, -movementSymbolSize/2.0, -movementSymbolSize/2.0, movementSymbolSize, movementSymbolSize);
  }
}


void mouseClicked() {
  if (mouseButton == LEFT) {
    ringDensity = 3;
    if (mode == 0) {
      mode = 1;
    } else {
      mode = 0;
    }
    
    if (key == CODED && keyCode == SHIFT) {
      shift = 0;
      shiftDelta = 0.002;
      mode = 4;
    }
  } else if (mouseButton == RIGHT) {
    ringDensity = 5;
    if (mode == 3) {
      mode = 2;
    } else {
      mode = 3;
    }
    
    if (key == CODED && keyCode == SHIFT) {
      shift = 0;
      shiftDelta = 0.01;
      mode = 5;
    }
  } 
}




//void oscEvent(OscMessage m) {
//  float t = millis();
//  int i;
  
//  float cps = -1;
//  float cycle = -1;
//  float n = -1;
//  float gain = -1;
//  int orbit = -1;
//  String s = "";
//  float distort = -1;
  
//  for(i = 0; i < m.typetag().length(); ++i) {
//    String name = m.get(i).stringValue();
//    switch(name) {
//      case "cps":
//        cps = m.get(i+1).floatValue();
//        break;
//      case "cycle":
//        cycle = m.get(i+1).floatValue();
//        break;
//      case "n":
//        n = m.get(i+1).floatValue();
//        break;
//      case "gain":
//        gain = m.get(i+1).floatValue();
//        break;
//      case "orbit":
//        orbit = m.get(i+1).intValue();
//        break;
//      case "s":
//        s = m.get(i+1).stringValue();
//        break;
//      case "distort":
//        distort = m.get(i+1).floatValue();
//      default:
//        break;
//    }
//    ++i;
//  }
  
//  switch(s) {
    
//    default:
//      // TODO: do something simple for all other sounds?
//  }
//}
