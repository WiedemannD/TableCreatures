void keyPressed(){
  if (key=='i') 
  {  
    config.videotex = (config.videotex+1)%4;
    flob.setImage(config.videotex);
  }
  
  if(key=='t') 
  {
    config.tresh--;
    flob.setTresh(config.tresh);
  }
  
  if(key=='T') 
  {
    config.tresh++;
    flob.setTresh(config.tresh);
  }   
  
  if(key=='f') 
  {
    config.fade--;
    flob.setFade(config.fade);
  }
  
  if(key=='F') 
  {
    config.fade++;
    flob.setFade(config.fade);
  }   
  
  if(key=='o') 
  {
    config.om=(config.om +1) % 3;
    flob.setOm(config.om);
  }   
  
  if(key=='e') 
  {
    config.edgeTresh = config.edgeTresh - 0.01;
    blobDetection.setThreshold(config.edgeTresh);
  }
  
  if(key=='E') 
  {
    config.edgeTresh = config.edgeTresh + 0.01;
    blobDetection.setThreshold(config.edgeTresh);
  }
  
  if(key=='p') 
  {
    if(config.posDiscrimination)
    {
      config.posDiscrimination = false;
    }
    else
    {
      config.posDiscrimination = true;
    }
    
    blobDetection.setPosDiscrimination(config.posDiscrimination);
  }
  
  if(key=='b')
  {
    setBackgroundImage();
  } 
    
  if(key == 's') // saves config and keystone
  {
    config.save();
    ks.save();
  }
  
  if(key == ' ') // set Background AND save config AND keystone
  {
    setBackgroundImage();
    config.save();
    ks.save();
  }
  
  if(key == 'k') // enter/leave calibration mode, where surfaces can be warped and moved
  {
    ks.toggleCalibration();
  }
}

void setBackgroundImage()
{
  backgroundImage = createImage(config.videores, config.videores, RGB);
  backgroundImage.copy(videoinput, 0, 0, videoinput.width, videoinput.height, 0, 0, videoinput.width, videoinput.height);
  
  flob.setBackground(backgroundImage);
  
  println("backgroundImage set");
}
