class CircleBody
{
   Body      mBody;
   float     mRadius;
   Box2DProcessing mBox2DRef;
   
   color mColor = color(255,255,255);
  
   CircleBody(float xInit, float yInit, float initRad, BodyType type, Box2DProcessing box2D)
   {
     mRadius = initRad;
     mBox2DRef = box2D;
     
     // Body def
     BodyDef bd = new BodyDef();
     bd.type = type;
     bd.position = mBox2DRef.coordPixelsToWorld( xInit, yInit );
     
     // Create the body
     mBody = mBox2DRef.createBody(bd);
     
     //shape
     CircleShape cs = new CircleShape();
     cs.m_radius = mBox2DRef.scalarPixelsToWorld(initRad);
     
     //fixture
     FixtureDef fd = new FixtureDef();
     fd.shape = cs;
     fd.density = 1f * 1.0f/initRad;
     fd.friction = 0.3f;
     fd.restitution = 0.5f;
     
     //attach the body
     mBody.createFixture( fd );
     
     mBody.setUserData( this); // set user data to be a reference to the Processing object
   }
   
   void draw()
   {
     Vec2 pos = mBox2DRef.getBodyPixelCoord( mBody );
     
     pushMatrix();
       translate(pos.x, pos.y);     
       if (mBody.isAwake()) {
         fill(mColor);
       }
       else {
         fill(red(mColor) * 0.9f, green(mColor) * 0.9f, blue(mColor) * 0.9f); 
       }
       rectMode(CENTER);
       ellipse( 0, 0, mRadius, mRadius );
     popMatrix();
   }
   
   Vec2 getPos()
   {
      Vec2 pos = mBox2DRef.getBodyPixelCoord(mBody);
      return pos;
   }
   
   void DestroyBody()
   {
     mBox2DRef.destroyBody(mBody);
   }
   
   void MoveBody(Vec2 newVelocity)
   {
     mBody.setLinearVelocity(newVelocity);
   }
}