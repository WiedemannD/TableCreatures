void processNewFrame()
{
  video.read();
  videoinput.copy(video, camZoomAspect(4), camZoomAspect(3), cWidth - (camZoomAspect(4) * 2), cHeight - (camZoomAspect(3) * 2), 0, 0, config.videores, config.videores);
  //flobs = flob.track(flob.binarize(videoinput)); // flob.track seems not able to handle multiple trackedBlobs for longer???? 
  flobs = flob.calcsimple(flob.binarize(videoinput));
  
  
  videoinputBD.copy(video, camZoomAspect(4), camZoomAspect(3), cWidth - (camZoomAspect(4) * 2), cHeight - (camZoomAspect(3) * 2), 0, 0, config.videores, config.videores); // uses original videoinput, adjust edgeTresh!!!
  //videoinputBD.copy(flob.getSrcImage(), 0, 0, cWidth, cHeight, 0, 0, config.videores, config.videores); // uses difference optimized image from flob, adjust edgeTresh!!!
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
    //o.rect(tb.cx,tb.cy,tb.dimx,tb.dimy);
    
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
        float bX = b.xMin*width + (b.w*width / 2);
        float bY = b.yMin*height + (b.h*height / 2);
        float bW = b.w*width;
        float bH = b.h*height;
        
        // a trackedObject has to be created
        if(bX >= fXMin && bX <= fXMax && bY >= fYMin && bY <= fYMax) 
        {
          
          float dX = average(f.cx, bX);  
          float dY = average(f.cy, bY);
          float dW = average(f.dimx, bW);
          float dH = average(f.dimy, bH);
          Boolean occupied = false;

          // look for near creatures to set trackedObjects to occupied
          for(int j = 0; j < creatures.size(); j++)
          {
            Creature c = (Creature) creatures.get(j);
            
            if(dist(dX, dY, c.x, c.y) < occupationDist)
            {
              occupied = true;
              break;
            }
          }
          
          trackedObjects.add(new TrackedObject(f, b, dX, dY, dW, dH, occupied));
          
          break;
        }
      }
    }   
  }
}

void populateCreatures()
{
  if(populateCreatures && creatures.size() < trackedObjects.size() + config.creatureExcess)
  {
    creatures.add(new Creature(true, null, -1, false));
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

void drawGroundEffects()
{
  for(int i = 0; i < groundEffects.size(); i++)
  {
    GroundEffect gE = (GroundEffect) groundEffects.get(i);
    gE.draw();
  }
}
