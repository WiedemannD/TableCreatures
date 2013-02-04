class HeartPulse extends GroundEffect
{
  float x, y, rot;
  float scale = 0;
  float alpha = 255;
  float time = 3.0;
  color col;
  Ani[] ani;
  
  HeartPulse(float posX, float posY, float r, color c)
  {
    x = posX;
    y = posY;
    rot = r;
    col = c;
    
    ani = Ani.to(this, time, "scale:0.4, alpha:0", Ani.QUINT_OUT, "onEnd:remove");
  }
  
  void draw()
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
  
  void remove()
  {
    groundEffects.remove(this);
    //System.gc();
  }
}
