/*
  TableCreatures
*/
import processing.opengl.*;
import processing.video.*;
import deadpixel.keystone.*;
import s373.flob.*;
import blobDetection.*;
import de.looksgood.ani.*;
import org.gicentre.utils.colour.*;
import ddf.minim.*;


// general variables
Config config;
int vWidth = 1024;
int vHeight = 768; 
int cWidth = 320;
int cHeight = 240;
int occupationDist = 30; 
int cInteractionDist = 30;
int randomDestDist = 10;

int fps = 60;
int camId = 0;
PFont font = createFont("monaspace", 20);
String camName = "USB 2.0 Camera";//"FaceTime HD-Kamera (integriert)"; //"USB 2.0 Camera";
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
Boolean mouseKlickSound = true;

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
  
  setupVideoCapture();
  setupFlob();
  setupBlobDetection();
  Ani.init(this);
  setupSound();
  setupTweets();
  
  
  /*
  // test creatures
  Creature c1 = new Creature(true, null, -1, false);
  c1.x = 350;
  c1.y = 350;
  c1.name = "c1";
  //c1.face.love();
  //c.col = color(200, 50, 200);
  creatures.add(c1);
  
  Creature c2 = new Creature(true, null, -1, true);
  c2.x = 400;
  c2.y = 400;
  c2.name = "c2";
  //creatures.add(c2);
  */
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
  //populateCreatures();


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

  if(config.debug && drawStats)
  {
    drawStats();
  }
  
  
  /*if(tweets.isAvailable())
  {
    for(int i = 0; i < tweets.tweets.size(); i++)
    {
      TweetsTweet t = (TweetsTweet) tweets.tweets.get(i);
      println(t.date + " wrote " + t.user + ": " + t.text);
    }
  }*/
  
  
  o.endDraw();
  background(0);
  surface.render(o);
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








