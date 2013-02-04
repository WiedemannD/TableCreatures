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
  o.fill(255,152,255);
  o.rectMode(CORNER);
  o.rect(5,5,flob.getPresencef()*width,5);
  
  String stats = "fps: "+frameRate+
                 "\ncreatures: "+creatures.size()+
                 "\ncreatureExcess: "+config.creatureExcess+" <x/X>"+
                 "\ngroundEffects: "+groundEffects.size()+
                 "\ntrackObjects: "+trackedObjects.size()+
                 "\nflob.thresh:"+config.tresh+" <t/T>"+
                 "\nflob.fade:"+config.fade+"   <f/F>"+
                 "\nflob.om:"+flob.getOm()+" <o>"+
                 "\nflob.image:"+config.videotex+" <i>"+
                 "\nflob.presence:"+flob.getPresencef()+
                 "\nedgeTresh:"+config.edgeTresh+" <e/E>"+
                 "\nposDiscrimination:"+config.posDiscrimination+" <p>"+
                 "\n\nset background <b>"+
                 "\ntoggle keystone mode <k>"+
                 "\ncreate random creature <c>"+
                 "\ncreate random creature in the center <C>"+
                 "\nremove all creatures <r>"+
                 "\ntoggle debug info <d>"+
                 "\nsave config AND save keystone <s>"+
                 "\nset background AND save config AND save keystone <space>";
  o.textSize(14);
  o.fill(255);
  o.text(stats, 5, 25);
}

void drawFlobs()
{
  o.fill(255,100);
  o.stroke(255,200);
  o.rectMode(CENTER);
  
  for(int i = 0; i < flobs.size(); i++) {
    trackedBlob tb = flob.getTrackedBlob(i);
   
    String txt = "id: "+tb.id+" time: "+tb.presencetime+" pixelcount: "+tb.pixelcount;
    float velmult = 100.0f;
    o.fill(220,220,255,100);
    o.rect(tb.cx,tb.cy,tb.dimx,tb.dimy);
    o.fill(0,255,0,200);
    o.rect(tb.cx,tb.cy, 5, 5); 
    o.fill(0);
    o.line(tb.cx, tb.cy, tb.cx + tb.velx * velmult ,tb.cy + tb.vely * velmult ); 
    o.text(txt,tb.cx -tb.dimx*0.10f, tb.cy + 5f);   
  }
}

void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  o.noFill();
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
        o.strokeWeight(3);
        o.stroke(0,255,0);
        for (int m = 0; m < b.getEdgeNb(); m++)
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
            o.line(
              eA.x*width, eA.y*height, 
              eB.x*width, eB.y*height
              );
        }
      }

      // Blobs
      if (drawBlobs)
      {
        o.rectMode(CORNER);
        o.strokeWeight(1);
        o.stroke(255,0,0);
        o.rect(
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


