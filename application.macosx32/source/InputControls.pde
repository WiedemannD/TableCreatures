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
  
  if(key == 'd') // enter/leave calibration mode, where surfaces can be warped and moved
  {
    if(!config.debug)
    {
      config.debug = true;
    }
    else
    {
      config.debug = false;
    }
  }
  
  if(key == 'c') // create random creature
  {
    creatures.add(new Creature(true, null, -1, false));
  }
  
  if(key == 'C') // create random creature in the center 
  {
    Creature c = new Creature(true, null, -1, false);
    c.x = width/2;
    c.y = height/2;
    creatures.add(c);
  }
  
  if(key == 'r') // remove all creatures
  {
    creatures = new ArrayList();
    groundEffects = new ArrayList();
  }
  
  if(key=='x') // decrease creatureExcess
  {
    config.creatureExcess--;
  }
  
  if(key=='X') // increase creatureExcess
  {
    config.creatureExcess++;
  }
}

void setBackgroundImage()
{
  backgroundImage = createImage(config.videores, config.videores, RGB);
  backgroundImage.copy(videoinput, 0, 0, videoinput.width, videoinput.height, 0, 0, videoinput.width, videoinput.height);
  
  flob.setBackground(backgroundImage);
  
  println("backgroundImage set");
}

void mouseClicked() 
{
  if(config.debug && mouseKlickSound)
  {
    Sound s = new Sound(Sound.TYPE_YAY, mouseX, mouseY);
  }
}
















