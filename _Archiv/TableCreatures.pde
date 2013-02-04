/*
  TableCreatures
*/
import processing.opengl.*;
import processing.video.*;
import deadpixel.keystone.*;
import s373.flob.*;
import blobDetection.*;

// general variables
Config config;
int vWidth = 1024;
int vHeight = 768; 
int cWidth = 320;
int cHeight = 240;
int creatureExcess = 3;

int fps = 60;
int camId = 0;
PFont font = createFont("monaspace", 10);
String camName = "USB 2.0 Camera";//"FaceTime HD-Kamera (integriert)"; //"USB 2.0 Camera";
Capture video;
PImage videoinput;
PImage videoinputBD;
PImage backgroundImage;
PImage savedBackgroundImage;

// debug variables
Boolean debug = true;
Boolean printCamNames = false;
Boolean drawVideoCapture = true;
Boolean drawFlobs = false;
Boolean drawTrackedObjects = true;
Boolean drawStats = true;

// keystone vars
Keystone ks;
CornerPinSurface surface;
PGraphics o; // offset view to draw to

// blob detection variables (Flob and BlobDetection)
Flob flob;
BlobDetection blobDetection;
ArrayList flobs = new ArrayList();

// various vars
ArrayList trackedObjects;
ArrayList creatures = new ArrayList();

/////////////////////
// setup
/////////////////////

void setup(){
  size(vWidth, vHeight, OPENGL);
  smooth();
  frameRate(fps);
  rectMode(CENTER);
  textFont(font);
  
  setupKeystone();
  config = new Config();
  
  if(debug && printCamNames)
  {
    printCamNames();
  }
  
  setupVideoCapture();
  setupFlob();
  setupBlobDetection();
  
  // test creature
  Creature c = new Creature(true);
  //c.x = 200;
  //c.y = 100;
  //c.col = color(200, 50, 200);
  creatures.add(c);
}


/////////////////////
// drawing
/////////////////////

void draw(){
  PVector surfaceMouse = surface.getTransformedMouse();
  o.beginDraw();
  
  
  
  
  if(video.available()) 
  {
    processNewFrame();
  }
  
  setTrackedObjects();

  if(debug && drawVideoCapture)
  {
    o.image(flob.getSrcImage(), 0, 0, width, height);
  }

  drawCreatures();

  if(debug && drawFlobs)
  {
    drawFlobs();
    drawBlobsAndEdges(true,true);
  }

  if(debug && drawTrackedObjects)
  {
    drawTrackedObjects(true, true, true);
  }

  if(debug && drawStats)
  {
    drawStats();
  }
  
  
  
  
  o.endDraw();
  background(0);
  surface.render(o);
}




