class Fruit {
  Box2DProcessing box2d;
  PolygonShape bananaShape;
  Body body;
  int collidedBowlIndex;
  int fruitIndex;
  float fruit_w, fruit_h;
  boolean dead;
  PImage fruit_img;
  
  //Sound effect variables
  boolean collided;
  boolean collidedWithTheBowl;
  int timer;
  int soundDelay = 10000;
  String name;
  
  Fruit(float x, float y, Box2DProcessing mBox2DRef, PImage fruitImage, int identifier) {
    collidedBowlIndex = -1;
    dead = false;
    fruitIndex = identifier;
    fruit_img = fruitImage;
    box2d = mBox2DRef;
    Vec2 center = new Vec2(x, y);
    Vec2[] vertices = null;
    collided = false;
    collidedWithTheBowl = false;
    switch(identifier)
     {
       case 0://Banana custom polyshape
         vertices = new Vec2[8];
         vertices[0] = box2d.vectorPixelsToWorld(new Vec2(40, 0)); 
         vertices[1] = box2d.vectorPixelsToWorld(new Vec2(25, 0)); 
         vertices[2] = box2d.vectorPixelsToWorld(new Vec2(0, 52)); 
         vertices[3] = box2d.vectorPixelsToWorld(new Vec2(12, 117)); 
         vertices[4] = box2d.vectorPixelsToWorld(new Vec2(54, 142)); 
         vertices[5] = box2d.vectorPixelsToWorld(new Vec2(61, 134));
         vertices[6] = box2d.vectorPixelsToWorld(new Vec2(41, 102));
         vertices[7] = box2d.vectorPixelsToWorld(new Vec2(33, 44)); 
         name = "banana";
         break;
      case 1://Coconut custom polyshape
        vertices = new Vec2[8];
        vertices[0] = box2d.vectorPixelsToWorld(new Vec2(80, 0));
        vertices[1] = box2d.vectorPixelsToWorld(new Vec2(44, 0));
        vertices[2] = box2d.vectorPixelsToWorld(new Vec2(7, 42));
        vertices[3] = box2d.vectorPixelsToWorld(new Vec2(0, 75));
        vertices[4] = box2d.vectorPixelsToWorld(new Vec2(31, 132));
        vertices[5] = box2d.vectorPixelsToWorld(new Vec2(77, 132));
        vertices[6] = box2d.vectorPixelsToWorld(new Vec2(114, 192));
        vertices[7] = box2d.vectorPixelsToWorld(new Vec2(111, 48));
        name = "coconut";
        break;
      case 2://Orange custom polyshape
        vertices = new Vec2[8];
        vertices[0] = box2d.vectorPixelsToWorld(new Vec2(60, 3));
        vertices[1] = box2d.vectorPixelsToWorld(new Vec2(45, 0));
        vertices[2] = box2d.vectorPixelsToWorld(new Vec2(30, 20));
        vertices[3] = box2d.vectorPixelsToWorld(new Vec2(14, 25));
        vertices[4] = box2d.vectorPixelsToWorld(new Vec2(0, 54));
        vertices[5] = box2d.vectorPixelsToWorld(new Vec2(31, 81));
        vertices[6] = box2d.vectorPixelsToWorld(new Vec2(69, 60));
        vertices[7] = box2d.vectorPixelsToWorld(new Vec2(57, 30));
        name = "orange";
        break;
      case 3://Apple custom polyshape
        vertices = new Vec2[8];
        vertices[0] = box2d.vectorPixelsToWorld(new Vec2(48, 0));
        vertices[1] = box2d.vectorPixelsToWorld(new Vec2(40, 2));
        vertices[2] = box2d.vectorPixelsToWorld(new Vec2(32, 17));
        vertices[3] = box2d.vectorPixelsToWorld(new Vec2(10, 20));
        vertices[4] = box2d.vectorPixelsToWorld(new Vec2(0, 55));
        vertices[5] = box2d.vectorPixelsToWorld(new Vec2(38, 81));
        vertices[6] = box2d.vectorPixelsToWorld(new Vec2(71, 47));
        vertices[7] = box2d.vectorPixelsToWorld(new Vec2(51, 18));
        name = "apple";
        break;
      case 4://Strawberry custom polyshape
        vertices = new Vec2[8];
        vertices[0] = box2d.vectorPixelsToWorld(new Vec2(38, 8));
        vertices[1] = box2d.vectorPixelsToWorld(new Vec2(19, 0));
        vertices[2] = box2d.vectorPixelsToWorld(new Vec2(0, 8));
        vertices[3] = box2d.vectorPixelsToWorld(new Vec2(7, 19));
        vertices[4] = box2d.vectorPixelsToWorld(new Vec2(12, 34));
        vertices[5] = box2d.vectorPixelsToWorld(new Vec2(18, 44));
        vertices[6] = box2d.vectorPixelsToWorld(new Vec2(24, 44));
        vertices[7] = box2d.vectorPixelsToWorld(new Vec2(29, 25));
        name = "strawberry";
        break;
     }
     
     
    // This function puts the fruit in the Box2d world
    PolygonShape sd = new PolygonShape();
    sd.set(vertices, vertices.length);
    bananaShape = sd;
    
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 0.1f;
    fd.friction = 0.3f;
    fd.restitution = 0f;
    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    body = box2d.createBody(bd);
    body.createFixture(fd);
    body.setAngularVelocity(random(-5, 5));
    body.setUserData(this);
    
  }
  
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    image(fruit_img, 0, 0); 
    popMatrix();
  }
  
  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center, float w_, float h_) {

    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 0f;
    fd.friction = 3f;
    fd.restitution = 0f;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    // Give it some initial random velocity
    body.setLinearVelocity(new Vec2(random(-5, 5), random(2, 5)));
    body.setAngularVelocity(random(-5, 5));
  }
  
  // Give the position of the body
  Vec2 getPos()
  {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    return pos;
  }
  
  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }
  
  void setDeath() {
    dead = true;
  }
  
  boolean isDead() {
    return dead;
  }
  
  // Is the particle ready for deletion?
  boolean isOffScreen() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height+height*2) {
      return true;
    }
    return false;
  }
  
  //Make sure fruit only collide once
  void collision()
  {
    timer = millis();
    collided = true;
  }
  
  //reseting the collision
  boolean hasCollided()
  {
    if(millis() - timer >= soundDelay)
      collided = false;
      
    return collided;
  }
  
  boolean hasCollidedWithBowl()
  {
    return collidedWithTheBowl;
  }
  
  void bowlCollision(Vec2 target)
  {
    collidedWithTheBowl=true;
    startStick(target);
  }
  
  int getFruitIndex() {
    return fruitIndex;
  }
  
  int getBowlCollidedIndex() {
    return collidedBowlIndex;
  }
  
  void setBowlCollidedIndex(int bowlIdx) {
    collidedBowlIndex = bowlIdx;
  }
  
  //trigger the fruits to stick
  void startStick(Vec2 target)
  {
    Vec2 worldTarget = box2d.coordPixelsToWorld(target.x,target.y);   
    Vec2 bodyVec = body.getWorldCenter();
    worldTarget.subLocal(bodyVec);
    worldTarget = new Vec2(worldTarget.x*5,worldTarget.y-40);
    worldTarget.normalize();
    worldTarget.mulLocal((float) 1000);
    body.applyForce(worldTarget, bodyVec);
  }
  
  void bowlCollisionEnd()
  {
    collidedWithTheBowl=false;
    stopStick();
    collidedBowlIndex = -1;
  }
  
  void stopStick()
  {
    
  }
    
  
}