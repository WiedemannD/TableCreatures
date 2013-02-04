class Creature
{
  int addSpace = 150; 
  float scale = 1.0;
  float speed = 1.0; // general creature speed factor
  int unitSize = 10;
  float lerpMove = 0.1;
  float lerpRot = 0.05;
  float cInteractionTime = 4.0;
  float dyingTime = 1.5;
  float timer = 0;
  float matingPossibility = 0.35; // second parameter of random(-1, matingPossibility);
  int typeCount = 0;

  float x, y, indiSpeed; // position, rotation and individual creature type speed
  float rot = 0;
  String name;
  color col;
  ColourTable cTable;
  int type = 0;
  Face face;
  Boolean stop = false;
  Boolean dying = false;
  Boolean bodyPartsMoving = true;
  Boolean drawBodyParts = true;
  ArrayList bodyParts;
  ArrayList anis = new ArrayList(); 
  
  Boolean growing = false;
  float growingTime = 20.0;
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
        cTable.addContinuousColourRule(0.0, int(random(255)), int(random(255)), int(random(255)));
        cTable.addContinuousColourRule(1.0, int(random(255)), int(random(255)), int(random(255)));
      }
      
      
      if(t != -1)
      {
        type = t;
      }
      else
      {
        type = int(random(0, typeCount));
      }
      
      switch(type)
      {
        case 0: // eating worm
          indiSpeed = 1.0;
  
          col = cTable.findColour(random(0, 1));
  
          bodyParts.add(new BodyPart(0, 0, unitSize, unitSize * 3, unitSize * 3, 0, col));
          bodyParts.add(new BodyPart(0, unitSize * 2, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));
          bodyParts.add(new BodyPart(0, unitSize * 3, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));
          bodyParts.add(new BodyPart(0, unitSize * 4, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));
          bodyParts.add(new BodyPart(0, unitSize * 5, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));
  
          float aniTime = 0.8; 
          float delay = 0.15;
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
        
        case 1: // twitter alien
          indiSpeed = 1.0;
  
          col = cTable.findColour(random(0, 1));
  
          bodyParts.add(new BodyPart(1, 0, unitSize, 40, 40, 0, col));
          /*bodyParts.add(new BodyPart(0, unitSize * 2, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));
          bodyParts.add(new BodyPart(0, unitSize * 3, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));
          bodyParts.add(new BodyPart(0, unitSize * 4, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));
          bodyParts.add(new BodyPart(0, unitSize * 5, 5, unitSize * 1, unitSize * 1, 0, cTable.findColour(random(0, 1))));*/
  
          /*float aniTime = 0.8; 
          float delay = 0.15;
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
          }*/
  
  
          break;
      }

      face = new Face(0, 0, col);
    }
  }

  void draw()
  {
    if(!stop)
    {
      updateTransform();
    }

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

  void updateTransform()
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

  void cInteract(Creature destC, int interaction, Boolean dominant, int interactionEnd)//, int interaction, Boolean interactionDominant)
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
      
      cInteractionEnd = frameCount + int(cInteractionTime * frameRate);
      
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
  
  void occupyTrackedObject(TrackedObject tO)
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
  PVector stepToDest(PVector currentPos, PVector destPos, float speed)
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
  float rotToDest(PVector originalDir, PVector destPos)
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
  
  void moveBodyParts()
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

  void stopBodyParts()
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

  void drawTrackedObjectShape(TrackedObject tO)
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

  void transformFace(TrackedObject tO)
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
      face.scale = lerp(face.scale, maxSize / (unitSize * 4), 0.1);//average(face.scale, maxSize / (unitSize * 4));
    }
    else
    {
      face.x = 0;
      face.y = 0;
      face.scale = lerp(face.scale, 1, 0.1);
      face.drawBackground = false;
    }
  }
  
  void grow()
  {
    if(growingAni == null)
    {
      growingAni = Ani.from(this, growingTime, "scale", 0.5, Ani.SINE_OUT, "onEnd:moveOn");
    }
  }
  
  void animateFight()
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
  
  void animateLovemaking()
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
  
  void spawnChildCreature()
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
    cCTable.addContinuousColourRule(0.0, col);
    cCTable.addContinuousColourRule(1.0, linkedCreature.col);
    
    Creature child = new Creature(true, cCTable, cType, true);
    child.x = x;
    child.y = y;
    
    creatures.add(0, child);
  }
  
  void moveOn()
  {
    growingAni = null;
    growing = false;
    cInteracting = false;
    linkedCreature = null;
    face.smile(true);
    movingAway = true;
  }
  
  void kill()
  {
    cInteracting = false;
    linkedCreature = null;
    face.smile(true);
  }
  
  void die()
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
  
  void remove()
  {
    groundEffects.add(new Splash(x, y, cTable, int(random(7, 10))));
    creatures.remove(this);
    //System.gc();
  }
}















