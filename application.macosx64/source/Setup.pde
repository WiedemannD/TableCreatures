void setupKeystone()
{
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(vWidth, vHeight, 20);
  o = createGraphics(vWidth, vHeight, OPENGL);
  o.smooth();
  o.rectMode(CENTER);
  o.textFont(font);
}

void setupVideoCapture()
{
  video = new Capture(this, cWidth, cHeight, camName, fps);
  video.start();  
  videoinput = createImage(config.videores, config.videores, RGB);
  videoinputBD = createImage(config.videores, config.videores, RGB);
}

void setupFlob()
{
  flob = new Flob(this, config.videores, config.videores, width, height);
  flob.setOm(config.om);  
  flob.setTresh(config.tresh);
  flob.setThresh(config.tresh);
  flob.setSrcImage(config.videotex);
  flob.settrackedBlobLifeTime(config.trackedBlobLifetime);
  flob.setBlur(0); //new : fastblur filter inside binarize
  flob.setMirror(false,false);
  
  if(backgroundImage != null)
  {
    flob.setBackground(backgroundImage);
  }
}

void setupBlobDetection()
{
  blobDetection = new BlobDetection(config.videores, config.videores);
  blobDetection.setPosDiscrimination(config.posDiscrimination);
  blobDetection.setThreshold(config.edgeTresh);
}

void setupSound()
{
  minim = new Minim(this);
}

void setupTweets()
{
  tweets = new Tweets();
  tweets.start();
}
