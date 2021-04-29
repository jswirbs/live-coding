/******************
Code by Vamoss
Original code link:
https://www.openprocessing.org/sketch/738638

Author links:
http://vamoss.com.br
http://twitter.com/vamoss
http://github.com/vamoss
******************/
import java.util.ArrayList;
import oscP5.*;
import netP5.*;

OscP5 oscP5;

ArrayList<Pos> posArr = new ArrayList<Pos>();
int backgroundColor = #1a0633;
int[] colors = new int[]{ #581845, #900C3F, #C70039, #FF5733, #FFC30F };
float moveSpeed = 1;
float moveScale = 800;

void setup() {
  size(1000, 500);
  background(backgroundColor);
  noStroke();
  
  oscP5 = new OscP5(this,3333);
  
  for(int i = 0; i < 300; i++){
    posArr.add(new Pos(random(width), random(height), floor(random(colors.length))));
  }
}

void draw() {
  for(int i = 0; i < posArr.size(); i++){
    Pos curPos = posArr.get(i);
    float angle = noise(curPos.x / moveScale, curPos.y / moveScale) * TWO_PI * moveScale;//I never understood why end by multiplying by moveScale
    curPos.x += cos(angle) * moveSpeed;
    curPos.y += sin(angle) * moveSpeed;
    fill(colors[curPos.cIndex]);
    ellipse(curPos.x, curPos.y, 2, 2);
    if(curPos.x > width || curPos.x < 0 || curPos.y > height || curPos.y < 0 || random(1) < 0.001 ){
      curPos.x = random(width);
      curPos.y = random(height);
    }
  }
}

class Pos {
  float x = -1;
  float y = -1;
  int cIndex = 0;
  
  public Pos(float x, float y, int cIndex) {
    this.x = x;
    this.y = y;
    this.cIndex = cIndex;
  }
}

void oscEvent(OscMessage m) {
  float t = millis();
  int i;
  
  float cps = -1;
  float cycle = -1;
  float delta = -1;
  float n = -1;
  float gain = -1;
  int orbit = -1;
  String s = "";
  

  //println("### received an osc message: "+m);
  for(i = 0; i < m.typetag().length(); ++i) {
    String name = m.get(i).stringValue();
    //print("### name: "+name);
    switch(name) {
      case "cps":
        cps = m.get(i+1).floatValue();
        //println(" > "+cps);
        break;
      case "cycle":
        cycle = m.get(i+1).floatValue();
        //println(" > "+cycle);
        break;
      case "delta":
        delta = m.get(i+1).floatValue();
        //println(" > "+delta);
        break;
      case "n":
        n = m.get(i+1).floatValue();
        //println(" > "+n);
        break;
      case "gain":
        gain = m.get(i+1).floatValue();
        //println(" > "+gain);
        break;
      case "orbit":
        orbit = m.get(i+1).intValue();
        //println(" > "+orbit);
        break;
      case "s":
        s = m.get(i+1).stringValue();
        //println(" > "+s);
        break;
      default:
        //println(" > DEFAULT");
        break;
    }
    ++i;
  }
  //println("### values: "+cps+", "+cycle+", "+delta+", "+gain+", "+orbit+", "+s);
  
  switch(s) {
    case "house":
      backgroundColor += floor(random(256));
      break;
    //case "sn":
    //  colors[floor(random(colors.length))] = floor(random(256));
      
    //case ("hh"):
    //  hh = height /2;
    //  break;
    //case ("electro1"):
    //  hh = height /2;
    //  break;
    //case "m1":
    //  m1 = 60;
    //  break;
    //case "m2":
    //  m2 = 60;
    //  break;
    //case "m3":
    //  m3 = 60;
    //  break;
    //case "m4":
    //  m4 = 60;
    //  break;
    //case ("superzow"):
    //  superzow = 4;
    //  break;
    //case ("superpiano"):
    //  superzow = 4;
    //  break;
    //case ("sn"):
    //  sn = 20;
    //  break;
    //case "nasty":
    //  nasty = 200;
    //  break;
    //case "kyle":
    //  xincr = 0.07;
    //  break;
    // default:
      // do something simple for all other sounds
  }
}
