public class Sound
{
  // occupy 
  public static final int TYPE_YAY = 0;
  public static final int TYPE_YAY2 = 1;
  
  // unoccupy
  public static final int TYPE_WOHO = 2;
  public static final int TYPE_WOHO2 = 3;
  
  // growing
  public static final int TYPE_WEE = 4;
  public static final int TYPE_WEE2 = 5;
  
  // mating
  public static final int TYPE_MATING = 6;
  // tweeting
  public static final int TYPE_TWEET = 7;
  // dying --> splash
  public static final int TYPE_SMACK = 8;
  
  // fighting
  public static final int TYPE_UHOH = 9;
  public static final int TYPE_AWW = 10;
  public static final int TYPE_UHOH2 = 11;
  
  // random movement
  public static final int TYPE_SINGING = 12;
  public static final int TYPE_SINGING2 = 13;
  public static final int TYPE_GIGGLE = 14;
  public static final int TYPE_GIGGLE2 = 15;
  public static final int TYPE_GIGGLE3 = 16;
  
  
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
      
      case TYPE_YAY2:
        fN = "yay2.wav";
        break;
        
      case TYPE_WOHO:
        fN = "woho.wav";
        break;
        
      case TYPE_WOHO2:
        fN = "woho2.wav";
        break;
        
      case TYPE_WEE:
        fN = "wee.wav";
        break;
        
      case TYPE_WEE2:
        fN = "wee2.wav";
        break;
        
      case TYPE_MATING:
        fN = "mating.wav";
        break;
        
      case TYPE_TWEET:
        fN = "tweet.wav";
        break;
        
      case TYPE_SMACK:
        fN = "smack.wav";
        break;
        
      case TYPE_UHOH:
        fN = "uhoh.wav";
        break;
        
      case TYPE_AWW:
        fN = "aww.wav";
        break;
      
      case TYPE_UHOH2:
        fN = "uhoh2.wav";
        break;
        
      case TYPE_SINGING:
        fN = "singing.wav";
        break;
        
      case TYPE_SINGING2:
        fN = "singing2.wav";
        break;
        
      case TYPE_GIGGLE:
        fN = "giggle.wav";
        break;
        
      case TYPE_GIGGLE2:
        fN = "giggle2.wav";
        break;
        
      case TYPE_GIGGLE3:
        fN = "giggle3.wav";
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







