/* 
audio input or midi input to f w shit

openprocessing facial blur w sound: https://openprocessing.org/sketch/1065532
openprocessing sound shit: https://openprocessing.org/sketch/959525
*/

import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import java.util.Random;

Capture video;
OpenCV opencv;

float scale = 3;

/* 0: face blur
 * 1: contours
 * 2: xray
 * 3: tiled face
 * 4: sobel
 */
int mode = 1;

int contourMode = 0;
int contourStroke = 1;


void setup() {
  //size(640, 480);
  size(1000, 750);
  height = int(height/scale);
  width = int(width/scale);
  
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
      
    video = new Capture(this, width, height, cameras[0]);
    opencv = new OpenCV(this, width, height);
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
    
    video.start();
  }
  
  //opencv.startBackgroundSubtraction(5, 3, 0.5);
  opencv.startBackgroundSubtraction(5, 3, 0.3);
}

void draw() {
  scale(scale);
  opencv.loadImage(video);
  
  // F W BRIGHTNESS
  opencv.brightness(0); // (int)map(mouseX, 0, width, -255, 255));

  if (mode == 0) {
    drawFaceBlur();
    
  } else if (mode == 1) {
    drawContours();
    
  } else if (mode == 2) {
    drawXray();
    
  } else if (mode == 3) {
    drawTiledFace();
    
  } else if (mode == 4) {
    drawSobel();
    
  }
}


void drawSobel() {
  float blend = (sin(0.003*millis()%(2*PI))+1);
  if (blend > 1) {
    //tint(256, 0, 0);
    blendMode(ADD);
  } else {
    //tint(230, 0, 200);
    blendMode(SUBTRACT);
  }
  opencv.findSobelEdges(1,0);
  image(opencv.getSnapshot(),0,0);
  noTint();
}


void drawTiledFace() {
  opencv.useColor(HSB);
  PImage s = opencv.getSnapshot(opencv.getS()); 
  
  Rectangle[] faces = opencv.detect();
    
  // could maybe do faces array like drawFaceBlur() and just add chunks to array of length (chunkDim*chunkDim*numFaces)
  // then get a grid of mutliple faces mixed in
  if (faces.length > 0) {
    image(s, 0, 0);
    //image(opencv.getOutput(),0,0);
    
    int chunkDim = 8;
    PImage[] faceChunks = new PImage[chunkDim*chunkDim];
    
    for (int j = 0; j < chunkDim; j++) {
      for (int k = 0; k < chunkDim; k++) {
        int x = ceil(faces[0].x + ceil(faces[0].width * j/chunkDim));
        int y = ceil(faces[0].y + ceil(faces[0].height * k/chunkDim));
        
        PImage faceChunk = get(int(x*scale), int(y*scale), ceil(faces[0].width/chunkDim * 4*scale) + 1, ceil(faces[0].height/chunkDim * 4*scale) + 1);
        faceChunks[j*chunkDim+k] = faceChunk;
      }
    }
    
    // shuffle array
    int index; 
    PImage temp;
    Random random = new Random(2); // use random seed so order stays same
    for (int j = faceChunks.length - 1; j > 0; j--)
    {
      index = random.nextInt(j + 1);
      temp = faceChunks[index];
      faceChunks[index] = faceChunks[j];
      faceChunks[j] = temp;
    }
    
    for (int j = 0; j < chunkDim; j++) {
      for (int k = 0; k < chunkDim; k++) {
        int x = ceil(j * width/chunkDim);
        int y = ceil(k * height/chunkDim);
        PImage curChunk = faceChunks[j*chunkDim+k];
        
        if ((j + k) % 4 == 0) {
          tint(0, 200, 160);
        } else if ((j + k) % 4 == 1) {
          tint(200, 20, 244);
        } else if ((j + k) % 4 == 2) {
          tint(180, 220, 0);
        } else if ((j + k) % 4 == 3) {
          tint(200, 200, 200);
        }
        
        image(curChunk, x, y, ceil((width/chunkDim)) + 1, ceil((height/chunkDim)) + 1);
        noTint();
      }
    }
  } else {
    background(0);
  }
  // SHUFFLE FACE TILES ONTOP OF FACE
  //for (int i = 0; i < faces.length; i++) {
    
  //  int chunkDim = 4;
  //  PImage[] faceChunks = new PImage[chunkDim*chunkDim];
    
  //  for (int j = 0; j < chunkDim; j++) {
  //    for (int k = 0; k < chunkDim; k++) {
  //      int x = ceil(faces[i].x + ceil(faces[i].width * j/chunkDim));
  //      int y = ceil(faces[i].y + ceil(faces[i].height * k/chunkDim));
        
  //      PImage faceChunk = get(int(x*scale), int(y*scale), ceil(faces[i].width/chunkDim)*2 + 1, ceil(faces[i].height/chunkDim)*2 + 1);
  //      faceChunks[j*chunkDim+k] = faceChunk;
  //    }
  //  }
    
  //  // shuffle array
  //  int index; 
  //  PImage temp;
  //  Random random = new Random(2); // use random seed so order stays same
  //  for (int j = faceChunks.length - 1; j > 0; j--)
  //  {
  //    index = random.nextInt(j + 1);
  //    temp = faceChunks[index];
  //    faceChunks[index] = faceChunks[j];
  //    faceChunks[j] = temp;
  //  }
    
  //  for (int j = 0; j < chunkDim; j++) {
  //    for (int k = 0; k < chunkDim; k++) {
  //      int x = ceil(faces[i].x + ceil(faces[i].width * j/chunkDim));
  //      int y = ceil(faces[i].y + ceil(faces[i].height * k/chunkDim));
        
  //      image(faceChunks[j*chunkDim+k], x, y, ceil(faces[i].width/chunkDim) + 1, ceil(faces[i].height/chunkDim) + 1);
  //    }
  //  }
  //}
}


void drawXray() {
  // PImage r = opencv.getSnapshot(opencv.getR());
  // PImage g = opencv.getSnapshot(opencv.getG());
  // PImage b = opencv.getSnapshot(opencv.getB());  
  
  opencv.useColor(HSB);
  // PImage h = opencv.getSnapshot(opencv.getH());
  PImage s = opencv.getSnapshot(opencv.getS());  
  // PImage v = opencv.getSnapshot(opencv.getV());
  
  image(s, 0, 0);
}


void mouseClicked() {
  if (mouseButton == LEFT) {
    contourMode++;
    if (contourMode > 3) {
      contourMode = 0;
    }
  } else if (mouseButton == RIGHT) {
    println("RIGHT");
    if (contourStroke == 0) {
      contourStroke = 1;
    } else {
      contourStroke = 0;
    }
  }
}


void drawContours() {
  // normal contour with black background
  if (contourMode == 0) {
    background(0);
    blendMode(BLEND);
  // no background redraw
  } else if (contourMode == 1) {
    blendMode(BLEND);
  // no background redraw and difference (glitchier)
  } else if (contourMode == 2) {
    blendMode(DIFFERENCE);
  } else if (contourMode == 3) {
    drawFaceBlur();
    blendMode(DIFFERENCE);
  }
  
  
  opencv.updateBackground();
  
  opencv.dilate();
  opencv.erode();

  // noFill();
  float r = (sin(0.0007*millis()%(2*PI))+1)*128;
  float g = (sin(0.0007*millis()%(2*PI) + PI/3)+1)*128;
  float b = (sin(0.0007*millis()%(2*PI) + (2*PI)/3)+1)*128;
  if (contourStroke == 1) {
    strokeWeight(2);
    stroke(r, g, b);
  } else {
    noStroke();
  }
  fill(g, b, r);
  
  for (Contour contour : opencv.findContours()) {
    contour.draw();
  }
}

// DIFFERENT SQUARES REACT TO DIFFERENT SOUNDS THROUGH COLOR OR SOMETHING
void drawFaceBlur() {
  // xray w face blur
  //opencv.useColor(HSB);
  //PImage s = opencv.getSnapshot(opencv.getS()); 
  //image(s, 0, 0);
  //image(video, 0, 0);
  noStroke();
  image(opencv.getOutput(),0,0);
  Rectangle[] faces = opencv.detect();
    
  for (int i = 0; i < faces.length; i++) {
    
    int blurSize = 6;
    for (int j = 0; j < blurSize; j++) {
      for (int k = 0; k < blurSize; k++) {
        int x = ceil(faces[i].x + ceil(faces[i].width * j/blurSize));
        int y = ceil(faces[i].y + ceil(faces[i].height * k/blurSize));
        
        PImage blur = get(int(x*scale), int(y*scale), ceil(faces[i].width/blurSize) + 1, ceil(faces[i].height/blurSize) + 1);
        int r = 0, g = 0, b = 0;
        for (int l=0; l < blur.pixels.length; l++) {
            color c = blur.pixels[l];
            r += c>>16&0xFF;
            g += c>>8&0xFF;
            b += c&0xFF;
        }
        r /= blur.pixels.length;
        g /= blur.pixels.length;
        b /= blur.pixels.length;
     
        fill(r, g, b);
        rect(x, y, ceil(faces[i].width/blurSize) + 1, ceil(faces[i].height/blurSize) + 1);
      }
    }
  }
}


void captureEvent(Capture c) {
  c.read();
}
