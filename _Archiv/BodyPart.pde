class BodyPart
{
  int type = 0;
  float x, y, w, h, rot;
  color col;
  
  BodyPart(int t, float posX, float posY, float oWidth, float oHeight, float rotation, color oColor)
  {
    type = t;
    x = posX;
    y = posY;
    w = oWidth;
    h = oHeight;
    rot = rotation;
    col = oColor;
  }
  
  void draw()
  {
    pushStyle();
      rectMode(CENTER);
      noStroke();
      fill(col);
      
      switch(type)
      {
        case 0: // rectangle
          rect(x, y, w, h);
          break;
      }
    
    popStyle();
  }
}
