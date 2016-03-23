class Bowl {
  Box2DProcessing mBox2DRef;

  PImage bowlBack = loadImage("bowl_02_back.png");
  PImage bowlFront = loadImage("bowl_02_front.png");
  
  int bowlWidth = 430;
  int bowlHeight = 130;
  int imageOffsetY = 15;
  int circleRad = 5;
  int bowlIndex;
  
  // We'll keep track of all of the surface points
  //ArrayList<Vec2> bowl;
  ArrayList<CircleBody> bowl2;
  Body previousShape;
  PVector leftEnd = new PVector(800,500);
  PVector rightEnd = new PVector(1000, 500);
  
  float angleBetweenTwoPoints = 0;
  float mAngleBetweenTwoPoints = 0;
  Vec2 circleCenter;
  Vec2 bowlPosition;
  float actualBowlAngle = 0; 
  float bowlPositionOffsetX;
  
  int numSections = bowlWidth / circleRad * 2 + 1;
  int rotateOffset = 180 / numSections;
  
  PVector bridgeVec = PVector.sub( leftEnd, rightEnd );  
  float sectionSpacing = bridgeVec.mag() / (float) numSections;  
  
  boolean dead = false;
  
  Bowl(Box2DProcessing box2D, int bowlId, PVector leftPoint, PVector rightPoint) {
    mBox2DRef = box2D;
    bowlIndex = bowlId;
    println(leftPoint);
    println(rightPoint);
    ArrayList<CircleBody> bufferBowl = getHalfCircle(new PVector(leftEnd.x ,(leftPoint.y < rightPoint.y ? rightPoint.y : leftPoint.y)),new PVector(rightEnd.x ,(leftPoint.y < rightPoint.y ? rightPoint.y : leftPoint.y)));
    bowl2 = bufferBowl;
    
    CircleBody middleBody = bowl2.get(bowl2.size() - 1);
    bowlPosition = mBox2DRef.getBodyPixelCoord( middleBody.mBody );
    
    CircleBody firstBody = bowl2.get(bowl2.size() - 1);
    Vec2 firstBowlPos = mBox2DRef.getBodyPixelCoord( firstBody.mBody );
    CircleBody endBody = bowl2.get(0);
    Vec2 endBowlPos = mBox2DRef.getBodyPixelCoord( endBody.mBody );
    
    actualBowlAngle = atan((endBowlPos.y - firstBowlPos.y) / (endBowlPos.x - firstBowlPos.x));
    bowlPositionOffsetX = (degrees(actualBowlAngle) / 360) * 200;
    bowlPosition.y -= 10;
  }
  
  ArrayList<Vec2> getWantedPos(PVector leftPoint, PVector rightPoint) {
    Vec2 mCircleCenter = new Vec2((rightPoint.x + leftPoint.x) / 2, (rightPoint.y + leftPoint.y) / 2); 
    float mRadius = bowlWidth/2;
    mAngleBetweenTwoPoints = atan((rightPoint.y - leftPoint.y) / (rightPoint.x - leftPoint.x));
   
    ArrayList<Vec2> RectanglePos = new ArrayList<Vec2>();
    
    for (int i = (int) degrees(mAngleBetweenTwoPoints) + 5; i < (int) degrees(mAngleBetweenTwoPoints) + 180; i+=rotateOffset) {
      float newPointX = mRadius * cos(radians(i)) + mCircleCenter.x;
      float newPointY = mRadius * sin(radians(i)) + mCircleCenter.y;
      // get a shallow bowl
      
      if (mAngleBetweenTwoPoints == 0) {
        float newPointOffsetY = newPointY / 2;
      } else {
        Vec2 vecLeftWithNew = new Vec2(leftPoint.x - newPointX, leftPoint.y - newPointY);
        Vec2 vecRightAndLeft = new Vec2(rightPoint.x - leftPoint.x, rightPoint.y - leftPoint.y);
        float dotProduct = vecLeftWithNew.x * vecRightAndLeft.x + vecLeftWithNew.y * vecRightAndLeft.y;
        float squareDist = pow(vecRightAndLeft.x, 2) + pow(vecRightAndLeft.y, 2);
        float t = -dotProduct / squareDist;
        Vec2 pol = new Vec2(leftPoint.x + t * (rightPoint.x - leftPoint.x), leftPoint.y + t * (rightPoint.y - leftPoint.y));
        // divided by 2
        newPointX = pol.x + ((newPointX - pol.x) / 2);
        newPointY = pol.y + ((newPointY - pol.y) / 2);
      }
      //newPointY -= newPointOffsetY;
      RectanglePos.add(new Vec2((int) newPointX, (int) newPointY));
    }
    
    return RectanglePos;
  }
  
  ArrayList<CircleBody> getHalfCircle(PVector leftPoint, PVector rightPoint) { 
    ArrayList<CircleBody> halfCircle = new ArrayList<CircleBody>();
    Vec2 circleCenter = new Vec2((rightPoint.x + leftPoint.x) / 2, (rightPoint.y + leftPoint.y) / 2); 
    
    float radius = bowlWidth/2;
    angleBetweenTwoPoints = atan((rightPoint.y - leftPoint.y) / (rightPoint.x - leftPoint.x));
    
    
    ArrayList<Vec2> RectanglePos = new ArrayList<Vec2>();
    
    for (int i = (int) degrees(angleBetweenTwoPoints) + 5; i < (int) degrees(angleBetweenTwoPoints) + 180; i+=rotateOffset) {
      float newPointX = radius * cos(radians(i)) + circleCenter.x;
      float newPointY = radius * sin(radians(i)) + circleCenter.y;
      // get a shallow bowl
      float newPointOffsetY = newPointY / 2;
      newPointY -= newPointOffsetY;
      RectanglePos.add(new Vec2((int) newPointX, (int) newPointY));
    }
    
    for(int i = 0; i < numSections + 1; i++ ) {
      CircleBody section = null;
      if (i == 0 ) {
        PVector sectionPos = new PVector( RectanglePos.get(0).x, RectanglePos.get(0).y );
        section = new CircleBody(bowlIndex, sectionPos.x, sectionPos.y, circleRad, BodyType.KINEMATIC, mBox2DRef);
      }
      else if ( i == numSections ) {
        PVector sectionPos = new PVector( RectanglePos.get(numSections - 1 ).x, RectanglePos.get(numSections - 1).y );
        section = new CircleBody(bowlIndex, sectionPos.x, sectionPos.y, circleRad, BodyType.KINEMATIC, mBox2DRef);
      }
      else {//all middle sections
       PVector sectionPos = new PVector( RectanglePos.get(i).x, RectanglePos.get(i).y );
       section = new CircleBody(bowlIndex, sectionPos.x, sectionPos.y, circleRad, BodyType.KINEMATIC, mBox2DRef);
      }
       
       //now that we have all pieces we want to connect them together with a "stretchy" joint
       if (i > 0) {
         DistanceJointDef djd = new DistanceJointDef();
         CircleBody previous = halfCircle.get(i-1);
         
         //connect between prev and curr section
         djd.bodyA = previous.mBody;
         djd.bodyB = section.mBody;
         
         // equilibrium length
         djd.length = mBox2DRef.scalarPixelsToWorld( sectionSpacing);
         
         // how springy is the joint
         djd.frequencyHz = 0f;
         djd.dampingRatio = 0f;
         
         // finally make the joint
         DistanceJoint dj = (DistanceJoint) mBox2DRef.world.createJoint(djd);
         
       }
       
       halfCircle.add(section);
    }
    return halfCircle;
  }
  
  void update(PVector posLeft, PVector posRight) {
      //ArrayList<RectangleBody> bufferBowl = getHalfCircle(posLeft, posRight);
      //destroyBowl();
      CircleBody middleBody = bowl2.get(bowl2.size() - 1);
      
      Vec2 previous = mBox2DRef.getBodyPixelCoord( middleBody.mBody );
      /*old Way of moving bowl
      float CenterX = posLeft.x + (0.5 *(posRight.x -  posLeft.x));
      float CenterY = posLeft.y + (0.5 *(posRight.y -  posLeft.y));
      float velX = (CenterX - previous.x) / 2;
      float velY = -1 * (CenterY - previous.y) / 2;*/
      
      //New way of moving bowl
      float velX = (posRight.x + posLeft.x) / 2 - previous.x;
      
      
      float velY = previous.y - (posLeft.y + (0.5*(posRight.y - posLeft.y)));
      
      
      for (CircleBody shape : bowl2) {
        shape.MoveBody(new Vec2(velX, velY));
      }
      
      ArrayList<Vec2> wantedNewPos = getWantedPos(posLeft, posRight);
      int increment = 0;
      for (CircleBody shape : bowl2) {
        float velWithAngleX = wantedNewPos.get(increment).x - shape.getPos().x;
        float velWithAngleY = shape.getPos().y - wantedNewPos.get(increment).y;
        shape.MoveBody(new Vec2(velWithAngleX + velX, velWithAngleY + velY));
        increment++;
      }
      //bowl2 = bufferBowl;
      middleBody = bowl2.get(bowl2.size() - 1);
      bowlPosition = mBox2DRef.getBodyPixelCoord( middleBody.mBody );
      //bowlPosition.y = map(bowlPosition.y,mBox2DRef.scalarPixelsToWorld(0),mBox2DRef.scalarPixelsToWorld(height), mBox2DRef.scalarPixelsToWorld(height - height/10), mBox2DRef.scalarPixelsToWorld(height));
      bowlPosition.y -= 10;
      CircleBody firstBody = bowl2.get(bowl2.size() - 1);
      Vec2 firstBowlPos = mBox2DRef.getBodyPixelCoord( firstBody.mBody );
      CircleBody endBody = bowl2.get(0);
      Vec2 endBowlPos = mBox2DRef.getBodyPixelCoord( endBody.mBody );
      actualBowlAngle = atan((endBowlPos.y - firstBowlPos.y) / (endBowlPos.x - firstBowlPos.x));
      bowlPositionOffsetX = (degrees(actualBowlAngle) / 360) * 200;
  }
  
  // A simple function to just draw the edge chain as a series of vertex points
  void display() {
    pushMatrix();
    translate(bowlPosition.x + bowlPositionOffsetX, bowlPosition.y - imageOffsetY);
      rotate(actualBowlAngle);
      image(bowlBack, 0, 0);
    popMatrix();
  }
  
  void displayFront() {
    pushMatrix();
      translate(bowlPosition.x + bowlPositionOffsetX, bowlPosition.y - imageOffsetY);
      rotate(actualBowlAngle);
      tint(255, 60);
      image(bowlFront, 0, 0);
      noTint();
    popMatrix();
    fill(0);
    for(CircleBody c : bowl2) {
      c.draw();
    }
    noFill();
  }
  
  Vec2 getPos()
  {
    return new Vec2(bowlPosition.x+bowlBack.width/2,bowlPosition.y + bowlBack.height);
  }
  
  boolean isDead()
  {
    return dead;
  }
  
  void kill()
  {
    dead = true;
  }
  
  void destroyBowl() {
    for (CircleBody shape : bowl2) {
        shape.DestroyBody();
      }
    
  }
}