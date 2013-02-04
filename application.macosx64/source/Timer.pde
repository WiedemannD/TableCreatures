import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class Timer
{
  PApplet main;
  float t;
  String fName;
  float startTime;
  float endTime;
  Object o;
  Method m;
  
  Timer(PApplet pApplet, float time, Object obj, String fctnName)
  {
    main = pApplet;
    t = time;
    o = obj;
    fName = fctnName;
    setAction(o, fName);
    
    startTime = millis();
    endTime = startTime + (time * 1000);
    
    main.registerPre(this);
  }
  
  /////////////////
  // have a look at the following for more understanding auf pre, post, draw etc. and registerPre etc.: http://www.processing.org/discourse/beta/num_1187919231.html
  /////////////////
  public void pre()
  {
    if(millis() >= endTime)
    {
      performAction();
      main.unregisterPre(this);
    }
  }
  
  /////////////////
  // code below from ewjordan: http://www.processing.org/discourse/beta/num_1187919231.html
  /////////////////
  void setAction(Object object, String method){
    if (method != null && !method.equals("") && o != null){
      try{
    m = o.getClass().getMethod(method, null);
      } catch (SecurityException e){
    e.printStackTrace();
      } catch (NoSuchMethodException e){
    e.printStackTrace();
      }
    }
  }
  
  void performAction(){
    if (m == null || o == null) return;
    try{
      m.invoke(o, null);
    } catch (Exception e){
      e.printStackTrace();
    }
  }
}
