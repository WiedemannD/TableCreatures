void processNewFrame()
{
  video.read();
  videoinput.copy(video, 0, 0, cWidth, cHeight, 0, 0, config.videores, config.videores);
  //flobs = flob.track(flob.binarize(videoinput)); // flob.track seems not able to handle multiple trackedBlobs for longer???? 
  flobs = flob.calcsimple(flob.binarize(videoinput));
  
  videoinputBD.copy(video, 0, 0, cWidth, cHeight, 0, 0, config.videores, config.videores);
  fastblur(videoinputBD, 2);
  blobDetection.computeBlobs(videoinputBD.pixels);
}

void setTrackedObjects()
{
  trackedObjects = new ArrayList();
  
  trackedBlob f;
  Blob b;
  
  // flobs
  for(int i = 0; i < flobs.size(); i++) 
  {
    f = flob.getTrackedBlob(i);
    //rect(tb.cx,tb.cy,tb.dimx,tb.dimy);
    
    float fXMin = f.cx - (f.dimx / 2);
    float fXMax = f.cx + (f.dimx / 2);
    float fYMin = f.cy - (f.dimy / 2);
    float fYMax = f.cy + (f.dimy / 2);
    
    // blobs
    for (int n = 0 ; n < blobDetection.getBlobNb() ; n++)
    {
      b = blobDetection.getBlob(n);
      
      if (b!=null)
      {
        //b.xMin*width, b.yMin*height, b.w*width, b.h*height
        
        float bX = b.xMin*width + (b.w*width / 2);
        float bY = b.yMin*height + (b.h*height / 2);
        float bW = b.w*width;
        float bH = b.h*height;
        
        //println("test3: bX "+bX+" fXMin "+fXMin+" fXMax "+fXMax+" bY "+bY+" fYMin "+fYMin+" fYMax "+fYMax);
        
        if(bX >= fXMin && bX <= fXMax && bY >= fYMin && bY <= fYMax)
        {
          /*
          rectMode(CENTER);
          stroke(0, 0, 255);
          rect(bX, bY, bW, bH);
          
          rectMode(CENTER);
          stroke(0, 255, 0);
          rect(f.cx, f.cy, f.dimx, f.dimy);
          */
          
          float dX = average(f.cx, bX);  
          float dY = average(f.cy, bY);
          float dW = average(f.dimx, bW);
          float dH = average(f.dimy, bH);
          
          trackedObjects.add(new TrackedObject(f, b, dX, dY, dW, dH));
          
          break;
        }
      }
    }   
  }
}

void drawCreatures()
{
  for(int i = 0; i < creatures.size(); i++)
  {
    Creature c = (Creature) creatures.get(i);
    c.draw();
  }
}
