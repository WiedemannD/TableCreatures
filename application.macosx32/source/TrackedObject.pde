class TrackedObject
{
  float x, y, w, h;
  Boolean occupied = false;
  
  trackedBlob flob;
  Blob blob;
  
  TrackedObject(trackedBlob f, Blob b, float posX, float posY, float oWidth, float oHeight, Boolean oc)
  {
    blob = b;
    flob = f;
    x = posX;
    y = posY;
    w = oWidth;
    h = oHeight;
    occupied = oc; 
  }
  
  void draw(boolean drawBlob, boolean drawEdges, boolean drawCenter)
  {
    o.noFill();
    
    // Blobs
    if (drawBlob)
    {
      o.rectMode(CENTER);
      o.strokeWeight(1);
      o.stroke(255,0,0);
      o.rect(x, y, w, h);
    }
    
    // Edges
    if (drawEdges)
    {
      o.strokeWeight(3);
      o.stroke(0,255,0);
      EdgeVertex eA,eB;
      
      for (int m = 0; m < getEdgeNb(); m++)
      {
        eA = getEdgeVertexA(m);
        eB = getEdgeVertexB(m);
        if (eA != null && eB != null)
        {
          o.line(eA.x*width, eA.y*height, eB.x*width, eB.y*height);
        }
      }
    }
    
    // Center
    if(drawCenter)
    {
      o.strokeWeight(3);
      o.stroke(255, 0, 0);
      o.rect(x, y, 10, 10);
    }
  }
  
  int getEdgeNb()
  {
    return blob.getEdgeNb();
  }
  
  EdgeVertex getEdgeVertexA(int iEdge)
  {
    return blob.getEdgeVertexA(iEdge);
  }
  
  EdgeVertex getEdgeVertexB(int iEdge)
  {
    return blob.getEdgeVertexB(iEdge);
  }
}
