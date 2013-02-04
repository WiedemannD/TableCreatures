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
      
      float rad = (TWO_PI / dropCount) * (i + random(-0.3, 0.3));  
      float x = radius * random(0.9, 1.1) * cos(rad);
      float y = radius * random(0.9, 1.1) * sin(rad);
      color col = cTable.findColour(random(0, 1));
      float s = random(0.6, 1.7);
      float rot = rad + PI;
      
      drops.add(new Drop(x, y, col, s, rot));
    }
    
    ani = Ani.from(this, 0.3, "scale", 0.5, Ani.QUINT_OUT, "onEnd:fadeOut");
  }
  
  void draw()
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
  
  void fadeOut()
  {
    ani = Ani.to(this, 1.0, 1.0, "alpha", 0, Ani.CUBIC_IN, "onEnd:remove");
  }
  
  void remove()
  {
    groundEffects.remove(this);
    //System.gc();
  }
}
