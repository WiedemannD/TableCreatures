class Config
{
  ///////////////
  // to add config vars: edit varCount and varNames, add var, edit functions save and load (yeah I know this sucks ...)
  ///////////////
  
  int varCount = 10;
  String[] varNames = {"tresh", "fade", "om", "videores", "videotex", "trackedBlobLifetime", "edgeTresh", "posDiscrimination", "debug", "creatureExcess"};
  
  // Flob vars
  int tresh = 32;
  int fade = 25;
  int om = 0;
  int videores = 128;
  int videotex = 0;//3
  int trackedBlobLifetime = 5;
  
  // BlobDetection vars
  float edgeTresh = 0.35;
  Boolean posDiscrimination = true;
  
  // general vars
  Boolean debug;
  int creatureExcess;
  
  // objects for general use
  PApplet main;
  PImage heartOutline;
  PImage type_1;
  
  Config(PApplet m)
  {
    main = m;
    load();
    ks.load();
    
    heartOutline = loadImage("data/heartOutline.png");
    type_1 = loadImage("data/type_1.png");
  }
  
  
  void save()
  {
     String[] varsToSave = new String[varCount];
     
     varsToSave[0] = varNames[0] + " = " + tresh;
     varsToSave[1] = varNames[1] + " = " + fade;
     varsToSave[2] = varNames[2] + " = " + om;
     varsToSave[3] = varNames[3] + " = " + videores;
     varsToSave[4] = varNames[4] + " = " + videotex;
     varsToSave[5] = varNames[5] + " = " + trackedBlobLifetime;
     varsToSave[6] = varNames[6] + " = " + edgeTresh;
     varsToSave[7] = varNames[7] + " = " + posDiscrimination;
     varsToSave[8] = varNames[8] + " = " + debug;
     varsToSave[9] = varNames[9] + " = " + creatureExcess;
     
     saveStrings("data/config.txt", varsToSave);
     
     backgroundImage.save(savePath("data/backgroundImage.tif"));
     //backgroundImage.save("data/backgroundImage.tif");
     
     println("config saved");
  }
  
  void load()
  {
    backgroundImage = loadImage("data/backgroundImage.tif");
    
    String[] varsLoaded = loadStrings("data/config.txt");
    
    tresh =                 Integer.parseInt(getSavedValue(varsLoaded[0]));
    fade =                  Integer.parseInt(getSavedValue(varsLoaded[1]));
    om =                    Integer.parseInt(getSavedValue(varsLoaded[2]));
    videores =              Integer.parseInt(getSavedValue(varsLoaded[3]));
    videotex =              Integer.parseInt(getSavedValue(varsLoaded[4]));
    trackedBlobLifetime =   Integer.parseInt(getSavedValue(varsLoaded[5]));
    edgeTresh =             float(getSavedValue(varsLoaded[6]));
    posDiscrimination =     boolean(getSavedValue(varsLoaded[7]));
    debug =                 boolean(getSavedValue(varsLoaded[8]));
    creatureExcess =        Integer.parseInt(getSavedValue(varsLoaded[9]));
  }
  
  String getSavedValue(String str)
  {
    str = str.substring(str.indexOf(" ") + 3, str.length());
    return str;
  }
  
  void reset()
  {
  
  }
}


