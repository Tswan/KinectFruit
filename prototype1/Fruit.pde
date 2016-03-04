class Fruit {
  Box2DProcessing box2d;
  PolygonShape bananaShape;
  Body body;
  float fruit_w, fruit_h;
  PImage fruit_img;
  
  //Sound effect variables
  boolean collided;
  boolean collidedWithTheBowl;
  int timer;
  int soundDelay = 10000;
  String name;
  
  Fruit(float x, float y, Box2DProcessing mBox2DRef, PImage fruitImage, int identifier) {
    
    fruit_img = fruitImage;
    box2d = mBox2DRef;
    Vec2 center = new Vec2(x, y);
    Vec2[] vertices = null;
    collided = false;
    collidedWithTheBowl = false;
    switch(identifier)
    {
      case 0://Banana custom polyshape
        vertices = new Vec2[6];
        vertices[0] = box2d.vectorPixelsToWorld(new Vec2(9.3, 0)); 
        vertices[1] = box2d.vectorPixelsToWorld(new Vec2(9.3, 20.8)); 
        vertices[2] = box2d.vectorPixelsToWorld(new Vec2(15.6, 39.4)); 
        vertices[3] = box2d.vectorPixelsToWorld(new Vec2(3.9, 33.4)); 
        vertices[4] = box2d.vectorPixelsToWorld(new Vec2(0, 15.4)); 
        vertices[5] = box2d.vectorPixelsToWorld(new Vec2(5.8, 1.2)); 
        name = "banana";
        break;
     case 1://Coconut custom polyshape
        break;
     case 2://Orange custom polyshape
        break;
     case 3://Strawberry custom polyshape
        break;
     case 4://Apple custom polyshape
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
    fd.restitution = 0.5f;
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
    fd.friction = 0.3f;
    fd.restitution = 0.5f;

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
  
  // Is the particle ready for deletion?
  boolean isOffScreen() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height+height*2) {
      killBody();
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
  
  //trigger the fruits to stick
  void startStick(Vec2 target)
  {
    Vec2 worldTarget = box2d.coordPixelsToWorld(target.x,target.y);   
    Vec2 bodyVec = body.getWorldCenter();
    worldTarget.subLocal(bodyVec);
    worldTarget = new Vec2(worldTarget.x*5,worldTarget.y-10);
    worldTarget.normalize();
    worldTarget.mulLocal((float) 50);
    body.applyForce(worldTarget, bodyVec);
  }
  
  void bowlCollisionEnd()
  {
    collidedWithTheBowl=false;
    stopStick();
  }
  
  void stopStick()
  {
    
  }
    
  
}