import ddf.minim.*;

import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;
import ddf.minim.*; //used for music
import org.jbox2d.dynamics.joints.*;

//For adding in mulitiple images of the fruit
PImage[] fruit_images;

//Tracking tracker;
Minim minim;
AudioPlayer backgroundMusic;
AudioPlayer pentanana_hit_sound;

PImage backgroundImg;
// A reference to our box2d world
Box2DProcessing box2d;

// An ArrayList of particles that will fall on the surface
ArrayList<Fruit> fruits;

PVector[] posRight = new PVector[2];
PVector[] posLeft = new PVector[2];

Bowl[] bowl = new Bowl[2];

void setup() {
  size(1920, 1080, P3D);
  background(175, 238, 238);
  smooth(4);
  colorMode(RGB, 255, 255, 255, 100);
  //tracker = new Tracking(this);
  
  bowl[0] = null;
  bowl[1] = null;
  
  posRight[0] = null;
  posRight[1] = null;
  
  posLeft[0] = null;
  posLeft[1] = null;
  
  //Music initialization
  minim = new Minim(this);
  backgroundMusic = minim.loadFile("alpha_musicBg_original.mp3");
  backgroundMusic.loop();
  
  pentanana_hit_sound = minim.loadFile("bananaHits/banana_hit_2.mp3");
  
  backgroundImg = loadImage("backgroundImg2.png");
  fruit_images = new PImage[6];
  fruit_images[0] = loadImage("banana.png");
  fruit_images[1] = loadImage("coconut.png");
  fruit_images[2] = loadImage("orange.png");
  fruit_images[3] = loadImage("apple.png");
  fruit_images[4] = loadImage("strawberry.png");

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -10);

  // Create the empty list
  fruits = new ArrayList<Fruit>();
  // Create the surface
  //bowl = new Bowl(box2d);
  box2d.listenForCollisions();
  
  posLeft[0] = new PVector(200, 500);
}

void draw() {
  // If the mouse is pressed, we make new particles
  if ((int) random(0, 10) == 1) {
    float w = random(5,10);
    int fruitIdx = (int) random(0,5);
    // make the coconut less frequent
    if (fruitIdx == 1) {
      int addedRand = (int) random(0, 5);
      if (addedRand != 1) {
        fruitIdx = addedRand;
      }
    }
    fruits.add(new Fruit(random(0, width),-100,box2d,fruit_images[fruitIdx],fruitIdx));//So we can have a randome value the corisponds to the fruit image and the fruit being made
  }

  background(255);
  image(backgroundImg, 0, 0);
  
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
  
  posRight[0] = new PVector(mouseX, mouseY);
  
  for (int x = 0; x < posLeft.length; x++) {
    if (posLeft[x] != null && posRight[x] != null) {
      if (bowl[x] == null) {
        bowl[x] = new Bowl(box2d, x);
      } else {
        ellipse(posRight[x].x,posRight[x].y,10,10);
        ellipse(posLeft[x].x,posLeft[x].y,10,10);
        bowl[x].update(posLeft[x], posRight[x]);
        // Draw the surface
        bowl[x].display();
      }
    } else if(posLeft[x] == null || posRight[x] == null) {
     if (bowl[x] != null) {
       bowl[x].destroyBowl();
     }
    }
  }
  // Draw all particles
  //println(fruits.size());
  for (Fruit p: fruits) {
    p.display();
  }
  
  for (int y = 0; y < posLeft.length; y++) {
    if(posLeft[y] != null || posRight[y] != null && bowl[y] != null) {
      bowl[y].displayFront();
    }
  }
  //bowl.display();
}

//Collision Detection
void beginContact(Contact cp)
{
  
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  //Hit sound trigger
  if(o1.getClass() == Fruit.class || o2.getClass() == Fruit.class)
  {
    if(o1.getClass() == CircleBody.class)
    {
      Fruit f = (Fruit)o2;
      CircleBody c = (CircleBody) o1;
      if(f.body.getLinearVelocity().y < -5)
      {
        if(!f.hasCollided())
        {
          pentanana_hit_sound.play(0);
          f.collision();
        }
      }
    }
    else if(o2.getClass() == CircleBody.class)
    {
      Fruit f = (Fruit)o1;
      CircleBody c = (CircleBody) o2;
      if(f.body.getLinearVelocity().y < -5)
      {
        if(!f.hasCollided())
        {
          pentanana_hit_sound.play(0);
          f.collision();
        }
      }
    }
  }
  
  //Sticking trigger
  if(o1.getClass() == Fruit.class && o2.getClass() == CircleBody.class)
  {
    Fruit fruit1 = (Fruit)o1;
    CircleBody c2 = (CircleBody)o2;
    fruit1.bowlCollision(c2.getPos());
    fruit1.setBowlCollidedIndex(c2.getBowlIndex());
  }
  
  if(o2.getClass() == Fruit.class && o1.getClass() == CircleBody.class)
  {
    Fruit fruit2 = (Fruit)o2;
    CircleBody c1 = (CircleBody)o1;
    fruit2.bowlCollision(c1.getPos());
    fruit2.setBowlCollidedIndex(c1.getBowlIndex());
  }
  
  if(o1.getClass() == Fruit.class && o2.getClass() == Fruit.class)
  {
    
    Fruit fruit1 = (Fruit)o1;
    Fruit fruit2 = (Fruit)o2;
    
    if(fruit2.hasCollidedWithBowl())
    {
      fruit1.bowlCollision(new Vec2(bowl[fruit2.getBowlCollidedIndex()].getPos().x,fruit2.getPos().y));
      fruit1.setBowlCollidedIndex(fruit2.getBowlCollidedIndex());
    }
    
    if(fruit1.hasCollidedWithBowl())
    {
      fruit2.bowlCollision(new Vec2(bowl[fruit1.getBowlCollidedIndex()].getPos().x,fruit1.getPos().y));
      fruit2.setBowlCollidedIndex(fruit1.getBowlCollidedIndex()); 
    }
  }
}

void endContact(Contact cp)
{
  /*
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  if(o1.getClass() == Fruit.class && o2.getClass() == Fruit.class)
  {
    
    Fruit fruit1 = (Fruit)o1;
    Fruit fruit2 = (Fruit)o2;
    
    if(fruit1.hasCollidedWithBowl())
    {
      fruit1.bowlCollisionEnd();
      
    }
    if(fruit2.hasCollidedWithBowl())
    {
      fruit2.bowlCollisionEnd();
    }
  }*/
}


/*
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
*/