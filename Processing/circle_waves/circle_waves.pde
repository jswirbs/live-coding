
import oscP5.*;
import netP5.*;

OscP5 oscP5;

float theta = 0;
float thetaNegative = 0;
float thetaVelocity = 0.08;

float circleWidth = 100;
float numRings = 6; 
float ringDensity = 8;

void setup() {
  size(1280,500);
  //fullScreen();
  frameRate(30);
  // start oscP5, listening for incoming messages at port 3333
  oscP5 = new OscP5(this,3333);
}

void draw() {
  background(0);
  
  blendMode(DIFFERENCE);
  noStroke();
  
  // Translate the origin point to the center of the screen
  translate(width/2, height/2);
  
  //circle(0, 0, circleWidth);
  
  for (float i = 0; i < numRings; i++) {
    
    
    for (float j = 0; j < ringDensity; j++) {
      fill(i/numRings * 256, 0, 256 - i/numRings * 256);
      
      float r = height * 0.45 * i/numRings;
      //float r = height * 0.45 * sin(i/numRings * millis() * 0.001);
      
      // Convert polar to cartesian
      
      float x = r * cos((i*theta)/numRings + (2*PI*j/ringDensity));
      float y = r * sin((i*theta)/numRings + (2*PI*j/ringDensity));
      
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
    }
  }

  theta += thetaVelocity;
  thetaNegative -= thetaVelocity;
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
