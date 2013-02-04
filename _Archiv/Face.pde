class Face
{
  float scale = 1.0;
  float strokeWeight = 3.0;
  
  color col = color(255);
  int mouthType = 0;
  int eyeType = 0;
  int character = 0;
  
  Face(int eType, int mType)
  {
    mouthType = mType;
    eType = eType;
  }
  
  void draw()
  {
    pushMatrix();
    pushStyle();
    
      noStroke();
      fill(col);
      
      pushMatrix();
        translate(0, 4);
        switch(eyeType)
        {
          case 0:
            ellipse(-5, 0, strokeWeight + 1, strokeWeight + 1);
            ellipse(5, 0, strokeWeight + 1, strokeWeight + 1);
            break;
        }
      popMatrix();
      
      
      stroke(col);
      strokeWeight(strokeWeight);
      strokeCap(ROUND);
      noFill();
      
      pushMatrix();
        translate(0, 10);
        switch(mouthType)
        {
          case 0: // closed smile
            arc(0, 0, 16, 16, radians(0), radians(180));
            break;
          
          case 1: // closed pout
            arc(0, 8, 16, 16, radians(180), radians(360));
            break;
          
          case 2: // open smile
            fill(col);
            arc(0, 0, 16, 16, radians(0), radians(180));
            break;
            
          case 3: // open pout
            fill(col);
            arc(0, 8, 16, 16, radians(180), radians(360));
            break;
        }
      popMatrix();
    
    popStyle();
    popMatrix();
  }
  
  void smile(Boolean closed)
  {
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
    if(closed)
    {
      mouthType = 1;
    }
    else
    {
      mouthType = 3;
    }
  }
}
