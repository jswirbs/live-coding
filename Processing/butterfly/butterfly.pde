import gab.opencv.*;
import processing.video.*;

Movie video;
OpenCV opencv;

void setup() {
  size(720, 480);
  video = new Movie(this, "someday720.mov");
  opencv = new OpenCV(this, 720, 480);
  
  opencv.startBackgroundSubtraction(5, 3, 0.5);
  
  video.loop();
  video.play();
}

void draw() {
  if (video.available()) {
    video.read();
    video.speed(0.2);
    
    image(video, 0, 0, width, height);  
    opencv.loadImage(video);
  }
  opencv.updateBackground();
  
  opencv.dilate();
  opencv.erode();

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);
  for (Contour contour : opencv.findContours()) {
    contour.draw();
  }
}

//void movieEvent(Movie m) {
//  m.read();
//}
