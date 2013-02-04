class Face
{
  float x = 0;
  float y = 0;
  float scale = 1.0;
  float strokeWeight = 3.0;
  
  color col = color(255);
  color bgCol;
  Boolean drawBackground = false;
  int mouthType = 0;
  int eyeType = 0;
  int eyeCount = 2;
  int specialType = -1;
  int character = 0;
  Boolean dying = false;
  float blinkSecMin = 1.0;
  float blinkSecMax = 6.0;
  float blinkingDuration = 0.2;
  Boolean blinking = false;
  int blinkingFirstFrame = 0;
  int blinkingLastFrame = 0;
  float mouthScaleY = 1.0;
  float eyeMoveX = 0.0;
  float aniSpecialScaleX = 1.0;
  float aniSpecialScaleY = 1.0;
  Ani aniMouthScale;
  Ani aniEyeMove;
  AniSequence aniSpecial;
  Boolean animateSpecial = false;
  
  Face(int eType, int mType, color backgroundColor, int eC)
  {
    mouthType = mType;
    eyeType = eType;
    bgCol = backgroundColor;
    eyeCount = eC;
    
    setAniMouthScale();
    setAniEyeMove();
  }
  
  void draw()
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
              if(eyeCount == 2)
              {
                o.ellipse(-5, 0, strokeWeight + 1, strokeWeight + 1);
                o.ellipse(5, 0, strokeWeight + 1, strokeWeight + 1);
              }
              if(eyeCount == 1)
              {
                o.ellipse(0, 0, strokeWeight + 1, strokeWeight + 1);
              }
              
              break;
              
            case 1: // rage eyes
              if(eyeCount == 2)
              {
                o.arc(-4, 0, strokeWeight + 4, strokeWeight + 4, radians(20), radians(200));
                o.arc(4, 0, strokeWeight + 4, strokeWeight + 4, radians(-20), radians(160));
              }
              if(eyeCount == 1)
              {
                o.arc(0, 0, strokeWeight + 4, strokeWeight + 4, radians(0), radians(180));
              }
              
              break;
              
            case 2: // dead eyes, crosses
              if(eyeCount == 2)
              {
                o.pushMatrix();
                  o.scale(2);
                  o.translate(-2.5, -1);
                  o.rotate(radians(45));
                  o.rect(-1.25, 0, strokeWeight + 1, strokeWeight / 2);
                  o.rotate(radians(-90));
                  o.rect(-2.75, 0, strokeWeight + 1, strokeWeight / 2);
                  o.rotate(radians(45));
                  o.translate(5, 0);
                  o.rotate(radians(45));
                  o.rect(-1.25, 0, strokeWeight + 1, strokeWeight / 2);
                  o.rotate(radians(-90));
                  o.rect(-2.75, 0, strokeWeight + 1, strokeWeight / 2);
                o.popMatrix();
              }
              if(eyeCount == 1)
              {
                o.pushMatrix();
                  o.scale(2);
                  o.translate(0, -1);
                  o.rotate(radians(45));
                  o.rect(-1.25, 0, strokeWeight + 1, strokeWeight / 2);
                  o.rotate(radians(-90));
                  o.rect(-2.75, 0, strokeWeight + 1, strokeWeight / 2);
                o.popMatrix();
              }
              
              break;
              
            default: // nothing
              break;
          }
        }
        else
        {
          // closed blink eyes
          o.translate(eyeMoveX - 2, 4);
          
          if(eyeCount == 2)
          {
            o.rect(-5, 0, strokeWeight + 1, strokeWeight / 2);
            o.rect(5, 0, strokeWeight + 1, strokeWeight / 2);
          }
          if(eyeCount == 1)
          {
            o.rect(0, 0, strokeWeight + 1, strokeWeight / 2);
          }
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
            o.translate(-0.5, 7);
            o.scale(aniSpecialScaleX, aniSpecialScaleX);
            o.translate(-3.5, 0);
            o.scale(0.6, 0.6);
            o.ellipse(0, 0, 16, 16);
            o.ellipse(12, 0, 16, 16);
            o.rotate(radians(45));
            o.rect(-0.3, -9.1, 17, 17);
            break;
          
          default: // nothing
            break;
        }
      o.popMatrix();
    
    o.popStyle();
    o.popMatrix();
  }
  
  void love()
  {
    eyeType = -1;
    mouthType = -1;
    specialType = 0;
   
    //println("aniSpecial " +aniSpecial+"      aniSpecial.isPlaying() "+aniSpecial.isPlaying());
    
    if(!animateSpecial)
    {
      animateSpecial = true;
      float longTime = 0.7;
      float shortTime = 0.12;
      float scaleMin = 0.6;
      float scaleMed = 0.75;
      
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
  
  void rage(Boolean closed)
  {
    specialType = -1;
    pout(closed);
    eyeType = 1;
  }
  
  void die()
  {
    dying = true;
    mouthType = 4;
    eyeType = 2;
    mouthScaleY = 1;
    eyeMoveX = 0;
  }
  
  void smile(Boolean closed)
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
  
  void pout(Boolean closed)
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
  
  void checkForRandomBlink()
  {
    if(!blinking && frameCount >= blinkingLastFrame + (blinkSecMin * frameRate))
    {
      blinkingFirstFrame = int(random(frameCount, frameCount + (blinkSecMax * frameRate)));
      blinkingLastFrame = blinkingFirstFrame + int(blinkingDuration * frameRate);
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
  
  void setAniMouthScale()
  {
    if(!dying)
    {
      float randTime = random(0.3, 1.2);
      float randScale = random(0.5, 1.0);
      aniMouthScale = new Ani(this, randTime, "mouthScaleY", randScale, Ani.QUAD_IN_OUT, "onEnd:setAniMouthScale");
    }
  }
  
  void setAniEyeMove()
  {
    if(!dying)
    {
      float randTime = random(0.3, 1.2);
      float randMove = random(-1.3, 1.3);
      aniEyeMove = new Ani(this, randTime, "eyeMoveX", randMove, Ani.EXPO_IN_OUT, "onEnd:setAniEyeMove");
    }
  }
  
  void restartAniSpecial()
  {
    if(animateSpecial)
    {
      aniSpecial.start();
    }
  }
  
}
