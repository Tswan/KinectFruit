class RectangleBody
{
   Body      mBody;
   float     mWidth;
   float     mHeight;
   float     mAngle;
   Box2DProcessing mBox2DRef;
   
   color mColor = color(255,255,255);
  
   RectangleBody(float xInit, float yInit, float initWidth, float initHeight, float initAngle, BodyType type, Box2DProcessing box2D)
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
     PolygonShape ps = new PolygonShape();
     float box2DW = mBox2DRef.scalarPixelsToWorld(mWidth);
     float box2DH = mBox2DRef.scalarPixelsToWorld(mHeight);
     ps.setAsBox(box2DW, box2DH);
     
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
     Vec2 pos = mBox2DRef.getBodyPixelCoord( mBody );
     float angle = -mBody.getAngle();
     
     pushMatrix();
       translate(pos.x, pos.y);
       rotate(angle);
       
       if (mBody.isAwake()) {
         fill(mColor);
       }
       else {
         fill(red(mColor) * 0.9f, green(mColor) * 0.9f, blue(mColor) * 0.9f); 
       }
       rectMode(CENTER);
       //rect( 0, 0, mWidth, mHeight );
     popMatrix();
   }
   
   void DestroyBody()
   {
     mBox2DRef.destroyBody(mBody);
   }
   
   void MoveBody(Vec2 newVelocity)
   {
     /*Vec2 previous = mBox2DRef.getBodyPixelCoord( mBody );
     float velX = mouseX - previous.x;
     float velY = mouseY + previous.y;*/
     mBody.setLinearVelocity(newVelocity);
   }
}