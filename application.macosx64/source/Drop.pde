class Drop
{
  int unitSize = 10;
  
  float x, y, scale, rot;
  color col;
  
  Drop(float posX, float posY, color c, float s, float rotation)
  {
    x = posX;
    y = posY;
    col = c;
    scale = s;
    rot = rotation;
  }
  
  void draw(int alpha)
  {
    o.pushMatrix();
    o.pushStyle();
      o.translate(x, y);
      o.scale(scale);
      o.rotate(rot);
      
      o.noStroke();
      o.fill(col, alpha);
      
      o.ellipse(0, 0, unitSize, unitSize / 2);
      o.triangle(0, - (unitSize / 4) - 0.5, unitSize * 2, - 0.5, 0, (unitSize / 4) + 0.5);
      
    o.popStyle();
    o.popMatrix();
  }
}
