/**
 * oscP5parsing by andreas schlegel
 * example shows how to parse incoming osc messages "by hand".
 * it is recommended to take a look at oscP5plug for an
 * alternative and more convenient way to parse messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

int width = 400;
int height = 400;

float cycle = 0;
int house = 0;
int hh = 0;
float m3 = 0;

void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,3333);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
}

void draw() {
  background(house); 
  
  noStroke();
  fill(100 + (cycle*10 % 150), 0, 220);
  ellipse(200, 200, m3, m3);
  
  // fill(100, 50, 150);
  noFill();
  stroke(150);
  rect(0, 0, hh, height);
  rect(400 - hh, 0, hh, height);
  
  
  if (house > 0) {
    house -= 10;
  }
  if (hh > 0) {
    hh -= 10;
  }
  if (m3 > 0) {
    m3 -= 6;
  }
}

void oscEvent(OscMessage m) {
  float t = millis();
  int i;
  
  float cps = -1;
  // float cycle = -1;
  float delta = -1;
  float gain = -1;
  int orbit = -1;
  String s = "";
  

  println("### received an osc message: "+m);
  
  println("### typetag: "+m.typetag());
  println("### typetag length: "+m.typetag().length());
  for(i = 0; i < m.typetag().length(); ++i) {
    String name = m.get(i).stringValue();
    println("### name: "+name);
    switch(name) {
      case "cps":
        cps = m.get(i+1).floatValue();
        break;
      case "cycle":
        cycle = m.get(i+1).floatValue();
        break;
      case "delta":
        delta = m.get(i+1).floatValue();
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
    }
    ++i;
  }
  println("### values: "+cps+", "+cycle+", "+delta+", "+gain+", "+orbit+", "+s);
  if (s.equals("house")) {
    println("HOUSEEEEE");
    house = 100;
  } else if (s.equals("hh") || s.equals("electro1")) {
    hh = width /2;
  } else if (s.equals("m3")) {
    m3 = 150;
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
