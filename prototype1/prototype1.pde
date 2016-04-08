import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;
import ddf.minim.*; //used for music
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import org.jbox2d.dynamics.joints.*;

//For adding in mulitiple images
PImage[] fruit_images;
PImage[] tree_images;
PImage[] fruit_particle_images;
float img_scale;
ArrayList<PVector> svgVrts;

Tracking tracker;

Minim minim;
AudioPlayer backgroundMusic;
AudioPlayer[] fruit_hit_sounds;
AudioPlayer treeGrowingSfx;

PImage backgroundImg;
PImage branchImg;

// A reference to our box2d world
Box2DProcessing box2d;

// An ArrayList of fruit related objects
ArrayList<Fruit> fruits;
ArrayList<Tree> trees;
ArrayList<FruitParticleSystem> explodingFruits;

// hand and elbow position arrays
PVector[] handPosRight = new PVector[2];
PVector[] handPosLeft = new PVector[2];
PVector[] elbowPosRight = new PVector[2];
PVector[] elbowPosLeft = new PVector[2];

// An object to store information about the uneven surface
Bowl[] bowl = new Bowl[2];
Branch[] branchesLeft = new Branch[2];
Branch[] branchesRight = new Branch[2];

void setup() 
{
  size(1280, 800, P3D);
  background(175, 238, 238);
  smooth(4);
  colorMode(RGB, 255, 255, 255, 100);
  tracker = new Tracking(this);
  
  bowl[0] = null;
  bowl[1] = null;
  
  handPosRight[0] = null;
  handPosRight[1] = null;
  
  handPosLeft[0] = null;
  handPosLeft[1] = null;
  
  branchesLeft[0] = null;
  branchesLeft[1] = null;
  branchesRight[0] = null;
  branchesRight[1] = null;
  
  elbowPosRight[0] = null;
  elbowPosRight[1] = null;
   
  elbowPosLeft[0] = null;
  elbowPosLeft[1] = null;
  
  //Music initialization
  minim = new Minim(this);

  backgroundMusic = minim.loadFile("FallingFruit.mp3");
  backgroundMusic.loop();
  
  fruit_hit_sounds = new AudioPlayer[6];
  fruit_hit_sounds[0] = minim.loadFile("hitSounds/Banana_Hitting_Bowl.mp3");
  fruit_hit_sounds[0].setGain(0.0);
  fruit_hit_sounds[1] = minim.loadFile("hitSounds/Coconut_Hitting_Bowl.mp3");
  fruit_hit_sounds[1].setGain(0.0);
  fruit_hit_sounds[2] = minim.loadFile("hitSounds/Orange_Hitting_Bowl.mp3");
  fruit_hit_sounds[2].setGain(0.0);
  fruit_hit_sounds[3] = minim.loadFile("hitSounds/Apple_Hitting_Bowl.mp3");
  fruit_hit_sounds[3].setGain(0.0);
  fruit_hit_sounds[4] = minim.loadFile("hitSounds/Strawberry_Hitting_Bowl.mp3");
  fruit_hit_sounds[4].setGain(0.0);
  fruit_hit_sounds[5] = minim.loadFile("hitSounds/Tree_Branch_Hitting.mp3");
  fruit_hit_sounds[5].setGain(0.0);

  treeGrowingSfx = minim.loadFile("tree_sfx_final.mp3");
  treeGrowingSfx.setGain(0.0);
  
  backgroundImg = loadImage("backgroundImgBlue.png");
  branchImg = loadImage("Tree_Branch.png");
  fruit_images = new PImage[5];
  fruit_images[0] = loadImage("fruitImages/banana.png");
  fruit_images[1] = loadImage("fruitImages/coconut.png");
  fruit_images[2] = loadImage("fruitImages/orange.png");
  fruit_images[3] = loadImage("fruitImages/apple.png");
  fruit_images[4] = loadImage("fruitImages/strawberry.png");
  
  tree_images = new PImage[5];
  tree_images[0] = loadImage("treeImages/Tree_Banana_Final_Small.png");
  tree_images[1] = loadImage("treeImages/Tree_Coconut_Final_Small.png");
  tree_images[2] = loadImage("treeImages/Tree_Orange_Final_Small.png");
  tree_images[3] = loadImage("treeImages/Tree_Apple_Final_Small.png");
  tree_images[4] = loadImage("treeImages/Tree_Strawberry_Final_Small.png");
  
  fruit_particle_images = new PImage[5];
  fruit_particle_images[0] = loadImage("particleImages/Final_Banana_Particle.png");
  fruit_particle_images[1] = loadImage("particleImages/Final_Coconut_Particle.png");
  fruit_particle_images[2] = loadImage("particleImages/Final_Orange_Particle.png");
  fruit_particle_images[3] = loadImage("particleImages/Final_Apple_Particle.png");
  fruit_particle_images[4] = loadImage("particleImages/Final_Strawberry_Particle.png");

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  
  // We are setting a custom gravity
  box2d.setGravity(0, -10);

  // Create the empty list
  fruits = new ArrayList<Fruit>();
  trees = new ArrayList<Tree>();
  explodingFruits = new ArrayList<FruitParticleSystem>();

  //Listen for collisions
  box2d.listenForCollisions();
  
}

void draw() 
{
  // If the mouse is pressed, we make new particles
  if ((int) random(0, 10) == 1) 
  {
    float w = random(5,10);
    int fruitIdx = (int) random(0,5);
    if (fruitIdx == 1) 
    {
      int addedRand = (int) random(0, 5);
      if (addedRand != 1) 
      {
        fruitIdx = addedRand;
      }
    }
    fruits.add(new Fruit(random(0, width),-80,box2d,fruit_images[fruitIdx],fruitIdx));//So we can have a randome value the corisponds to the fruit image and the fruit being made
  }
  background(255);
  image(backgroundImg, 0, -(0.10 * height));
  
  treeReorder();
  if (trees != null) 
  {
    for (Tree tree : trees) 
    {
      tree.display();
    }
  }

  // Particles that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = fruits.size()-1; i >= 0; i--) 
  {
    Fruit p = fruits.get(i);
    if (p.isDead()) 
    {
      p.killBody();
      fruits.remove(i);
    }
    else if (p.isOffScreen()) 
    {
      p.killBody();
      fruits.remove(i);
    }
  }
  
  for (int i = 1; i >= 0; i--) 
  {
    if(bowl[i] != null)
    {
      if(bowl[i].isDead()) 
      {
        bowl[i].destroyBowl();
        bowl[i] = null;
      }
    }
  }
  
  for(int i = 1; i >=0; i--)
  {
    if(branchesLeft[i] != null)
    {
     if(branchesLeft[i].isDead())
     {
       branchesLeft[i].destroyBody();
       branchesLeft[i] = null;
     }
    }
  }
  
  for(int i = 1; i >=0; i--)
  {
    if(branchesRight[i] != null)
    {
     if(branchesRight[i].isDead())
     {
       branchesRight[i].destroyBody();
       branchesRight[i] = null;
     }
    }
  }
  
  box2d.step();
  
  //Kinect for Windows loop to get body data from the kinect using a tracker sub class
  for (int i=0; i<tracker.getBodySize(); i++)
  {
    if(tracker.getRightHandPos(tracker.bodies.get(i)) != null) 
    {
      for(int j = 0; j < handPosRight.length; j++)
      {
        if(handPosRight[j] == null)
        {
          if(tracker.getRightHandPos(tracker.bodies.get(i)) != null && tracker.getRightElbowPos(tracker.bodies.get(i)) != null)
          {    
            handPosRight[j] = new PVector(tracker.getRightHandPos(tracker.bodies.get(i)).x, tracker.getRightHandPos(tracker.bodies.get(i)).y);
            elbowPosRight[j] = new PVector(tracker.getRightElbowPos(tracker.bodies.get(i)).x, tracker.getRightElbowPos(tracker.bodies.get(i)).y);
          }
          if(tracker.getLeftHandPos(tracker.bodies.get(i)) != null && tracker.getLeftElbowPos(tracker.bodies.get(i)) != null)
          {
            handPosLeft[j] = new PVector(tracker.getLeftHandPos(tracker.bodies.get(i)).x, tracker.getLeftHandPos(tracker.bodies.get(i)).y);
            elbowPosLeft[j] = new PVector(tracker.getLeftElbowPos(tracker.bodies.get(i)).x, tracker.getLeftElbowPos(tracker.bodies.get(i)).y);
          }
          break;
        }
      }
    }
         
  }
  
  for (int x = 0; x < handPosLeft.length; x++) 
  {
    if (handPosLeft[x] != null && handPosRight[x] != null)
    {
      if( handPosLeft[x].y < elbowPosLeft[x].y && handPosRight[x].y < elbowPosRight[x].y) 
      {
        if (bowl[x] == null) 
        {
          bowl[x] = new Bowl(box2d,x,handPosLeft[x],handPosRight[x]);
        } 
        else 
        {
          bowl[x].update(handPosLeft[x], handPosRight[x]);
          
          // Draw the background of the bowl surface
          bowl[x].display();
        }
        
        //Remove branches if the hands and shoulders are is being tracked
        if(branchesLeft[x] != null)
          branchesLeft[x].kill();
        if(branchesRight[x] != null)  
          branchesRight[x].kill();
      }
      else
      {
        //Remove a bowl and unset the fruit that are flagged as collided with that bowl
        if (bowl[x] != null) 
        {
          bowl[x].kill();
          unsetBowlCollision(x);
        }
        
        //Initialize the left branch if it doesn't exsist and the left elbow is highest
        if(branchesLeft[x] == null && elbowPosLeft[x].y < elbowPosRight[x].y )
        {
          branchesLeft[x] = new Branch(elbowPosLeft[x].x,elbowPosLeft[x].y,100,10,0,BodyType.KINEMATIC, box2d);
        }
        
        //Kill the branch if its lower than the right elbow, otherwise update the position and draw it
        if(branchesLeft[x] != null)
        {
          if(elbowPosLeft[x].y > elbowPosRight[x].y)
            branchesLeft[x].kill();
            
          branchesLeft[x].MoveBody(new Vec2(handPosLeft[x].x,handPosLeft[x].y), new Vec2(elbowPosLeft[x].x,elbowPosLeft[x].y));
          branchesLeft[x].draw();
        }
        
        //Initialize the right branch if it doesn't exsist and the right elbow is highest
        if(branchesRight[x] == null && elbowPosLeft[x].y > elbowPosRight[x].y)
        {
          branchesRight[x] = new Branch(elbowPosRight[x].x,elbowPosRight[x].y,100,10,0,BodyType.KINEMATIC, box2d);
        }
        
        //Kill the branch if its lower than the left elbow, otherwise update the position and draw it
        if(branchesRight[x] != null)
        {
          if(elbowPosLeft[x].y < elbowPosRight[x].y)
            branchesRight[x].kill();
          
          branchesRight[x].MoveBody(new Vec2(handPosRight[x].x,handPosRight[x].y), new Vec2(elbowPosRight[x].x,elbowPosRight[x].y));
          branchesRight[x].draw();
        }
      }
    } 
    else if(handPosLeft[x] == null || handPosRight[x] == null) 
    {
      if (bowl[x] != null) 
      {
        bowl[x].kill();
        if(branchesLeft[x] != null)
           branchesLeft[x].kill();
        if(branchesRight[x] != null)  
           branchesRight[x].kill();
      }
    }
  }
  
  //Drawing the foreground of the bowl
  for (int y = 0; y < handPosLeft.length; y++) 
  {
    if(handPosLeft[y] != null && handPosRight[y] != null && bowl[y] != null) 
    {
      bowl[y].displayFront();
    }
  }
  
  // Draw all particles
  for (Fruit p: fruits) 
  {
    if (p != null) 
    {
      p.display();
      
      if(p.hasCollidedWithBowl() && p.body.getLinearVelocity().y > 1)
      {
        p.bowlCollisionEnd();
      } 
    }
  }
  
  //Exploding the fruit when they are flagged as dead, and then proceeding to remove them
  for (int w = 0; w < explodingFruits.size(); w++) 
  {
    if (!explodingFruits.get(w).isDead()) 
    {
      explodingFruits.get(w).update();
      explodingFruits.get(w).display();
    } 
    else 
    {
      explodingFruits.remove(w);
    }
  }
  
  //Bowl stealing fix, if the same body has both the bowls they will have the same index, and one with be removed
  if(bowl[0] != null && bowl[1] != null)
  {
    if(bowl[0].bowlIndex == bowl[1].bowlIndex)
    {
      bowl[0].kill();
    }
  }
  
  //Resetting all the hands to null
  handPosRight[0] = null;
  handPosLeft[0] = null;
  handPosRight[1] = null;
  handPosLeft[1] = null;
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
    if(o1.getClass() == CircleBody.class)
    {
      Fruit f = (Fruit)o2;
      if(f.body.getLinearVelocity().y < -2)
      {
        if(!f.hasCollided())
        {
          fruit_hit_sounds[f.getFruitIndex()].play(0);
          f.collision();
        }
      }
      
    }
    else if(o2.getClass() == CircleBody.class)
    {
      Fruit f = (Fruit)o1;
      if(f.body.getLinearVelocity().y < -2)
      {
        if(!f.hasCollided())
        {
          fruit_hit_sounds[f.getFruitIndex()].play(0);
          f.collision();
        }
      }
    }
    else if(o2.getClass() == Branch.class)
    {
      Branch b = (Branch)o2;
      if(!b.hasCollided())
      {
        fruit_hit_sounds[5].play(0);
        b.collision();
      }
    }
    else if(o1.getClass() == Branch.class)
    {
      Branch b = (Branch)o1;
      if(!b.hasCollided())
      {
        fruit_hit_sounds[5].play(0);
        b.collision();
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
      int coconutIndex = 1;
      int strawberryIndex = 4;
      if (fruit1.getFruitIndex() == coconutIndex && fruit2.getFruitIndex() != coconutIndex) {
        if (fruit1.body.getLinearVelocity().y < -2) {
          fruit2.setDeath();
          explodingFruits.add(new FruitParticleSystem(fruit2.getPos().x, fruit2.getPos().y, fruit_particle_images[fruit2.getFruitIndex()]));
        } 
        else 
        {
          if(bowl[fruit2.getBowlCollidedIndex()] != null)
          {
            fruit1.bowlCollision(new Vec2(bowl[fruit2.getBowlCollidedIndex()].getPos().x,fruit2.getPos().y));
            fruit1.setBowlCollidedIndex(fruit2.getBowlCollidedIndex());
          }
        }
      }
      else if (fruit2.getFruitIndex() == strawberryIndex && fruit1.getFruitIndex() != strawberryIndex) 
      {
        if (fruit1.body.getLinearVelocity().y < -2) 
        {
          fruit2.setDeath();
          explodingFruits.add(new FruitParticleSystem(fruit2.getPos().x, fruit2.getPos().y, fruit_particle_images[fruit2.getFruitIndex()]));
        } 
        else 
        {
          if(bowl[fruit2.getBowlCollidedIndex()] != null)
          {
            fruit1.bowlCollision(new Vec2(bowl[fruit2.getBowlCollidedIndex()].getPos().x,fruit2.getPos().y));
            fruit1.setBowlCollidedIndex(fruit2.getBowlCollidedIndex());
          }
        }
      }
      else 
      {
        if(bowl[fruit2.getBowlCollidedIndex()] != null)
        {
          fruit1.bowlCollision(new Vec2(bowl[fruit2.getBowlCollidedIndex()].getPos().x,fruit2.getPos().y));
          fruit1.setBowlCollidedIndex(fruit2.getBowlCollidedIndex());
        }
      }
    }
    
    if(fruit1.hasCollidedWithBowl())
    {
      int coconutIndex = 1;
      int strawberryIndex = 4;
      if (fruit2.getFruitIndex() == coconutIndex && fruit1.getFruitIndex() != coconutIndex) 
      {
        if (fruit2.body.getLinearVelocity().y < -2) 
        {
          fruit1.setDeath();
          explodingFruits.add(new FruitParticleSystem(fruit1.getPos().x, fruit1.getPos().y, fruit_particle_images[fruit1.getFruitIndex()]));
        } 
        else 
        {
          if(bowl[fruit1.getBowlCollidedIndex()] != null)
          {
            fruit2.bowlCollision(new Vec2(bowl[fruit1.getBowlCollidedIndex()].getPos().x,fruit1.getPos().y));
            fruit2.setBowlCollidedIndex(fruit1.getBowlCollidedIndex()); 
          }
        }
      } 
      else if (fruit1.getFruitIndex() == strawberryIndex && fruit2.getFruitIndex() != strawberryIndex) 
      {
        if (fruit2.body.getLinearVelocity().y < -2) 
        {
          fruit1.setDeath();
          explodingFruits.add(new FruitParticleSystem(fruit1.getPos().x, fruit1.getPos().y, fruit_particle_images[fruit1.getFruitIndex()]));
        } 
        else 
        {
          if(bowl[fruit1.getBowlCollidedIndex()] != null)
          {
            fruit2.bowlCollision(new Vec2(bowl[fruit1.getBowlCollidedIndex()].getPos().x,fruit1.getPos().y));
            fruit2.setBowlCollidedIndex(fruit1.getBowlCollidedIndex());
          }
        }
      }
      else 
      {
        if(bowl[fruit1.getBowlCollidedIndex()] != null)
        {
          fruit2.bowlCollision(new Vec2(bowl[fruit1.getBowlCollidedIndex()].getPos().x,fruit1.getPos().y));
          fruit2.setBowlCollidedIndex(fruit1.getBowlCollidedIndex()); 
        }
      }
    }
    
    // tree code
    if (!fruit1.isDead() && fruit1.hasCollidedWithBowl()) 
    {
      if (fruit1.getPos().y < 0) 
      { 
        trees.add(new Tree(random(0, width*0.95)-100, random(height*0.85, height*0.97), tree_images[fruit1.getFruitIndex()], fruit1.getFruitIndex()));
        treeGrowingSfx.play(0);
        killAllBowlFruits();  
        
      }
    }
    if (!fruit2.isDead() && fruit2.hasCollidedWithBowl()) 
    {
      if (fruit2.getPos().y < 0) 
      { 
        trees.add(new Tree(random(0, width*0.95)-100, random(height*0.85, height*0.97), tree_images[fruit2.getFruitIndex()], fruit2.getFruitIndex()));
        treeGrowingSfx.play(0);
        killAllBowlFruits();  
        
      }
    }
  }
}

void treeReorder() 
{
  if(trees.size() > 1)
  {
    for (int i = 0; i < trees.size(); i++) 
    {
      for(int j = 0; j < trees.size(); j++)
      {
        if (i != j) {
          if(trees.get(i).getY() < trees.get(j).getY())
          {
            Tree tempTree = trees.get(j);
            trees.set(j,trees.get(i));
            trees.set(i,tempTree);
          }
        }
      }
    }
  }
}

void killAllBowlFruits()
{
  for(Fruit fruit : fruits) 
  {
    if (fruit.hasCollidedWithBowl()) 
    {
      fruit.setDeath();
      explodingFruits.add(new FruitParticleSystem(fruit.getPos().x, fruit.getPos().y, fruit_particle_images[fruit.getFruitIndex()]));
    }   
  }  
}

void unsetBowlCollision(int bowlIndex)
{
  for(Fruit fruit : fruits) 
  {
    if (fruit.hasCollidedWithBowl()&& fruit.getBowlCollidedIndex() == bowlIndex) 
    {
      fruit.bowlCollisionEnd();
    }   
  }  
}

void endContact(Contact cp)
{
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
    
    if(fruit1.hasCollidedWithBowl() && fruit1.body.getLinearVelocity().y > 1)
    {
      fruit1.bowlCollisionEnd();
    }
    if(fruit2.hasCollidedWithBowl() && fruit1.body.getLinearVelocity().y > 1)
    {
      fruit2.bowlCollisionEnd();
    }
  }
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