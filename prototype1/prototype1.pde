
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
float img_scale;
ArrayList<PVector> svgVrts;

Tracking tracker;

Minim minim;
AudioPlayer backgroundMusic;
AudioPlayer pentanana_hit_sound;

PImage backgroundImg;
// A reference to our box2d world
Box2DProcessing box2d;

// An ArrayList of particles that will fall on the surface
ArrayList<Fruit> fruits;

// An object to store information about the uneven surface
Bowl bowl;



void setup() {
  size(1920, 1080, P3D);
  background(175, 238, 238);
  smooth(4);
  colorMode(RGB, 255, 255, 255, 100);
  tracker = new Tracking(this);
  
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
  //bowl = new ArrayList<Bowl>();
  
  
  //Listen for collisions
  box2d.listenForCollisions();
  
}

void draw() {
  // If the mouse is pressed, we make new particles
  if (random(6) < 0.5) {
    float w = random(5,10);
    float h = random(5,10);
    fruits.add(new Fruit(random(0, width),-60,box2d,fruit_images[0],0));
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
  
  for (int i=0; i<tracker.getBodySize(); i++) 
  {
    //tracker.drawSkeleton(tracker.bodies.get(i));
    
    println("Left hand: "+tracker.getLeftHandPos(tracker.bodies.get(i)));
    println("Right hand: "+tracker.getRightHandPos(tracker.bodies.get(i)));
    PVector posRight = tracker.getRightHandPos(tracker.bodies.get(i));
    PVector posLeft = tracker.getLeftHandPos(tracker.bodies.get(i));
    
    
    if(posLeft == null || posRight == null)
    {
     /*if (bowl != null) {
       bowl.destroyBowl();
     }*/
    }
    else
    {
      if (bowl == null) 
      {
        bowl = new Bowl(box2d);
      }
      ellipse(posRight.x,posRight.y,10,10);
      ellipse(posLeft.x,posLeft.y,10,10);
      //Update bowl position
      bowl.update(posLeft, posRight);
      
      // Draw the surface
      bowl.display();
      
    }
    
    
    
    if(posLeft != null || posRight != null && bowl != null) 
    {
      bowl.displayFront();
    }
     
  }
  
  // Draw all particles
  for (Fruit p: fruits) {
    p.display();
  }
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
  
  ///Hit sound trigger
  if(o1.getClass() == Fruit.class || o2.getClass() == Fruit.class)
  {
    if(o1.getClass() == RectangleBody.class)
    {
      Fruit f = (Fruit)o2;
      if(f.body.getLinearVelocity().y < -5)
      {
        if(!f.hasCollided())
        {
          pentanana_hit_sound.play(0);
          f.collision();
        }
      }
      
    }
    else if(o2.getClass() == RectangleBody.class)
    {
      Fruit f = (Fruit)o1;
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
  }
  
  if(o2.getClass() == Fruit.class && o1.getClass() == CircleBody.class)
  {
    Fruit fruit2 = (Fruit)o2;
    CircleBody c1 = (CircleBody)o1;
    fruit2.bowlCollision(c1.getPos());
  }
  
  if(o1.getClass() == Fruit.class && o2.getClass() == Fruit.class)
  {
    
    Fruit fruit1 = (Fruit)o1;
    Fruit fruit2 = (Fruit)o2;
    
    if(fruit2.hasCollidedWithBowl())
    {
      //fruit1.bowlCollision(new Vec2(bowl.getPos().x,fruit2.getPos().y));
    }
    
    if(fruit1.hasCollidedWithBowl())
    {
      //fruit2.bowlCollision(new Vec2(bowl.getPos().x,fruit1.getPos().y));
    }
  }
  
}

void endContact(Contact cp)
{
  
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