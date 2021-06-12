
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
      
      // normal opaque (glitchy w DIFFERENCE)
      //int circleAlpha = 256; 
      // transparent circles (blendy everywhere w DIFFERENCE)
      //int circleAlpha = 60; 
      // somewhere in the middle
      int circleAlpha = 150; 
      fill(i/numRings * 64 + 192 * sin(millis()*0.0005 + PI), 100 - i/numRings * 50, 256 - i/numRings * 64, circleAlpha);

      
      // fixed r
      //float r = height * 0.45 * i/numRings;
      // oscillating r
      float r = height * 0.45 * sin(i/numRings * millis() * 0.001);
      
      // Convert polar to cartesian
      
      // all rotating the same direction
      float x = r * cos((i*theta)/numRings + (2*PI*j/ringDensity));
      float y = r * sin((i*theta)/numRings + (2*PI*j/ringDensity));
      
      // alternating reverse rotation
      //float x;
      //float y;
      //if (i % 2 == 0) {
      //  x = r * cos((i*theta)/numRings + (2*PI*j/ringDensity));
      //  y = r * sin((i*theta)/numRings + (2*PI*j/ringDensity));
      //} else { 
      //  x = r * cos((i*thetaNegative)/numRings + (2*PI*j/ringDensity));
      //  y = r * sin((i*thetaNegative)/numRings + (2*PI*j/ringDensity));
      //}
      
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
  // scale the inverse of the scale above to keep it still
  scale(1.1/(2.2 + 1.5*sin(millis()*0.0005)*0.9));
  image(movementSymbol, -movementSymbolSize/2.0, -movementSymbolSize/2.0, movementSymbolSize, movementSymbolSize);
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
    
    default:
      // TODO: do something simple for all other sounds?
  }
}
