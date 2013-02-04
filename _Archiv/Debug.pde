void printCamNames()
{
  String[] cameras = Capture.list();
  
  for(int i = 0; i < cameras.length; i++)
  {
    String currentCamName = cameras[i].substring(5, cameras[i].indexOf(","));
    println("cam: " + currentCamName);
  }
}


void drawStats()
{
  fill(255,152,255);
  rectMode(CORNER);
  rect(5,5,flob.getPresencef()*width,10);
  
  String stats = "fps: "+frameRate+
                 "\nflob.numblobs: "+flobs.size()+
                 "\nflob.thresh:"+config.tresh+" <t/T>"+
                 "\nflob.fade:"+config.fade+"   <f/F>"+
                 "\nflob.om:"+flob.getOm()+" <o>"+
                 "\nflob.image:"+config.videotex+" <i>"+
                 "\nflob.presence:"+flob.getPresencef()+
                 "\nedgeTresh:"+config.edgeTresh+" <e/E>"+
                 "\nposDiscrimination:"+config.posDiscrimination+" <p>"+
                 "\n\nset background <b>"+
                 "\nsave config <s>"+
                 "\nset background AND save config <space>";
  fill(0,255,0);
  text(stats,5,25);
}

void drawFlobs()
{
  fill(255,100);
  stroke(255,200);
  rectMode(CENTER);
  
  for(int i = 0; i < flobs.size(); i++) {
    trackedBlob tb = flob.getTrackedBlob(i);
   
    String txt = "id: "+tb.id+" time: "+tb.presencetime+" pixelcount: "+tb.pixelcount;
    float velmult = 100.0f;
    fill(220,220,255,100);
    rect(tb.cx,tb.cy,tb.dimx,tb.dimy);
    fill(0,255,0,200);
    rect(tb.cx,tb.cy, 5, 5); 
    fill(0);
    line(tb.cx, tb.cy, tb.cx + tb.velx * velmult ,tb.cy + tb.vely * velmult ); 
    text(txt,tb.cx -tb.dimx*0.10f, tb.cy + 5f);   
  }
}

void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  noFill();
  Blob b;
  EdgeVertex eA,eB;
  for (int n = 0 ; n < blobDetection.getBlobNb() ; n++)
  {
    b = blobDetection.getBlob(n);
    if (b!=null)
    {
      // Edges
      if (drawEdges)
      {
        strokeWeight(3);
        stroke(0,255,0);
        for (int m = 0; m < b.getEdgeNb(); m++)
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
            line(
              eA.x*width, eA.y*height, 
              eB.x*width, eB.y*height
              );
        }
      }

      // Blobs
      if (drawBlobs)
      {
        rectMode(CORNER);
        strokeWeight(1);
        stroke(255,0,0);
        rect(
          b.xMin*width,b.yMin*height,
          b.w*width,b.h*height
          );
      }
    }
  }
}

void drawTrackedObjects(boolean drawBlobs, boolean drawEdges, boolean drawCenters)
{
  TrackedObject tO;
  
  for(int i = 0; i < trackedObjects.size(); i++)
  {
    tO = (TrackedObject) trackedObjects.get(i);
    tO.draw(drawBlobs, drawEdges, drawCenters);
  }
}
