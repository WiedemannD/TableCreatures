class CirclePulse extends GroundEffect
{
  float x, y, rot;
  float scale = 0;
  float alpha = 255;
  float time = 1.0;
  color col;
  Ani[] ani = new Ani[2];
  
  CirclePulse(float posX, float posY, float r, color c)
  {
    x = posX;
    y = posY;
    rot = r;
    col = c;
    
    ani[0] = Ani.to(this, time, "scale", 0.4, Ani.QUINT_OUT);
    ani[1] = Ani.to(this, time, "alpha", 0, Ani.QUINT_IN);
    
    for(int i = 0; i < ani.length; i++)
    {
      ani[i].repeat();
    }
  }
  
  void draw()
  {
    o.pushMatrix();
    o.pushStyle();
      o.translate(x, y);
      o.rotate(rot);
      o.scale(scale);
      
      
      o.noFill();
      o.stroke(col, alpha);
      o.strokeWeight(3);
      o.ellipse(0, 0, 300, 300);
    
    o.popStyle();
    o.popMatrix();
  }
  
  void remove()
  {
    for(int i = 0; i < ani.length; i++)
    {
      ani[i].end();
    }
    groundEffects.remove(this);
  }
}
