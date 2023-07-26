
import oscP5.*;
import netP5.*;

OscP5 oscP5;

float cps = 0;
float cycle = 0;
boolean colorImgs = false;

PFont f;

boolean kickTrigger = false;
int kickN = 0;
//int kickDuration = 0;

int imgCount = 13;
PImage[] imgs = new PImage[imgCount];
int imgCounter = 0;

float r = random(256);
float g = random(256);
float b = random(256);

// String[] words = new String[]{"LUCY", "FERRY"};
String[] words = new String[]{"HARD", "CORE", "SOFT", "WARE"};
int wordAlpha = 256;
String word = "";


void setup() {
  //size(1300,700);
  fullScreen();
  frameRate(30);
  // start oscP5, listening for incoming messages at port 3333
  oscP5 = new OscP5(this,3333);
  
  for (int i = 0; i < imgCount; i++) {
    String fileName = Integer.toString(i);
    while (fileName.length() < 3) {
      fileName = "0" + fileName;
    }
    imgs[i] = loadImage(fileName + ".png");
  }
  
  //printArray(PFont.list());
  //f = createFont("Futura-Bold", 350);
  //f = createFont("PTMono-Bold", 400); // not full screen
  f = createFont("PTMono-Bold", 550); // full screen
  
  textFont(f);
}

void draw() {
  blendMode(BLEND);
  
  // Displays the image at its actual size at point (0,0)
  image(imgs[imgCounter], 0, 0, width, height);
  filter(INVERT);
  filter(POSTERIZE, 12);
  // Displays the image at point (0, height/2) at half of its size
  //image(img, 0, height/2, img.width/2, img.height/2);

  
  if (kickTrigger) {
    //kickDuration = 9;
    kickTrigger = false;
    
    imgCounter++;
    if (imgCounter >= imgCount) {
      imgCounter = 0;
    }
    
    r = random(256);
    g = random(256);
    b = random(256);
    
    if (kickN == 18) {
      wordAlpha = 256;
      int wordIndex = (int) ((cycle - (int) cycle) * 4);
      word = words[wordIndex];
    }
  }
  
  
  blendMode(DIFFERENCE);
  
  textAlign(CENTER);
  fill(r, g, b, wordAlpha);
  wordAlpha -= 7;
  text(word, width/2, height - height/3.5);
   
   
  if (colorImgs) {
    r = random(256);
    g = random(256);
    b = random(256);
    fill(r, g, b);
    rect(0, 0, width, height);
  }
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
  
  //switch(s) {
  //  case "color":
  //    if (n == 1) {
  //      colorActive = false;
  //    } else {
  //      colorActive = true;
  //    }
  //  case "house":
  //    if (gain > 0) {
  //      house = int(90 * gain);
  //    } else {
  //      house = int(90);
  //    }
  //    break;
  //  case "sn":
  //    sn = 20;
  //    break;
  //  default:
  //    // TODO: do something simple for all other sounds?
  //}
  

  if (s.contains("_kicks")) {
    kickTrigger = true;
    kickN = int(n);
  }
  if (s.contains("color")) {
    colorImgs = !colorImgs;
  }
  //if (s.contains("_hats") || s.contains("_hh")) {
  //  hh = height /2;
  //}
  //if (s.contains("_sn") || s.contains("_snare") || s.contains("_clap")) {
  //  sn = 20;
  //}
}
