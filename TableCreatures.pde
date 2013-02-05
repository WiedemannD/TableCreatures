/*
  TableCreatures
*/
import processing.opengl.*;
import processing.video.*;
//import deadpixel.keystone.*; // included all files into code directory to make adjustments
import s373.flob.*;
import blobDetection.*;
import de.looksgood.ani.*;
import org.gicentre.utils.colour.*;
import ddf.minim.*;


// general variables
Config config;
int vWidth = 1280;//1024;
int vHeight = 1024;//768; 
int cWidth = 320;//640; //320; // set to higher resolution by heavy zoom --> hit on performance
int cHeight = 240;//480; //240; // set to higher resolution by heavy zoom --> hit on performance
int occupationDist = 30; 
int cInteractionDist = 30;
int randomDestDist = 10;
int moveAroundDist = 50;

int fps = 60;
int camId = 0;
PFont font = createFont("monaspace", 20);
PFont font2;
String[] camNames = {"USB 2.0 Camera", "FaceTime HD-Kamera (integriert)"}; //"USB 2.0 Camera";
Capture video;
PImage videoinput;
PImage videoinputBD;
PImage backgroundImage;
PImage savedBackgroundImage;

// debug variables
//Boolean debug = true; // has been replaced with config.debug
Boolean printCamNames = false;
Boolean drawVideoCapture = true;
Boolean drawFlobs = false;
Boolean drawTrackedObjects = false;
Boolean drawStats = true;
Boolean mouseKlickSound = false;
Boolean populateCreatures = false;
int generalCalibration = -1;

// keystone vars
Keystone ks;
CornerPinSurface surface;
PGraphics o; // offset view to draw to

// blob detection variables (Flob and BlobDetection)
Flob flob;
BlobDetection blobDetection;
ArrayList flobs = new ArrayList();

// sound/minim
Minim minim;

// various vars
ArrayList trackedObjects;
ArrayList creatures = new ArrayList();
ArrayList groundEffects = new ArrayList();
Tweets tweets;

/////////////////////
// setup
/////////////////////

void setup(){
  size(vWidth, vHeight, OPENGL);
  frameRate(fps);
  
  setupKeystone();
  
  config = new Config(this);
  
  if(config.debug && printCamNames)
  {
    printCamNames();
  }

  font2 = loadFont("Menlo-Bold-20.vlw");  
  setupVideoCapture();
  setupFlob();
  setupBlobDetection();
  Ani.init(this);
  setupSound();
  setupTweets();
  
  
  
  // test creatures
  Creature c1 = new Creature(true, null, 1, false);
  c1.x = 200;
  c1.y = vHeight / 2;
  c1.name = "c1";
  //c1.randomDest = new PVector(vWidth, vHeight / 2);
  //c1.face.love();
  //c.col = color(200, 50, 200);
  creatures.add(c1);
  
  
  Creature c2 = new Creature(true, null, 1, false);
  c2.x = 800;
  c2.y = vHeight / 2;
  c2.name = "c2";
  creatures.add(c2);
  
}


/////////////////////
// drawing
/////////////////////

void draw(){
  PVector surfaceMouse = surface.getTransformedMouse();
  
  o.beginDraw();
  o.background(0);
  
  
  
  if(video.available()) 
  {
    processNewFrame();
  }

  
  setTrackedObjects();
  populateCreatures();


  if(config.debug && drawVideoCapture)
  {
    o.image(flob.getSrcImage(), 0, 0, width, height);
  }

  
  drawGroundEffects();
  drawCreatures();


  if(config.debug && drawFlobs)
  {
    drawFlobs();
    drawBlobsAndEdges(true,true);
  }

  if(config.debug && drawTrackedObjects)
  {
    drawTrackedObjects(true, true, true);
  }

  
  o.endDraw();
  background(0);
  surface.render(o);
  
  if(config.debug && drawStats)
  {
    drawStats();
  }
  
}


/////////////////////
// quit/stop (seems depricated)
// for minim audio lib
/////////////////////

void quit()
{
    // always stop Minim before exiting.
    minim.stop();
    tweets.quit();
        
    super.stop();
}








