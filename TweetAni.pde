class TweetAni extends GroundEffect
{
  PGraphics canvas;
  float x, y, rot, destX, destY, aniX;
  float speed = 2.0;
  int offset = 90;
  color col;
  int textHeight = 30;
  TweetsTweet tweet;
  String txt = "";
  Boolean isAnimating = true;
  
  TweetAni(float posX, float posY, float posDX, float posDY, float r, color c)
  {
    x = posX;
    y = posY;
    destX = posDX;
    destY = posDY;
    rot = rotToDest(new PVector(-1, 0), new PVector(destX, destY));
    col = c;
    aniX = dist(x, y, destX, destY);
    
    canvas = createGraphics(int(aniX), textHeight, JAVA2D);
    
    isAnimating = true;
  }
  
  void draw()
  {
    if(txt == "")
    {
      if(tweets.isAvailable())
      {
        int index = randomInt(0, tweets.tweets.size() - 1);
        tweet = (TweetsTweet) tweets.tweets.get(index);
        txt = tweet.user + ": " + tweet.text;
        txt = txt.toUpperCase();
        
        Sound sound = new Sound(Sound.TYPE_TWEET, x, y);
      }
    }
    else
    {
      canvas.beginDraw();
      canvas.background(0, 0);
      canvas.translate(aniX, 0);
      canvas.fill(col);
      canvas.textAlign(LEFT, TOP);
      canvas.textFont(font2);
      canvas.textSize(16);
      canvas.text(txt, 0, 0);
      
      canvas.endDraw();
      
      o.pushMatrix();
      o.pushStyle();
        o.translate(destX, destY);
        o.rotate(rot);
        o.image(canvas, 0, 0); 
      o.popStyle();
      o.popMatrix();
      
      aniX -= speed;
    }
    
    if(aniX <= - canvas.textWidth(txt) - offset)
    {
      remove();
    }
    
    //println("canvas "+canvas.width);
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
    
    return newRot;// + PI;
  }
  
  void remove()
  {
    groundEffects.remove(this);
    isAnimating = false;
  }
}
