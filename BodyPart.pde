class BodyPart
{
  int type = 0;
  float x, y, w, h, rot, scale;
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
    scale = 1;
  }
  
  BodyPart(int t, float posX, float posY, float oWidth, float oHeight, float rotation, color oColor, float s)
  {
    type = t;
    x = posX;
    y = posY;
    w = oWidth;
    h = oHeight;
    rot = rotation;
    col = oColor;
    scale = s;
  }
  
  void draw()
  {
    o.pushMatrix();
    o.pushStyle();
      o.rectMode(CENTER);
      o.noStroke();
      o.fill(col);
      
      switch(type)
      {
        case 0: // rectangle
          o.rect(x, y, w, h);
          break;
          
        case 1: // alien shape
          o.tint(col);
          o.translate(-20, -20);
          o.image(config.type_1, x, y, w, h);
          break;
        
        case 2: // circle
          o.translate(-w / 2, -h / 2);
          o.ellipse(x, y, w, h);
          break;
        
        case 3: // triangle
          o.scale(scale);
          o.translate(0, h / 5);
          o.rotate(rot);
          o.translate(x, y);
          
          o.triangle(w / 2, 4, w, h, 0, h);
          break;  
      }
    
    o.popStyle();
    o.popMatrix();
  }
}
