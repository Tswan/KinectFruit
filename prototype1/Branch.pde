class Branch
{
   Body      mBody;
   float     mWidth;
   float     mHeight;
   float     mAngle;
   
   Box2DProcessing mBox2DRef;
   
   color mColor = color(255,255,255);
   
   boolean dead = false;
  
   Branch(float xInit, float yInit, float initWidth, float initHeight, float initAngle, BodyType type, Box2DProcessing box2D)
   {
     mWidth = initWidth;
     mHeight = initHeight;
     mAngle = initAngle;
     mBox2DRef = box2D;
     
     // Body def
     BodyDef bd = new BodyDef();
     bd.type = type;
     bd.position = mBox2DRef.coordPixelsToWorld( xInit, yInit );
     bd.angle = radians(initAngle);
     
     // Create the body
     mBody = mBox2DRef.createBody(bd);
     
     //shape
     
     
     Vec2[] vertices = new Vec2[8];
     vertices[0] = box2d.vectorPixelsToWorld(new Vec2(-13, 0)); 
     vertices[1] = box2d.vectorPixelsToWorld(new Vec2(2, 6)); 
     vertices[2] = box2d.vectorPixelsToWorld(new Vec2(18, 179)); 
     vertices[3] = box2d.vectorPixelsToWorld(new Vec2(100, 281)); 
     vertices[4] = box2d.vectorPixelsToWorld(new Vec2(58, 336)); 
     vertices[5] = box2d.vectorPixelsToWorld(new Vec2(-69, 289));
     vertices[6] = box2d.vectorPixelsToWorld(new Vec2(-56, 142));
     vertices[7] = box2d.vectorPixelsToWorld(new Vec2(-26, 87));
     
     PolygonShape ps = new PolygonShape();
    ps.set(vertices, vertices.length);
     //fixture
     FixtureDef fd = new FixtureDef();
     fd.shape = ps;
     fd.density = 1f * 1.0f/mWidth;
     fd.friction = 0.3f;
     fd.restitution = 0.5f;
     
     //attach the body
     mBody.createFixture( fd );
     
     mBody.setUserData( this); // set user data to be a reference to the Processing object
   }
   
   void draw()
   {
     // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(mBody);
    // Get its angle of rotation
    float a = mBody.getAngle();
    
    pushMatrix();
      translate(pos.x, pos.y);
      rotate(-a);
      image(branchImg, -branchImg.width/2 +20, 0); 
    popMatrix();
    
   }
   
   boolean isDead()
  {
    return dead;
  }
  
  void kill()
  {
    dead = true;
  }
  
  
   void destroyBody()
   {
     mBox2DRef.destroyBody(mBody);
   }
   
   void MoveBody(Vec2 handPos, Vec2 sholderPos)
   {
     Vec2 previous = mBox2DRef.getBodyPixelCoord( mBody );
     
     float velX =  sholderPos.x - previous.x;
     float velY = previous.y - sholderPos.y;
     Vec2 velocity = new Vec2(velX,velY);
     
     Vec2 target = handPos.sub(sholderPos);
     //target.mul(-1);
     float bodyAngle = mBody.getAngle();
     float desiredAngle = atan2(-target.x,target.y) *-1;
     
     /*float nextAngle = bodyAngle + mBody.getAngularVelocity()/60;
     float totalRotation = desiredAngle - nextAngle;
    
     while(totalRotation < radians(-180) ){ totalRotation += radians(360); }
     while(totalRotation > radians(180) ){ totalRotation -= radians(360); }
     
     float desiredAngularVelocity = totalRotation * 60;
     float impulse =  degrees(atan2(-velocity.x,velocity.y)) - mBody.getAngularVelocity();// * desiredAngle;*/
     
     mBody.setTransform(mBody.getPosition(), desiredAngle);
     
     mBody.setLinearVelocity(velocity);
   }
}