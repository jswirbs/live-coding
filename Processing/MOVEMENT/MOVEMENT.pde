import processing.video.*;
import java.util.concurrent.CopyOnWriteArrayList;
import gab.opencv.*;
import java.awt.*;
import java.util.Random;
import oscP5.*;
import netP5.*;

OscP5 oscP5;

int phase = 0;


void setup() {
  size(1280,500);
  //fullScreen();
  frameRate(30);
  // start oscP5, listening for incoming messages at port 3333
  oscP5 = new OscP5(this,3333);
  
  background(0);
  
  setupCircleWaves();
  setup303();
  // setupWebcam(); // maybe??
  setupHotelAlexandria();
  // that song I dreamt??
  setupProgress();
  // outro
  
}

void draw() {
  if (phase == 0) {
    drawCircleWaves();
  } else if (phase == 1) {
    draw303();
    if (webcamInitialized) {
      uninitializeWebcam();
      webcamInitialized = false;
    }
  } else if (phase == 2) {
    drawWebcam(); // maybe??
  } else if (phase == 3) {
    drawHotelAlexandria();
    if (webcamInitialized) {
      uninitializeWebcam();
      webcamInitialized = false;
    }
  } else if (phase == 4) {
    // that song I dreamt??
  } else if (phase == 5) {
    //drawProgress();
  } else if (phase == 6) {
    // outro
  }
}


void mouseClicked() {
  // transition between phases
  if ((mouseX > width - 20) && (mouseY < 20)) {
    if (mouseButton == LEFT) {
      phase += 1; 
      if (phase > 6) {
        phase = 0;
      }
    } else if (mouseButton == RIGHT) {
      phase -= 1;
      if (phase < 0) {
        phase = 6;
      }
    }
  // otherwise, call the current phases mouseClicked function
  } else {
  
    if (phase == 0) {
      mouseClickedCircleWaves();
    } else if (phase == 1) {
      //draw303();
    } else if (phase == 2) {
      mouseClickedWebcam(); // maybe??
    } else if (phase == 3) {
      //drawHotelAlexandria();
    } else if (phase == 4) {
      // that song I dreamt??
    } else if (phase == 5) {
      //drawProgress();
    } else if (phase == 6) {
      // outro
    }
    
  }
}


void oscEvent(OscMessage m) {
  if (phase == 0) {
    // oscEventCircleWaves();
  } else if (phase == 1) {
    oscEvent303(m);
  } else if (phase == 2) {
    // oscEventWebcam(m); // maybe??
  } else if (phase == 3) {
    oscEventHotelAlexandria(m);
  } else if (phase == 4) {
    // that song I dreamt??
  } else if (phase == 5) {
    oscEventProgress(m);
  } else if (phase == 6) {
    // outro
  }
}
