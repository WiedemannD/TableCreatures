public class Sound
{
  public static final int TYPE_YAY = 0;

  int type;  
  float x, y;
  String fileName;
  
  AudioPlayer audioPlayer;
  
  Sound(int soundType, float posX, float posY)
  {
    type = soundType;
    x = posX;
    y = posY;
    fileName = getFileName();
    
    audioPlayer = minim.loadFile("data/sounds/" + fileName, 2048);
    audioPlayer.setPan(map(x, 0, vWidth, -1, 1));
    audioPlayer.play();
    
    // take this object into Processings post loop
    config.main.registerPost(this);
  }
  
  String getFileName()
  {
    String fN = "";
    
    switch(type)
    {
      case TYPE_YAY:
        fN = "yay.wav";
        break;
    }
    
    return fN;
  }
  
  // gets called by Processings post loop
  public void post()
  {
    if(!audioPlayer.isPlaying())
    {
      // always close Minim audio classes when you are done with them
      // ensures that new sounds can be played
      audioPlayer.close();
      
      // remove this from the post loop
      config.main.unregisterPost(this);
    }
  }
}







