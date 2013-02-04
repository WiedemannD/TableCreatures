import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.opengl.*; 
import processing.video.*; 
import deadpixel.keystone.*; 
import s373.flob.*; 
import blobDetection.*; 
import de.looksgood.ani.*; 
import org.gicentre.utils.colour.*; 
import ddf.minim.*; 
import java.lang.reflect.Field; 
import java.lang.reflect.Method; 
import java.util.Date; 
import java.text.SimpleDateFormat; 
import java.text.ParseException; 
import twitter4j.conf.*; 
import twitter4j.internal.async.*; 
import twitter4j.internal.org.json.*; 
import twitter4j.internal.logging.*; 
import twitter4j.json.*; 
import twitter4j.internal.util.*; 
import twitter4j.management.*; 
import twitter4j.auth.*; 
import twitter4j.api.*; 
import twitter4j.util.*; 
import twitter4j.internal.http.*; 
import twitter4j.*; 
import twitter4j.internal.json.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TableCreatures extends PApplet {

/*
  TableCreatures
*/










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

public void setup(){
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

public void draw(){
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

public void quit()
{
    // always stop Minim before exiting.
    minim.stop();
    tweets.quit();
        
    super.stop();
}








class BodyPart
{
  int type = 0;
  float x, y, w, h, rot;
  int col;
  
  BodyPart(int t, float posX, float posY, float oWidth, float oHeight, float rotation, int oColor)
  {
    type = t;
    x = posX;
    y = posY;
    w = oWidth;
    h = oHeight;
    rot = rotation;
    col = oColor;
  }
  
  public void draw()
  {
    o.pushStyle();
      o.rectMode(CENTER);
      o.noStroke();
      o.fill(col);
      
      switch(type)
      {
        case 0: // rectangle
          o.rect(x, y, w, h);
          break;
      }
    
    o.popStyle();
  }
}
class Config
{
  ///////////////
  // to add config vars: edit varCount and varNames, add var, edit functions save and load (yeah I know this sucks ...)
  ///////////////
  
  int varCount = 10;
  String[] varNames = {"tresh", "fade", "om", "videores", "videotex", "trackedBlobLifetime", "edgeTresh", "posDiscrimination", "debug", "creatureExcess"};
  
  // Flob vars
  int tresh = 32;
  int fade = 25;
  int om = 0;
  int videores = 128;
  int videotex = 0;//3
  int trackedBlobLifetime = 5;
  
  // BlobDetection vars
  float edgeTresh = 0.35f;
  Boolean posDiscrimination = true;
  
  // general vars
  Boolean debug;
  int creatureExcess;
  
  // objects for general use
  PApplet main;
  PImage heartOutline;
  PImage type_1;
  
  Config(PApplet m)
  {
    main = m;
    load();
    ks.load();
    
    heartOutline = loadImage("data/heartOutline.png");
    type_1 = loadImage("data/type_1.png");
  }
  
  
  public void save()
  {
     String[] varsToSave = new String[varCount];
     
     varsToSave[0] = varNames[0] + " = " + tresh;
     varsToSave[1] = varNames[1] + " = " + fade;
     varsToSave[2] = varNames[2] + " = " + om;
     varsToSave[3] = varNames[3] + " = " + videores;
     varsToSave[4] = varNames[4] + " = " + videotex;
     varsToSave[5] = varNames[5] + " = " + trackedBlobLifetime;
     varsToSave[6] = varNames[6] + " = " + edgeTresh;
     varsToSave[7] = varNames[7] + " = " + posDiscrimination;
     varsToSave[8] = varNames[8] + " = " + debug;
     varsToSave[9] = varNames[9] + " = " + creatureExcess;
     
     saveStrings("data/config.txt", varsToSave);
     
     backgroundImage.save(savePath("data/backgroundImage.tif"));
     //backgroundImage.save("data/backgroundImage.tif");
     
     println("config saved");
  }
  
  public void load()
  {
    backgroundImage = loadImage("data/backgroundImage.tif");
    
    String[] varsLoaded = loadStrings("data/config.txt");
    
    tresh =                 Integer.parseInt(getSavedValue(varsLoaded[0]));
    fade =                  Integer.parseInt(getSavedValue(varsLoaded[1]));
    om =                    Integer.parseInt(getSavedValue(varsLoaded[2]));
    videores =              Integer.parseInt(getSavedValue(varsLoaded[3]));
    videotex =              Integer.parseInt(getSavedValue(varsLoaded[4]));
    trackedBlobLifetime =   Integer.parseInt(getSavedValue(varsLoaded[5]));
    edgeTresh =             PApplet.parseFloat(getSavedValue(varsLoaded[6]));
    posDiscrimination =     PApplet.parseBoolean(getSavedValue(varsLoaded[7]));
    debug =                 PApplet.parseBoolean(getSavedValue(varsLoaded[8]));
    creatureExcess =        Integer.parseInt(getSavedValue(varsLoaded[9]));
  }
  
  public String getSavedValue(String str)
  {
    str = str.substring(str.indexOf(" ") + 3, str.length());
    return str;
  }
  
  public void reset()
  {
  
  }
}


class Creature
{
  int addSpace = 150; 
  float scale = 1.0f;
  float speed = 1.0f; // general creature speed factor
  int unitSize = 10;
  float lerpMove = 0.1f;
  float lerpRot = 0.05f;
  float cInteractionTime = 4.0f;
  float dyingTime = 1.5f;
  float timer = 0;
  float matingPossibility = 0.5f; // second parameter of random(-1, matingPossibility);
  int typeCount = 0;

  float x, y, indiSpeed; // position, rotation and individual creature type speed
  float rot = 0;
  String name;
  int col;
  ColourTable cTable;
  int type = 0;
  Face face;
  Boolean dying = false;
  Boolean bodyPartsMoving = true;
  Boolean drawBodyParts = true;
  ArrayList bodyParts;
  ArrayList anis = new ArrayList(); 
  
  Boolean growing = false;
  float growingTime = 18.0f;
  Ani growingAni;
  Boolean occupying = false;
  Boolean cInteracting = false;
  int cInteraction = 0;
  Boolean cInteractionDominant = true;
  int cInteractionEnd;
  Ani cInteractionAni;
  float intAniX = 0;
  float intAniY = 0;
  float intRot = 0;
  Creature linkedCreature;
  PVector randomDest;
  Boolean movingAway = false;


  Creature(Boolean autoRandom, ColourTable cT, int t, Boolean cGrowing)
  {
    bodyParts = new ArrayList();
    cInteractionAni = new Ani(this, 0, "intAniX", 0); // just to init the ani as a blank ani
    
    growing = cGrowing;
    
    if (autoRandom)
    {
      x = random(0 - addSpace, width + addSpace);
      float tb = random(-1, 1);
      if (tb < 0)
      {
        y = 0 - addSpace;
      }
      else
      {
        y = height + addSpace;
      }
      
      if(cT != null)
      {
        cTable = cT;
      }
      else
      {
        cTable = new ColourTable();
        cTable.addContinuousColourRule(0.0f, PApplet.parseInt(random(255)), PApplet.parseInt(random(255)), PApplet.parseInt(random(255)));
        cTable.addContinuousColourRule(1.0f, PApplet.parseInt(random(255)), PApplet.parseInt(random(255)), PApplet.parseInt(random(255)));
      }
      
      
      if(t != -1)
      {
        type = t;
      }
      else
      {
        type = PApplet.parseInt(random(0, typeCount));
      }
      
      switch(type)
      {
      case 0: // eating worm
        indiSpeed = 1.0f;

        col = cTable.findColour(random(0, 1));

        bodyParts.add(new BodyPart(0, 0, unitSize, unitSize * 3, unitSize * 3, 0, col));
        bodyParts.add(new BodyPart(0, unitSize * 2, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));
        bodyParts.add(new BodyPart(0, unitSize * 3, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));
        bodyParts.add(new BodyPart(0, unitSize * 4, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));
        bodyParts.add(new BodyPart(0, unitSize * 5, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));

        float aniTime = 0.8f; 
        float delay = 0.15f;
        float movement = (unitSize * 2) - 5;

        Ani ani1 = new Ani(bodyParts.get(1), aniTime, "y", movement, Ani.LINEAR);
        anis.add(ani1);
        Ani ani2 = new Ani(bodyParts.get(2), aniTime - delay, delay, "y", movement, Ani.LINEAR);
        anis.add(ani2);
        Ani ani3 = new Ani(bodyParts.get(3), aniTime - (delay * 2), delay * 2, "y", movement, Ani.LINEAR);
        anis.add(ani3);
        Ani ani4 = new Ani(bodyParts.get(4), aniTime - (delay * 3), delay * 3, "y", movement, Ani.LINEAR);
        anis.add(ani4);

        for (int i = 0; i < anis.size(); i++)
        {
          Ani ani = (Ani) anis.get(i);

          ani.setPlayMode(Ani.YOYO);
          ani.repeat();
        }


        break;
      }

      face = new Face(0, 0, col);
    }
  }

  public void draw()
  {
    updateTransform();

    o.pushMatrix();
      o.translate(x, y);
      o.rotate(rot);
      o.translate(intAniX, intAniY);
      o.rotate(intRot);
      o.scale(scale);
      
      if (!occupying)
      {
        transformFace(null);
        drawBodyParts = true;
      }
  
      if (drawBodyParts)
      {
        for (int i = 0; i < bodyParts.size(); i++)
        {
          BodyPart bP = (BodyPart) bodyParts.get(i);
          bP.draw();
        }
      }
  
      face.draw();
    
    o.popMatrix();
  }

  public void updateTransform()
  {
    PVector c, d, step;

    ////////////////
    // position
    ////////////////

    float lastDist = -1;
    float currentDist = 10000;
    float destX = 0;
    float destY = 0;
    int action = -1;
    TrackedObject destTO = new TrackedObject(null, null, 0, 0, 0, 0, false);
    Creature destC = new Creature(false, null, -1, false);
    
    
    ////////////////
    // GROWING UP
    // just grow
    ////////////////
    if(growing)
    {
      action = 5;
    }
    ////////////////
    // ADULT
    // do something with your power
    ////////////////
    else
    {
      for (int i = 0; i < trackedObjects.size(); i++)
      {
        TrackedObject tO = (TrackedObject) trackedObjects.get(i);
        currentDist = dist(x, y, tO.x, tO.y);
  
        ////////////////
        // KEEP OCCUPYING
        // if not cInteracting look if there is a fitting occupied tracked object in close distance -> action = 0
        ////////////////
        if (!growing && !cInteracting && tO.occupied && currentDist <= occupationDist)
        {
          action = 0;
          destTO = tO;
          break;
        }
        ////////////////
        // GETTING KILLED BY TRACKED_OBJECT
        // look if this creatures not occupying and if there is a tracked object in close distance -> action = 1
        ////////////////
        else if (!growing && !occupying && currentDist <= occupationDist)
        {
          // kill me with a splash
          // seems to be not happening if there is no delay or something and a bigger "killingDist" definied
          action = 1;
          break;
        }
        ////////////////
        // MOVE TO NEXT TRACKED_OBJECT
        // if not cInteracting look if there is a not occupied tracked object, not in close distance and choose the closest one -> action = 2
        ////////////////
        else if (!growing && !cInteracting && !tO.occupied && currentDist > occupationDist)
        {
          if (lastDist == -1)
          {
            lastDist = currentDist;
            destX = tO.x;
            destY = tO.y;
            destTO = tO;
          }
          else
          {
            if (lastDist > currentDist)
            {
              lastDist = currentDist;
              destX = tO.x;
              destY = tO.y;
              destTO = tO;
            }
          }
  
          action = 2;
        }
        ////////////////
        // DO SOMETHING ELSE
        // ???
        ////////////////
        else
        {
        }
      }
    }
    

    ////////////////
    // CREATURE 2 CREATURE INTERACTION
    // look for not occupying next creatures or interact if there is one in reach
    ////////////////
    if (action == -1)
    {
      ////////////////
      // MOVE TO NEXT CREATURE
      // look for not occupying creatures and choose the closest one -> action = -1
      ////////////////
      if(!cInteracting && !movingAway)
      {
        lastDist = -1;

        for (int j = 0; j < creatures.size(); j++)
        {
          Creature otherCreature = (Creature) creatures.get(j);
  
          // look for another creature than this one which is not occupying, not creature interacting, not growing and not moving away
          if (otherCreature != this && !otherCreature.occupying && !otherCreature.cInteracting && !otherCreature.growing && !otherCreature.movingAway)
          {
            currentDist = dist(x, y, otherCreature.x, otherCreature.y);
  
            if (lastDist == -1)
            {
              lastDist = currentDist;
              destX = otherCreature.x;
              destY = otherCreature.y;
              destC = otherCreature;
            }
            else
            {
              if (lastDist > currentDist)
              {
                lastDist = currentDist;
                destX = otherCreature.x;
                destY = otherCreature.y;
                destC = otherCreature;
              }
            }
  
            action = 3;
          }
        }
      }
      ////////////////
      // INTERACT WITH CREATURE
      // if not movingAway --> action = 4
      ////////////////
      else
      {
        if(!movingAway)
        {
          action = 4;
        }
      }
    }
    
    
    ////////////////
    // RANDOM MOVEMENT
    // if there is no creature to interact with or trackedObject to occupy set a random dest --> action = 6
    ////////////////
    if (action == -1)
    {
      if(randomDest == null)
      {
        randomDest = new PVector(random(0, vWidth), random(0, vHeight));
        //println("randomDest "+randomDest.x+"  "+randomDest.y);
      }
      
      action = 6;
    }

    //println(creatures.indexOf(this)+"   action "+action);
    
    ////////////////
    // PERFORM THE ACTION
    // finally
    ////////////////
    switch(action)
    {
      case -1: // do something else or nothing maybe
        stopBodyParts();
        break;
  
      case 0: // keep occupying
        occupyTrackedObject(destTO);
        break;
  
      case 1: // kill me
        // won't be triggered right now sadly
        break;
  
      case 2: // move to next unoccupied trackedObject
        occupying = false;
        face.smile(true);
  
        c = new PVector(x, y); // creature
        d = new PVector(destX, destY); // destination
        step = stepToDest(c, d, speed * indiSpeed / lerpMove);
  
        x = lerp(x, step.x, lerpMove);
        y = lerp(y, step.y, lerpMove);
  
        moveBodyParts();
  
        // check if creature NOW occupies
        if (dist(x, y, destX, destY) <= occupationDist)
        {
          occupyTrackedObject(destTO);
        }
  
        break;
  
      case 3: // move to next not occupying and not interacting creature
        face.smile(true);
  
        c = new PVector(x, y); // creature
        d = new PVector(destX, destY); // destination
        step = stepToDest(c, d, speed * indiSpeed / lerpMove);
        
        x = lerp(x, step.x, lerpMove);
        y = lerp(y, step.y, lerpMove);
  
        moveBodyParts();
  
        // check if creature NOW interacts with other creature
        if (!cInteracting && !destC.cInteracting && dist(x, y, destX, destY) <= cInteractionDist)
        {
          cInteract(destC, 0, false, 0);
        }
        break;
        
      case 4: // interacting with another creature
        // animate interaction        
        if(frameCount < cInteractionEnd)
        {
          // struggling to kill
          if(cInteraction == -1)
          {
            animateFight();
          }
          // making sweet sweet love
          else if(cInteraction == 1)
          {
            animateLovemaking();
          }
          
        }
        // wait till creature interaction time is over
        else
        {
          // fight
          if(cInteraction == -1)
          {
            // killing
            if(cInteractionDominant)
            {
              kill();
            }
            // getting killed
            else
            {
              die();
            }
          }
          // mate
          else
          {
            // look for master creature
            if(linkedCreature != null)
            {
              spawnChildCreature();
            }

            moveOn();
          }
        }
        
        break;
        
      case 5: // growing
        grow();
        break;
        
      case 6: // random movement
        face.smile(true);
  
        c = new PVector(x, y); // creature
        destX = randomDest.x;
        destY = randomDest.y;
        d = new PVector(destX, destY); // destination
        
        step = stepToDest(c, d, speed * indiSpeed / lerpMove);
        
        x = lerp(x, step.x, lerpMove);
        y = lerp(y, step.y, lerpMove);
        
        moveBodyParts();
  
        // check if creature NOW interacts with other creature
        if (dist(x, y, randomDest.x, randomDest.y) <= randomDestDist)
        {
          randomDest = null;
          movingAway = false;
        }
        
        break;
    }


    ////////////////
    // rotation
    ////////////////

    // do something when the action is movement to trackedObject or another creature 
    if (action == 2 || action == 3 || action == 6)
    {
      c = new PVector(-1, 0); // creatures first direction
      d = new PVector(destX, destY); // destination position

      rot = lerp(rot, rotToDest(c, d), lerpRot);
    }
  }

  public void cInteract(Creature destC, int interaction, Boolean dominant, int interactionEnd)//, int interaction, Boolean interactionDominant)
  {
    // general creature behaviour
    cInteracting = true;
    
    // master creature behaviour
    if(destC != null)
    {
      linkedCreature = destC;
      
      // positive interaction --> mating
      cInteraction = 1;
      
      ///////////////
      // randomly choose positiv or negativ interaction
      // but to ensure a refreshing "genpool" the chance for a negativ interaction is slightly higher, like this the random creature generator more often steps in
      ///////////////
      float randDesc = random(-1, matingPossibility); // adjust second parameter to increase/decrease mating 
      if(randDesc < 0)
      {
        // negative interaction --> killing
        cInteraction = -1;
        
        // desc who killes --> is dominant
        cInteractionDominant = true;
        randDesc = random(-1, 1);
        if(randDesc < 0)
        {
          cInteractionDominant = false;
        }  
      }
      
      // JUST FOR TESTING love making!!
      //cInteraction = 1; // remove after testing!
      
      cInteractionEnd = frameCount + PApplet.parseInt(cInteractionTime * frameRate);
      
      Boolean destDominant = true;
      if(cInteractionDominant)
      {
        destDominant = false;
      }
      
      destC.cInteract(null, cInteraction, destDominant, cInteractionEnd);
    }
    // slave creature behaviour
    else
    {
      cInteraction = interaction;
      cInteractionDominant = dominant;
      cInteractionEnd = interactionEnd;
    }
  }
  
  public void occupyTrackedObject(TrackedObject tO)
  {
    tO.occupied = true;
    occupying = true;

    face.smile(false);
    stopBodyParts();

    switch(type)
    {
    case 0: // eating worm
      drawBodyParts = false;
      drawTrackedObjectShape(tO);
      transformFace(tO);
      break;
    }
  }
  
  //////////////////
  // takes current position, destination position and speed and returns new current position
  //////////////////
  public PVector stepToDest(PVector currentPos, PVector destPos, float speed)
  {
    destPos.sub(currentPos); // set destPos from (0|0)
    destPos.normalize(); // normalize destPos
    destPos.mult(speed); // multiply by speed
    currentPos.add(destPos); // add calculated step to currentPos
    
    return currentPos;
  }
  
  //////////////////
  // takes original direction (preferably normalized) and destination position and returns rotation to face destination in radians
  //////////////////
  public float rotToDest(PVector originalDir, PVector destPos)
  {
    destPos.sub(x, y, 0); // calc destination direction
    originalDir.normalize();
    destPos.normalize();

    float dot = originalDir.dot(destPos); // create dot product of the two directions
    PVector cross = originalDir.cross(destPos); // create cross product of the two directions, to destinguish turning direction

    float newRot = acos(dot); //PVector.angleBetween(c, d); --> same as acos(dot); // arc cos dot product to get angle to rotate

    if (cross.z < 0) // destinguish turning direction
    {
      newRot = -newRot;
    }
    
    return newRot;
  }
  
  public void moveBodyParts()
  {
    if (!bodyPartsMoving)
    {
      for (int i = 0; i < anis.size(); i++)
      {
        Ani ani = (Ani) anis.get(i);
        ani.resume();
      }

      bodyPartsMoving = true;
    }
  }

  public void stopBodyParts()
  {
    if (bodyPartsMoving)
    {
      for (int i = 0; i < anis.size(); i++)
      {
        Ani ani = (Ani) anis.get(i);
        ani.pause();
      }

      bodyPartsMoving = false;
    }
  }

  public void drawTrackedObjectShape(TrackedObject tO)
  {
    o.pushStyle();
    EdgeVertex eA, eB;
    PShape shape = createShape();
    shape.fill(col);
    shape.noStroke();

    for (int m = 0; m < tO.getEdgeNb(); m++)
    {
      eA = tO.getEdgeVertexA(m);
      eB = tO.getEdgeVertexB(m);
      if (eA != null && eB != null)
      {
        shape.vertex(eA.x*width, eA.y*height);
      }
    }

    shape.end(CLOSE);
    o.shape(shape);

    o.popStyle();
  }

  public void transformFace(TrackedObject tO)
  {
    if (tO != null)
    {
      float maxSize = tO.w;

      if (tO.w > tO.h)
      {
        maxSize = tO.h;
      }

      face.x = - occupationDist;
      face.y = - unitSize * 2;
      face.drawBackground = true;
      face.scale = lerp(face.scale, maxSize / (unitSize * 4), 0.1f);//average(face.scale, maxSize / (unitSize * 4));
    }
    else
    {
      face.x = 0;
      face.y = 0;
      face.scale = lerp(face.scale, 1, 0.1f);
      face.drawBackground = false;
    }
  }
  
  public void grow()
  {
    if(growingAni == null)
    {
      growingAni = Ani.from(this, growingTime, "scale", 0.5f, Ani.SINE_OUT, "onEnd:moveOn");
    }
  }
  
  public void animateFight()
  {
    moveBodyParts();
    face.rage(false);
    
    if(!cInteractionAni.isPlaying())
    {
      int aniReps = 10;
            
      cInteractionAni = Ani.to(this, cInteractionTime / aniReps, "intAniX", intAniX + (unitSize), Ani.QUAD_OUT);
      cInteractionAni.setPlayMode(Ani.YOYO);
      cInteractionAni.repeat(aniReps);
    }
  }
  
  public void animateLovemaking()
  {
    moveBodyParts();
    face.love();
    
    if(!cInteractionAni.isPlaying())
    {
      int aniReps = 6;
            
      cInteractionAni = Ani.to(this, cInteractionTime / aniReps, "intRot", intRot + radians(20), Ani.SINE_IN_OUT);
      cInteractionAni.setPlayMode(Ani.YOYO);
      cInteractionAni.repeat(aniReps);
    }
  }
  
  public void spawnChildCreature()
  {
    HeartPulse h = new HeartPulse(x, y, rot, col);
    groundEffects.add(h);
    
    int cType;
    if(cInteractionDominant)
    {
      cType = type; 
    }
    else
    {
      cType = linkedCreature.type;
    }
    
    ColourTable cCTable = new ColourTable();
    cCTable.addContinuousColourRule(0.0f, col);
    cCTable.addContinuousColourRule(1.0f, linkedCreature.col);
    
    Creature child = new Creature(true, cCTable, cType, true);
    child.x = x;
    child.y = y;
    
    creatures.add(0, child);
  }
  
  public void moveOn()
  {
    growingAni = null;
    growing = false;
    cInteracting = false;
    linkedCreature = null;
    face.smile(true);
    movingAway = true;
  }
  
  public void kill()
  {
    cInteracting = false;
    linkedCreature = null;
    face.smile(true);
  }
  
  public void die()
  {
    if(!dying)
    {
      dying = true;
      linkedCreature = null;
      face.die();
      stopBodyParts();
    
      Timer timer = new Timer(config.main, dyingTime, this, "remove");
    }
  }
  
  public void remove()
  {
    groundEffects.add(new Splash(x, y, cTable, PApplet.parseInt(random(7, 10))));
    creatures.remove(this);
    //System.gc();
  }
}















public void printCamNames()
{
  String[] cameras = Capture.list();
  
  for(int i = 0; i < cameras.length; i++)
  {
    String currentCamName = cameras[i].substring(5, cameras[i].indexOf(","));
    println("cam: " + currentCamName);
  }
}


public void drawStats()
{
  o.fill(255,152,255);
  o.rectMode(CORNER);
  o.rect(5,5,flob.getPresencef()*width,5);
  
  String stats = "fps: "+frameRate+
                 "\ncreatures: "+creatures.size()+
                 "\ncreatureExcess: "+config.creatureExcess+" <x/X>"+
                 "\ngroundEffects: "+groundEffects.size()+
                 "\ntrackObjects: "+trackedObjects.size()+
                 "\nflob.thresh:"+config.tresh+" <t/T>"+
                 "\nflob.fade:"+config.fade+"   <f/F>"+
                 "\nflob.om:"+flob.getOm()+" <o>"+
                 "\nflob.image:"+config.videotex+" <i>"+
                 "\nflob.presence:"+flob.getPresencef()+
                 "\nedgeTresh:"+config.edgeTresh+" <e/E>"+
                 "\nposDiscrimination:"+config.posDiscrimination+" <p>"+
                 "\n\nset background <b>"+
                 "\ntoggle keystone mode <k>"+
                 "\ncreate random creature <c>"+
                 "\ncreate random creature in the center <C>"+
                 "\nremove all creatures <r>"+
                 "\ntoggle debug info <d>"+
                 "\nsave config AND save keystone <s>"+
                 "\nset background AND save config AND save keystone <space>";
  o.textSize(14);
  o.fill(255);
  o.text(stats, 5, 25);
}

public void drawFlobs()
{
  o.fill(255,100);
  o.stroke(255,200);
  o.rectMode(CENTER);
  
  for(int i = 0; i < flobs.size(); i++) {
    trackedBlob tb = flob.getTrackedBlob(i);
   
    String txt = "id: "+tb.id+" time: "+tb.presencetime+" pixelcount: "+tb.pixelcount;
    float velmult = 100.0f;
    o.fill(220,220,255,100);
    o.rect(tb.cx,tb.cy,tb.dimx,tb.dimy);
    o.fill(0,255,0,200);
    o.rect(tb.cx,tb.cy, 5, 5); 
    o.fill(0);
    o.line(tb.cx, tb.cy, tb.cx + tb.velx * velmult ,tb.cy + tb.vely * velmult ); 
    o.text(txt,tb.cx -tb.dimx*0.10f, tb.cy + 5f);   
  }
}

public void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  o.noFill();
  Blob b;
  EdgeVertex eA,eB;
  for (int n = 0 ; n < blobDetection.getBlobNb() ; n++)
  {
    b = blobDetection.getBlob(n);
    if (b!=null)
    {
      // Edges
      if (drawEdges)
      {
        o.strokeWeight(3);
        o.stroke(0,255,0);
        for (int m = 0; m < b.getEdgeNb(); m++)
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
            o.line(
              eA.x*width, eA.y*height, 
              eB.x*width, eB.y*height
              );
        }
      }

      // Blobs
      if (drawBlobs)
      {
        o.rectMode(CORNER);
        o.strokeWeight(1);
        o.stroke(255,0,0);
        o.rect(
          b.xMin*width,b.yMin*height,
          b.w*width,b.h*height
          );
      }
    }
  }
}

public void drawTrackedObjects(boolean drawBlobs, boolean drawEdges, boolean drawCenters)
{
  TrackedObject tO;
  
  for(int i = 0; i < trackedObjects.size(); i++)
  {
    tO = (TrackedObject) trackedObjects.get(i);
    tO.draw(drawBlobs, drawEdges, drawCenters);
  }
}


public void processNewFrame()
{
  video.read();
  videoinput.copy(video, 0, 0, cWidth, cHeight, 0, 0, config.videores, config.videores);
  //flobs = flob.track(flob.binarize(videoinput)); // flob.track seems not able to handle multiple trackedBlobs for longer???? 
  flobs = flob.calcsimple(flob.binarize(videoinput));
  
  
  videoinputBD.copy(video, 0, 0, cWidth, cHeight, 0, 0, config.videores, config.videores); // uses original videoinput, adjust edgeTresh!!!
  //videoinputBD.copy(flob.getSrcImage(), 0, 0, cWidth, cHeight, 0, 0, config.videores, config.videores); // uses difference optimized image from flob, adjust edgeTresh!!!
  fastblur(videoinputBD, 2);
  blobDetection.computeBlobs(videoinputBD.pixels);
}

public void setTrackedObjects()
{
  trackedObjects = new ArrayList();
  
  trackedBlob f;
  Blob b;
  
  // flobs
  for(int i = 0; i < flobs.size(); i++) 
  {
    f = flob.getTrackedBlob(i);
    //o.rect(tb.cx,tb.cy,tb.dimx,tb.dimy);
    
    float fXMin = f.cx - (f.dimx / 2);
    float fXMax = f.cx + (f.dimx / 2);
    float fYMin = f.cy - (f.dimy / 2);
    float fYMax = f.cy + (f.dimy / 2);
    
    // blobs
    for (int n = 0 ; n < blobDetection.getBlobNb() ; n++)
    {
      b = blobDetection.getBlob(n);
      
      if (b!=null)
      {
        float bX = b.xMin*width + (b.w*width / 2);
        float bY = b.yMin*height + (b.h*height / 2);
        float bW = b.w*width;
        float bH = b.h*height;
        
        // a trackedObject has to be created
        if(bX >= fXMin && bX <= fXMax && bY >= fYMin && bY <= fYMax) 
        {
          
          float dX = average(f.cx, bX);  
          float dY = average(f.cy, bY);
          float dW = average(f.dimx, bW);
          float dH = average(f.dimy, bH);
          Boolean occupied = false;

          // look for near creatures to set trackedObjects to occupied
          for(int j = 0; j < creatures.size(); j++)
          {
            Creature c = (Creature) creatures.get(j);
            
            if(dist(dX, dY, c.x, c.y) < occupationDist)
            {
              occupied = true;
              break;
            }
          }
          
          trackedObjects.add(new TrackedObject(f, b, dX, dY, dW, dH, occupied));
          
          break;
        }
      }
    }   
  }
}

public void populateCreatures()
{
  if(creatures.size() < trackedObjects.size() + config.creatureExcess)
  {
    creatures.add(new Creature(true, null, -1, false));
  }
}

public void drawCreatures()
{
  for(int i = 0; i < creatures.size(); i++)
  {
    Creature c = (Creature) creatures.get(i);
    c.draw();
  }
}

public void drawGroundEffects()
{
  for(int i = 0; i < groundEffects.size(); i++)
  {
    GroundEffect gE = (GroundEffect) groundEffects.get(i);
    gE.draw();
  }
}
class Drop
{
  int unitSize = 10;
  
  float x, y, scale, rot;
  int col;
  
  Drop(float posX, float posY, int c, float s, float rotation)
  {
    x = posX;
    y = posY;
    col = c;
    scale = s;
    rot = rotation;
  }
  
  public void draw(int alpha)
  {
    o.pushMatrix();
    o.pushStyle();
      o.translate(x, y);
      o.scale(scale);
      o.rotate(rot);
      
      o.noStroke();
      o.fill(col, alpha);
      
      o.ellipse(0, 0, unitSize, unitSize / 2);
      o.triangle(0, - (unitSize / 4) - 0.5f, unitSize * 2, - 0.5f, 0, (unitSize / 4) + 0.5f);
      
    o.popStyle();
    o.popMatrix();
  }
}
class Face
{
  float x = 0;
  float y = 0;
  float scale = 1.0f;
  float strokeWeight = 3.0f;
  
  int col = color(255);
  int bgCol;
  Boolean drawBackground = false;
  int mouthType = 0;
  int eyeType = 0;
  int specialType = -1;
  int character = 0;
  Boolean dying = false;
  float blinkSecMin = 1.0f;
  float blinkSecMax = 6.0f;
  float blinkingDuration = 0.2f;
  Boolean blinking = false;
  int blinkingFirstFrame = 0;
  int blinkingLastFrame = 0;
  float mouthScaleY = 1.0f;
  float eyeMoveX = 0.0f;
  float aniSpecialScaleX = 1.0f;
  float aniSpecialScaleY = 1.0f;
  Ani aniMouthScale;
  Ani aniEyeMove;
  AniSequence aniSpecial;
  Boolean animateSpecial = false;
  
  Face(int eType, int mType, int backgroundColor)
  {
    mouthType = mType;
    eyeType = eType;
    bgCol = backgroundColor;
    
    setAniMouthScale();
    setAniEyeMove();
  }
  
  public void draw()
  {
    checkForRandomBlink();
    
    o.pushMatrix();
    o.pushStyle();
    
      o.translate(x, y);
      o.scale(scale);
      o.noStroke();
      o.fill(bgCol);
      
      ///////////////
      // render background
      ///////////////
      
      o.pushMatrix();
        
        o.translate(0, 8);
        
        if(drawBackground)
        {
          o.ellipse(0, 0, 24, 24);
        }
      
      o.popMatrix();
      
      ///////////////
      // render eyes
      ///////////////
      
      o.fill(col);
      
      o.pushMatrix();
        
        if(!blinking || dying || eyeType == -1)
        {
          o.translate(eyeMoveX, 4);

          switch(eyeType)
          {
            case 0: // open
              o.ellipse(-5, 0, strokeWeight + 1, strokeWeight + 1);
              o.ellipse(5, 0, strokeWeight + 1, strokeWeight + 1);
              break;
              
            case 1: // rage eyes
              o.arc(-4, 0, strokeWeight + 4, strokeWeight + 4, radians(20), radians(200));
              o.arc(4, 0, strokeWeight + 4, strokeWeight + 4, radians(-20), radians(160));
              break;
              
            case 2: // dead eyes, crosses
              o.pushMatrix();
                o.scale(2);
                o.translate(-2.5f, -1);
                o.rotate(radians(45));
                o.rect(-1.25f, 0, strokeWeight + 1, strokeWeight / 2);
                o.rotate(radians(-90));
                o.rect(-2.75f, 0, strokeWeight + 1, strokeWeight / 2);
                o.rotate(radians(45));
                o.translate(5, 0);
                o.rotate(radians(45));
                o.rect(-1.25f, 0, strokeWeight + 1, strokeWeight / 2);
                o.rotate(radians(-90));
                o.rect(-2.75f, 0, strokeWeight + 1, strokeWeight / 2);
              o.popMatrix();
              break;
              
            default: // nothing
              break;
          }
        }
        else
        {
          // closed blink eyes
          o.translate(eyeMoveX - 2, 4);
          o.rect(-5, 0, strokeWeight + 1, strokeWeight / 2);
          o.rect(5, 0, strokeWeight + 1, strokeWeight / 2);
        }
        
      o.popMatrix();
      
      
      ///////////////
      // render mouth
      ///////////////
      
      o.stroke(col);
      o.strokeWeight(strokeWeight);
      o.strokeCap(ROUND);
      o.noFill();
      
      o.pushMatrix();
        o.translate(0, 10);
        o.scale(1, mouthScaleY);
        switch(mouthType)
        {
          case 0: // closed smile
            o.arc(0, 0, 16, 16, radians(0), radians(180));
            break;
          
          case 1: // closed pout
            o.arc(0, 8, 16, 16, radians(180), radians(360));
            break;
          
          case 2: // open smile
            o.fill(col);
            o.arc(0, 0, 16, 16, radians(0), radians(180));
            break;
            
          case 3: // open pout
            o.fill(col);
            o.arc(0, 8, 16, 16, radians(180), radians(360));
            break;
          
          case 4: // neutral line
            o.fill(col);
            o.rect(-8, 4, 16, strokeWeight / 2);
            break;
          
          default: // nothing
            break;
        }
      o.popMatrix();
      
      
      ///////////////
      // render special
      ///////////////
      
      o.stroke(col);
      o.strokeWeight(strokeWeight);
      o.strokeCap(ROUND);
      o.fill(col);
      
      o.pushMatrix();
        switch(specialType)
        {
          case 0: // heart
            o.translate(-0.5f, 7);
            o.scale(aniSpecialScaleX, aniSpecialScaleX);
            o.translate(-3.5f, 0);
            o.scale(0.6f, 0.6f);
            o.ellipse(0, 0, 16, 16);
            o.ellipse(12, 0, 16, 16);
            o.rotate(radians(45));
            o.rect(-0.3f, -9.1f, 17, 17);
            break;
          
          default: // nothing
            break;
        }
      o.popMatrix();
    
    o.popStyle();
    o.popMatrix();
  }
  
  public void love()
  {
    eyeType = -1;
    mouthType = -1;
    specialType = 0;
   
    //println("aniSpecial " +aniSpecial+"      aniSpecial.isPlaying() "+aniSpecial.isPlaying());
    
    if(!animateSpecial)
    {
      animateSpecial = true;
      float longTime = 0.7f;
      float shortTime = 0.12f;
      float scaleMin = 0.6f;
      float scaleMed = 0.75f;
      
      aniSpecial = new AniSequence(config.main);
      aniSpecial.beginSequence();
      aniSpecial.add(Ani.to(this, longTime, "aniSpecialScaleX:" + scaleMin + ", aniSpecialScaleY:" + scaleMin, Ani.LINEAR));
      aniSpecial.add(Ani.to(this, shortTime, "aniSpecialScaleX:" + 1 + ", aniSpecialScaleY:" + 1, Ani.LINEAR));
      aniSpecial.add(Ani.to(this, shortTime, "aniSpecialScaleX:" + scaleMed + ", aniSpecialScaleY:" + scaleMed, Ani.LINEAR));
      aniSpecial.add(Ani.to(this, shortTime, "aniSpecialScaleX:" + 1 + ", aniSpecialScaleY:" + 1, Ani.LINEAR, "onEnd:restartAniSpecial"));
      aniSpecial.endSequence();
      aniSpecial.start();
    }
  }
  
  public void rage(Boolean closed)
  {
    specialType = -1;
    pout(closed);
    eyeType = 1;
  }
  
  public void die()
  {
    dying = true;
    mouthType = 4;
    eyeType = 2;
    mouthScaleY = 1;
    eyeMoveX = 0;
  }
  
  public void smile(Boolean closed)
  {
    specialType = -1;
    eyeType = 0;

    if(closed)
    {
      mouthType = 0;
    }
    else
    {
      mouthType = 2;
    }
  }
  
  public void pout(Boolean closed)
  {
    specialType = -1;
    
    if(closed)
    {
      mouthType = 1;
    }
    else
    {
      mouthType = 3;
    }
  }
  
  public void checkForRandomBlink()
  {
    if(!blinking && frameCount >= blinkingLastFrame + (blinkSecMin * frameRate))
    {
      blinkingFirstFrame = PApplet.parseInt(random(frameCount, frameCount + (blinkSecMax * frameRate)));
      blinkingLastFrame = blinkingFirstFrame + PApplet.parseInt(blinkingDuration * frameRate);
    }
    
    if(frameCount >= blinkingFirstFrame && frameCount <= blinkingLastFrame)
    {
      blinking = true;
    }
    else
    {
      blinking = false;
    }
  }
  
  public void setAniMouthScale()
  {
    if(!dying)
    {
      float randTime = random(0.3f, 1.2f);
      float randScale = random(0.5f, 1.0f);
      aniMouthScale = new Ani(this, randTime, "mouthScaleY", randScale, Ani.QUAD_IN_OUT, "onEnd:setAniMouthScale");
    }
  }
  
  public void setAniEyeMove()
  {
    if(!dying)
    {
      float randTime = random(0.3f, 1.2f);
      float randMove = random(-1.3f, 1.3f);
      aniEyeMove = new Ani(this, randTime, "eyeMoveX", randMove, Ani.EXPO_IN_OUT, "onEnd:setAniEyeMove");
    }
  }
  
  public void restartAniSpecial()
  {
    if(animateSpecial)
    {
      aniSpecial.start();
    }
  }
  
}
class GroundEffect
{
  GroundEffect()
  {
  }
  
  public void draw()
  {
  }
}
class HeartPulse extends GroundEffect
{
  float x, y, rot;
  float scale = 0;
  float alpha = 255;
  float time = 3.0f;
  int col;
  Ani[] ani;
  
  HeartPulse(float posX, float posY, float r, int c)
  {
    x = posX;
    y = posY;
    rot = r;
    col = c;
    
    ani = Ani.to(this, time, "scale:0.4, alpha:0", Ani.QUINT_OUT, "onEnd:remove");
  }
  
  public void draw()
  {
    o.pushMatrix();
    o.pushStyle();
      o.translate(x, y);
      o.rotate(rot);
      o.scale(scale);
      
      o.translate(-150, -150);
      o.tint(col, alpha);
      o.image(config.heartOutline, 0, 0);
    
    o.popStyle();
    o.popMatrix();
  }
  
  public void remove()
  {
    groundEffects.remove(this);
    //System.gc();
  }
}
public void keyPressed(){
  if (key=='i') 
  {  
    config.videotex = (config.videotex+1)%4;
    flob.setImage(config.videotex);
  }
  
  if(key=='t') 
  {
    config.tresh--;
    flob.setTresh(config.tresh);
  }
  
  if(key=='T') 
  {
    config.tresh++;
    flob.setTresh(config.tresh);
  }   
  
  if(key=='f') 
  {
    config.fade--;
    flob.setFade(config.fade);
  }
  
  if(key=='F') 
  {
    config.fade++;
    flob.setFade(config.fade);
  }   
  
  if(key=='o') 
  {
    config.om=(config.om +1) % 3;
    flob.setOm(config.om);
  }   
  
  if(key=='e') 
  {
    config.edgeTresh = config.edgeTresh - 0.01f;
    blobDetection.setThreshold(config.edgeTresh);
  }
  
  if(key=='E') 
  {
    config.edgeTresh = config.edgeTresh + 0.01f;
    blobDetection.setThreshold(config.edgeTresh);
  }
  
  if(key=='p') 
  {
    if(config.posDiscrimination)
    {
      config.posDiscrimination = false;
    }
    else
    {
      config.posDiscrimination = true;
    }
    
    blobDetection.setPosDiscrimination(config.posDiscrimination);
  }
  
  if(key=='b')
  {
    setBackgroundImage();
  } 
    
  if(key == 's') // saves config and keystone
  {
    config.save();
    ks.save();
  }
  
  if(key == ' ') // set Background AND save config AND keystone
  {
    setBackgroundImage();
    config.save();
    ks.save();
  }
  
  if(key == 'k') // enter/leave calibration mode, where surfaces can be warped and moved
  {
    ks.toggleCalibration();
  }
  
  if(key == 'd') // enter/leave calibration mode, where surfaces can be warped and moved
  {
    if(!config.debug)
    {
      config.debug = true;
    }
    else
    {
      config.debug = false;
    }
  }
  
  if(key == 'c') // create random creature
  {
    creatures.add(new Creature(true, null, -1, false));
  }
  
  if(key == 'C') // create random creature in the center 
  {
    Creature c = new Creature(true, null, -1, false);
    c.x = width/2;
    c.y = height/2;
    creatures.add(c);
  }
  
  if(key == 'r') // remove all creatures
  {
    creatures = new ArrayList();
    groundEffects = new ArrayList();
  }
  
  if(key=='x') // decrease creatureExcess
  {
    config.creatureExcess--;
  }
  
  if(key=='X') // increase creatureExcess
  {
    config.creatureExcess++;
  }
}

public void setBackgroundImage()
{
  backgroundImage = createImage(config.videores, config.videores, RGB);
  backgroundImage.copy(videoinput, 0, 0, videoinput.width, videoinput.height, 0, 0, videoinput.width, videoinput.height);
  
  flob.setBackground(backgroundImage);
  
  println("backgroundImage set");
}

public void mouseClicked() 
{
  if(config.debug && mouseKlickSound)
  {
    Sound s = new Sound(Sound.TYPE_YAY, mouseX, mouseY);
  }
}
















public void setupKeystone()
{
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(vWidth, vHeight, 20);
  o = createGraphics(vWidth, vHeight, OPENGL);
  o.smooth();
  o.rectMode(CENTER);
  o.textFont(font);
}

public void setupVideoCapture()
{
  video = new Capture(this, cWidth, cHeight, camName, fps);
  video.start();  
  videoinput = createImage(config.videores, config.videores, RGB);
  videoinputBD = createImage(config.videores, config.videores, RGB);
}

public void setupFlob()
{
  flob = new Flob(this, config.videores, config.videores, width, height);
  flob.setOm(config.om);  
  flob.setTresh(config.tresh);
  flob.setThresh(config.tresh);
  flob.setSrcImage(config.videotex);
  flob.settrackedBlobLifeTime(config.trackedBlobLifetime);
  flob.setBlur(0); //new : fastblur filter inside binarize
  flob.setMirror(false,false);
  
  if(backgroundImage != null)
  {
    flob.setBackground(backgroundImage);
  }
}

public void setupBlobDetection()
{
  blobDetection = new BlobDetection(config.videores, config.videores);
  blobDetection.setPosDiscrimination(config.posDiscrimination);
  blobDetection.setThreshold(config.edgeTresh);
}

public void setupSound()
{
  minim = new Minim(this);
}

public void setupTweets()
{
  tweets = new Tweets();
  tweets.start();
}
public class Sound
{
  public static final int TYPE_YAY = 0;

  int type;  
  float x, y;
  String fileName;
  
  AudioPlayer audioPlayer;
  
  Sound(int soundType, float posX, float posY)
  {
    type = soundType;
    x = posX;
    y = posY;
    fileName = getFileName();
    
    audioPlayer = minim.loadFile("data/sounds/" + fileName, 2048);
    audioPlayer.setPan(map(x, 0, vWidth, -1, 1));
    audioPlayer.play();
    
    // take this object into Processings post loop
    config.main.registerPost(this);
  }
  
  public String getFileName()
  {
    String fN = "";
    
    switch(type)
    {
      case TYPE_YAY:
        fN = "yay.wav";
        break;
    }
    
    return fN;
  }
  
  // gets called by Processings post loop
  public void post()
  {
    if(!audioPlayer.isPlaying())
    {
      // always close Minim audio classes when you are done with them
      // ensures that new sounds can be played
      audioPlayer.close();
      
      // remove this from the post loop
      config.main.unregisterPost(this);
    }
  }
}







class Splash extends GroundEffect
{
  float x, y;
  float scale = 1;
  int alpha = 255;
  ColourTable cTable;
  int dropCount = 5;
  float radius = 30;
  Ani ani;
  
  ArrayList drops = new ArrayList();
  
  Splash(float posX, float posY, ColourTable cT, int dC)
  {
    x = posX;
    y = posY;
    cTable = cT;
    dropCount = dC;
    
    for(int i = 0; i < dropCount; i++)
    {
      
      float rad = (TWO_PI / dropCount) * (i + random(-0.3f, 0.3f));  
      float x = radius * random(0.9f, 1.1f) * cos(rad);
      float y = radius * random(0.9f, 1.1f) * sin(rad);
      int col = cTable.findColour(random(0, 1));
      float s = random(0.6f, 1.7f);
      float rot = rad + PI;
      
      drops.add(new Drop(x, y, col, s, rot));
    }
    
    ani = Ani.from(this, 0.3f, "scale", 0.5f, Ani.QUINT_OUT, "onEnd:fadeOut");
  }
  
  public void draw()
  {
    o.pushMatrix();
    o.pushStyle();
      o.translate(x, y);
      o.scale(scale);
        
      for(int i = 0; i < drops.size(); i++)
      {
        Drop d = (Drop) drops.get(i);
        d.draw(alpha);
      }
      
    o.popStyle();
    o.popMatrix();
  }
  
  public void fadeOut()
  {
    ani = Ani.to(this, 1.0f, 1.0f, "alpha", 0, Ani.CUBIC_IN, "onEnd:remove");
  }
  
  public void remove()
  {
    groundEffects.remove(this);
    //System.gc();
  }
}



public class Timer
{
  PApplet main;
  float t;
  String fName;
  float startTime;
  float endTime;
  Object o;
  Method m;
  
  Timer(PApplet pApplet, float time, Object obj, String fctnName)
  {
    main = pApplet;
    t = time;
    o = obj;
    fName = fctnName;
    setAction(o, fName);
    
    startTime = millis();
    endTime = startTime + (time * 1000);
    
    main.registerPre(this);
  }
  
  /////////////////
  // have a look at the following for more understanding auf pre, post, draw etc. and registerPre etc.: http://www.processing.org/discourse/beta/num_1187919231.html
  /////////////////
  public void pre()
  {
    if(millis() >= endTime)
    {
      performAction();
      main.unregisterPre(this);
    }
  }
  
  /////////////////
  // code below from ewjordan: http://www.processing.org/discourse/beta/num_1187919231.html
  /////////////////
  public void setAction(Object object, String method){
    if (method != null && !method.equals("") && o != null){
      try{
    m = o.getClass().getMethod(method, null);
      } catch (SecurityException e){
    e.printStackTrace();
      } catch (NoSuchMethodException e){
    e.printStackTrace();
      }
    }
  }
  
  public void performAction(){
    if (m == null || o == null) return;
    try{
      m.invoke(o, null);
    } catch (Exception e){
      e.printStackTrace();
    }
  }
}
class TrackedObject
{
  float x, y, w, h;
  Boolean occupied = false;
  
  trackedBlob flob;
  Blob blob;
  
  TrackedObject(trackedBlob f, Blob b, float posX, float posY, float oWidth, float oHeight, Boolean oc)
  {
    blob = b;
    flob = f;
    x = posX;
    y = posY;
    w = oWidth;
    h = oHeight;
    occupied = oc; 
  }
  
  public void draw(boolean drawBlob, boolean drawEdges, boolean drawCenter)
  {
    o.noFill();
    
    // Blobs
    if (drawBlob)
    {
      o.rectMode(CENTER);
      o.strokeWeight(1);
      o.stroke(255,0,0);
      o.rect(x, y, w, h);
    }
    
    // Edges
    if (drawEdges)
    {
      o.strokeWeight(3);
      o.stroke(0,255,0);
      EdgeVertex eA,eB;
      
      for (int m = 0; m < getEdgeNb(); m++)
      {
        eA = getEdgeVertexA(m);
        eB = getEdgeVertexB(m);
        if (eA != null && eB != null)
        {
          o.line(eA.x*width, eA.y*height, eB.x*width, eB.y*height);
        }
      }
    }
    
    // Center
    if(drawCenter)
    {
      o.strokeWeight(3);
      o.stroke(255, 0, 0);
      o.rect(x, y, 10, 10);
    }
  }
  
  public int getEdgeNb()
  {
    return blob.getEdgeNb();
  }
  
  public EdgeVertex getEdgeVertexA(int iEdge)
  {
    return blob.getEdgeVertexA(iEdge);
  }
  
  public EdgeVertex getEdgeVertexB(int iEdge)
  {
    return blob.getEdgeVertexB(iEdge);
  }
}


















public class Tweets extends Thread
{
  // Thread vars
  boolean running;                   // Is the thread running?  Yes or no?
  boolean available;                 // is tweets available for others to request
  int pollingTime = 12 * 1000;       // How many milliseconds should we wait in between executions?
  String id = "Tweets";              // Thread name
  Boolean printTweets = false;

  // class/twitter vars
  String querySearchParam = "#TableCreatures OR #CreativeTechnology";
  int reqPerPage = 100;
  
  ArrayList tweets = new ArrayList();
  ConfigurationBuilder cb;
  Twitter twitter;
  Query query;
  
  Tweets()
  {
    running = false;
  }
  
  public void start()
  {
    ///////////////
    // Twitter stuff
    ///////////////
   
    cb = new ConfigurationBuilder();
    cb.setOAuthConsumerKey("1ENhhsQmb0LXAc5po5qUBw");
    cb.setOAuthConsumerSecret("WWgm27yiOW2jxSjZ0ynMjTJ6lvscL5MW3mG62X7Os");
    cb.setOAuthAccessToken("68431437-otUPCszca9s8w07zavTU7Oyily5nsviOWxDNjiNiK");
    cb.setOAuthAccessTokenSecret("YVfiCY9O5aeE4cdvsd8WBlueXtxJc18LI1zDvWuhHI");
    
    twitter = new TwitterFactory(cb.build()).getInstance();
    query = new Query(querySearchParam);
    query.setCount(reqPerPage);
    
    
    ///////////////
    // Thread stuff
    ///////////////
    
    running = true;
    super.start();
  } 
    
  public void run()
  {
    while(running)
    {
      //Try making the query request.
      try 
      {
        QueryResult result = twitter.search(query);
        ArrayList stati = (ArrayList) result.getTweets();
        
        saveStatiToTweets(stati);
        
        if(printTweets)
        {
          println("Tweets: successfully received and saved " + tweets.size() + " tweets.");
        }
      }
      catch (TwitterException te) 
      {
        loadSavedTweets();
        
        if(printTweets)
        {
          println("Tweets: Couldn't connect: " + te);
          println("Tweets: Saved tweets (" + tweets.size() + ") were loaded.");
        }
      }
      
      available = true;
      
      if(printTweets)
      {
        printTweets();
      }
      
      // Ok, let's wait for however long we should wait
      try 
      {
        sleep((long)(pollingTime));
      } 
      catch (Exception e)
      {
        println("Tweets: Thread sleep error: " + e);
      }
    }
  }
  
  public void saveStatiToTweets(ArrayList stati)
  {
    tweets = new ArrayList();
    String[] lines = {};
    
    for(int i = 0; i < stati.size(); i++)
    {
      Status t = (Status) stati.get(i);
      
      lines = append(lines, t.getUser().getScreenName());
      lines = append(lines, t.getText());
      
      SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss dd/MM/yyyy");
      lines = append(lines, format.format(t.getCreatedAt()));
      
      tweets.add(new TweetsTweet(t.getUser().getScreenName(), t.getText(), format.format(t.getCreatedAt())));
    }
    
    saveStrings("data/tweets.json", lines);
  }
  
  public void loadSavedTweets()
  {
    String[] lines = loadStrings("data/tweets.json");
    tweets = new ArrayList();
    
    for(int i = 0; i < lines.length; i++)
    {
      tweets.add(new TweetsTweet(lines[i], lines[i + 1], lines[i + 2]));
      
      i = i + 2;
    }
  }
  
  public void printTweets()
  {
    for (int i = 0; i < tweets.size(); i++) 
    {
      TweetsTweet t = (TweetsTweet) tweets.get(i);
      String user = t.user;//t.getUser();
      String msg = t.text;//t.getText();
      String d = t.date;//t.getDate();
      println("Tweet by " + user + " at " + d + ": " + msg);
    }
  }
  
  public boolean isAvailable() 
  {
    return available;
  }
  
  // Our method that quits the thread
  public void quit() {
    running = false;  // Setting running to false ends the loop in run()
    // In case the thread is waiting. . .
    interrupt();
  }
}


class TweetsTweet
{
  String user;
  String text;
  String date;
  
  TweetsTweet(String u, String m, String d)
  {
    user = u;
    text = m;
    date = d;
  }
  
  public String getUser()
  {
    return user;
  }
  
  public String getText()
  {
    return text;
  }
  
  public String getDate()
  {
    return date;
  }
}











public float average(float a, float b)
{
  return a - ((a - b) / 2);
}

// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
public void fastblur(PImage img,int radius)
{
 if (radius<1){
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum,gsum,bsum,x,y,i,p,p1,p2,yp,yi,yw;
  int vmin[] = new int[max(w,h)];
  int vmax[] = new int[max(w,h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0;i<256*div;i++){
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0;y<h;y++){
    rsum=gsum=bsum=0;
    for(i=-radius;i<=radius;i++){
      p=pix[yi+min(wm,max(i,0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0;x<w;x++){

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if(y==0){
        vmin[x]=min(x+radius+1,wm);
        vmax[x]=max(x-radius,0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0;x<w;x++){
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for(i=-radius;i<=radius;i++){
      yi=max(0,yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0;y<h;y++){
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if(x==0){
        vmin[y]=min(y+radius+1,hm)*w;
        vmax[y]=max(y-radius,0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "TableCreatures" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
