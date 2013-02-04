import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;

import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.json.*;
import twitter4j.internal.util.*;
import twitter4j.management.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;
import twitter4j.internal.json.*;

public class Tweets extends Thread
{
  // Thread vars
  boolean running;                   // Is the thread running?  Yes or no?
  boolean available;                 // is tweets available for others to request
  int pollingTime = 12 * 1000;       // How many milliseconds should we wait in between executions?
  String id = "Tweets";              // Thread name
  Boolean printTweets = false;

  // class/twitter vars
  String querySearchParam = "#TableCreatures OR #CreativeTechnology";
  int reqPerPage = 100;
  
  ArrayList tweets = new ArrayList();
  ConfigurationBuilder cb;
  Twitter twitter;
  Query query;
  
  Tweets()
  {
    running = false;
  }
  
  void start()
  {
    ///////////////
    // Twitter stuff
    ///////////////
   
    cb = new ConfigurationBuilder();
    cb.setOAuthConsumerKey("1ENhhsQmb0LXAc5po5qUBw");
    cb.setOAuthConsumerSecret("WWgm27yiOW2jxSjZ0ynMjTJ6lvscL5MW3mG62X7Os");
    cb.setOAuthAccessToken("68431437-otUPCszca9s8w07zavTU7Oyily5nsviOWxDNjiNiK");
    cb.setOAuthAccessTokenSecret("YVfiCY9O5aeE4cdvsd8WBlueXtxJc18LI1zDvWuhHI");
    
    twitter = new TwitterFactory(cb.build()).getInstance();
    query = new Query(querySearchParam);
    query.setCount(reqPerPage);
    
    
    ///////////////
    // Thread stuff
    ///////////////
    
    running = true;
    super.start();
  } 
    
  void run()
  {
    while(running)
    {
      //Try making the query request.
      try 
      {
        QueryResult result = twitter.search(query);
        ArrayList stati = (ArrayList) result.getTweets();
        
        saveStatiToTweets(stati);
        
        if(printTweets)
        {
          println("Tweets: successfully received and saved " + tweets.size() + " tweets.");
        }
      }
      catch (TwitterException te) 
      {
        loadSavedTweets();
        
        if(printTweets)
        {
          println("Tweets: Couldn't connect: " + te);
          println("Tweets: Saved tweets (" + tweets.size() + ") were loaded.");
        }
      }
      
      available = true;
      
      if(printTweets)
      {
        printTweets();
      }
      
      // Ok, let's wait for however long we should wait
      try 
      {
        sleep((long)(pollingTime));
      } 
      catch (Exception e)
      {
        println("Tweets: Thread sleep error: " + e);
      }
    }
  }
  
  void saveStatiToTweets(ArrayList stati)
  {
    tweets = new ArrayList();
    String[] lines = {};
    
    for(int i = 0; i < stati.size(); i++)
    {
      Status t = (Status) stati.get(i);
      
      lines = append(lines, t.getUser().getScreenName());
      lines = append(lines, t.getText());
      
      SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss dd/MM/yyyy");
      lines = append(lines, format.format(t.getCreatedAt()));
      
      tweets.add(new TweetsTweet(t.getUser().getScreenName(), t.getText(), format.format(t.getCreatedAt())));
    }
    
    saveStrings("data/tweets.json", lines);
  }
  
  void loadSavedTweets()
  {
    String[] lines = loadStrings("data/tweets.json");
    tweets = new ArrayList();
    
    for(int i = 0; i < lines.length; i++)
    {
      tweets.add(new TweetsTweet(lines[i], lines[i + 1], lines[i + 2]));
      
      i = i + 2;
    }
  }
  
  void printTweets()
  {
    for (int i = 0; i < tweets.size(); i++) 
    {
      TweetsTweet t = (TweetsTweet) tweets.get(i);
      String user = t.user;//t.getUser();
      String msg = t.text;//t.getText();
      String d = t.date;//t.getDate();
      println("Tweet by " + user + " at " + d + ": " + msg);
    }
  }
  
  boolean isAvailable() 
  {
    return available;
  }
  
  // Our method that quits the thread
  void quit() {
    running = false;  // Setting running to false ends the loop in run()
    // In case the thread is waiting. . .
    interrupt();
  }
}


class TweetsTweet
{
  String user;
  String text;
  String date;
  
  TweetsTweet(String u, String m, String d)
  {
    user = u;
    text = m;
    date = d;
  }
  
  String getUser()
  {
    return user;
  }
  
  String getText()
  {
    return text;
  }
  
  String getDate()
  {
    return date;
  }
}











