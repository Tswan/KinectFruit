import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;
import ddf.minim.*; //used for music
import org.jbox2d.dynamics.joints.*;

PImage pentanana_img;
float img_scale;
ArrayList<PVector> svgVrts;

Tracking tracker;

Minim minim;
AudioPlayer backgroundMusic;

PImage backgroundImg;
// A reference to our box2d world
Box2DProcessing box2d;

// An ArrayList of particles that will fall on the surface
ArrayList<Fruit> fruits;

// An object to store information about the uneven surface
Bowl bowl;

void setup() {
  background(175, 238, 238);
  size(1920, 1080);
  smooth(4);
  colorMode(RGB, 255, 255, 255, 100);
  tracker = new Tracking(this);
  
  //Music initialization
  minim = new Minim(this);
  backgroundMusic = minim.loadFile("alpha_musicBg.mp3");
  backgroundMusic.loop();
  
  backgroundImg = loadImage("backgroundImg.png");
  pentanana_img = loadImage("PENTANANA_500.png");

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -10);

  // Create the empty list
  fruits = new ArrayList<Fruit>();
  // Create the surface
  bowl = new Bowl(box2d);
}

void draw() {
  // If the mouse is pressed, we make new particles
  if (random(1) < 0.5) {
    float w = random(5,10);
    float h = random(5,10);
    fruits.add(new Fruit(random(0, width),-20,box2d));
  }

  // We must always step through time!
  

  background(255);
  image(backgroundImg, 0, 0);
  

  // Draw all particles
  println(fruits.size());
  for (Fruit p: fruits) {
    p.display();
  }
  

  // Particles that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = fruits.size()-1; i >= 0; i--) {
    Fruit p = fruits.get(i);
    if (p.isOffScreen()) {
      fruits.remove(i);
    }
  }
  
  box2d.step();

  // Just drawing the framerate to see how many particles it can handle
  fill(0);
  text("framerate: " + (int)frameRate,12,16);
  
  PVector posRight = null;
  PVector posLeft = null;
    for (int i=0; i<tracker.getBodySize(); i++) 
    {
      print("Left hand: "+tracker.getLeftHandPos());
      print("Right hand: "+tracker.getRightHandPos());
      posRight = tracker.getRightHandPos();
      posLeft = tracker.getLeftHandPos();
    }
  if(posLeft == null || posRight == null)
  {
   // print("it's null");
  }
  else
  {
    ellipse(posRight.x,posRight.y,10,10);
    ellipse(posLeft.x,posLeft.y,10,10);
    
    bowl.update(posLeft, posRight);
    // Draw the surface
    bowl.display();
  }
  
  //bowl.display();
}

//Kinect Events Similar to MousePressed, must be kept
void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(tracker.getBodies()) {
    tracker.addJoint(_s);
  }
}

void disappearEvent(SkeletonData _s) 
{
  synchronized(tracker.getBodies()) {
    for (int i=tracker.getBodySize()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == tracker.getBodyData(i).dwTrackingID) 
      {
        tracker.removeJoint(i);
      }
    }
  }
}

void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(tracker.getBodies()) {
    for (int i=tracker.getBodySize()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == tracker.getBodyData(i).dwTrackingID) 
      {
        tracker.updateJoint(i,_a);
        break;
      }
    }
  }
}