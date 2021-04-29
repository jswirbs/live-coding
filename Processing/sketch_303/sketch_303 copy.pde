
import oscP5.*;
import netP5.*;

OscP5 oscP5;

//int width = 1000;
//int height = 500;

int[] haromColors = new int[]{0, 36, 72, 108, 144, 180, 216, 242};

float cycle = 0;
int house = 0;
int hh = 0;
float m1 = 0;
float m2 = 0;
float m3 = 0;
float m4 = 0;

void setup() {
  size(1200,700);
  //fullScreen();
  
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 3333 */
  oscP5 = new OscP5(this,3333);

}

void draw() {
  blendMode(BLEND);
  background(house); 
  
  harom(width/2+height/2.75, height-height/3.5, width/2-height/2.75, height-height/3.5, 7, (sin(0.0005*millis()%(2*PI))+1)/2);
  
  blendMode(DIFFERENCE);
  
  noStroke();
  fill(256, 0, 0);
  ellipse(width/2, height/2, m1 * (min(width, height)/100), m1 * (min(width, height)/100));

  fill(0, 256, 0);
  ellipse(width/2, height/2, m2 * (min(width, height)/100), m2 * (min(width, height)/100));
  
  fill(0, 0, 256);
  ellipse(width/2, height/2, m3 * (min(width, height)/100), m3 * (min(width, height)/100));
  
  fill(200, 0, 256);
  ellipse(width/2, height/2, m3 * (min(width, height)/100), m3 * (min(width, height)/100));
  
  
  // fill(100, 50, 150);
  noFill();
  strokeWeight(2);
  stroke(150);
  //rect(0, 0, hh, height);
  //rect(width - hh, 0, hh, height);
  rect(height/4 - hh/2, height/2 - hh, max(width/2 * hh/(height/2), 10), max(hh*2, 10));
  rect(width - (height/4 - hh/2 + width/2 * hh/(height/2)), height/2 - hh, max(width/2 * hh/(height/2), 10), max(hh*2, 10));
  
  if (house > 0) {
    house = max(house - 10, 0);
  }
  if (hh > 0) {
    hh = max(hh - 10, 0);
  }
  if (m1 > 0) {
    m1 = max(m1 - 2.3, 0);
  }
  if (m2 > 0) {
    m2 = max(m2 - 2, 0);
  }
  if (m3 > 0) {
    m3 = max(m3 - 1.7, 0);
  }
  if (m4 > 0) {
    m4 = max(m4 - 1.4, 0);
  }
}

void harom(float ax, float ay,float bx, float by, int level,float ratio) {
  if(level!=0){
    float vx,vy,nx,ny,cx,cy;
    vx=bx-ax;
    vy=by-ay;
    nx=cos(PI/3)*vx-sin(PI/3)*vy; 
    ny=sin(PI/3)*vx+cos(PI/3)*vy; 
    cx=ax+nx;
    cy=ay+ny;
    //line(ax,ay,bx,by);
    //line(ax,ay,cx,cy);
    //line(cx,cy,bx,by);
    //fill(ax%256, (ay+bx)%256, by);
    blendMode(BLEND);
    //fill(20 * level, 128 - 20 * level, 256 - 20 * level);
    fill(haromColors[level]);
    beginShape();
    vertex(ax, ay);
    vertex(bx, by);
    vertex(cx, cy);
    //vertex(30, 75);
    endShape(CLOSE);
    
    harom(ax*ratio+cx*(1-ratio),ay*ratio+cy*(1-ratio),ax*(1-ratio)+bx*ratio,ay*(1-ratio)+by*ratio,level-1,ratio);
  }
}


void oscEvent(OscMessage m) {
  float t = millis();
  int i;
  
  float cps = -1;
  // float cycle = -1;
  float delta = -1;
  float n = -1;
  float gain = -1;
  int orbit = -1;
  String s = "";
  

  println("### received an osc message: "+m);
  
  println("### typetag: "+m.typetag());
  println("### typetag length: "+m.typetag().length());
  for(i = 0; i < m.typetag().length(); ++i) {
    String name = m.get(i).stringValue();
    print("### name: "+name);
    switch(name) {
      case "cps":
        cps = m.get(i+1).floatValue();
        println(" > "+cps);
        break;
      case "cycle":
        cycle = m.get(i+1).floatValue();
        println(" > "+cycle);
        break;
      case "delta":
        delta = m.get(i+1).floatValue();
        println(" > "+delta);
        break;
      case "n":
        n = m.get(i+1).floatValue();
        println(" > "+n);
        break;
      case "gain":
        gain = m.get(i+1).floatValue();
        println(" > "+gain);
        break;
      case "orbit":
        orbit = m.get(i+1).intValue();
        println(" > "+orbit);
        break;
      case "s":
        s = m.get(i+1).stringValue();
        println(" > "+s);
        break;
      default:
        println(" > DEFAULT");
        break;
    }
    ++i;
  }
  println("### values: "+cps+", "+cycle+", "+delta+", "+gain+", "+orbit+", "+s);
  
  switch(s) {
    case "house":
      if (gain > 0) {
        house = int(90 * gain);
      } else {
        house = int(90);
      }
      break;
    case ("hh"):
      hh = height /2;
      break;
    case ("electro1"):
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
  }
  //if (s.equals("house")) {
  //  house = 100;
  //  if (gain >= 0) {
  //    house = int(90 * gain);
  //  }
  //  println("HOUSEEE "+house);
  //} else if (s.equals("hh") || s.equals("electro1")) {
  //  hh = width /2;
  //} else if (s.equals("m3")) {
  //  m3 = 40;
  //}
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
