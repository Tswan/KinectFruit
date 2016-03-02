class Bowl {
  Box2DProcessing mBox2DRef;

  PImage bowlBack = loadImage("bowl_02_back.png");
  PImage bowlFront = loadImage("bowl_02_front.png");
  
  int bowlWidth = 430;
  int bowlHeight = 130;
  int imageOffsetY = 15;
  int circleRad = 5;
  
  // We'll keep track of all of the surface points
  //ArrayList<Vec2> bowl;
  ArrayList<CircleBody> bowl2;
  Body previousShape;
  PVector leftEnd = new PVector(800,500);
  PVector rightEnd = new PVector(1000, 500);
  
  float angleBetweenTwoPoints = 0;
  Vec2 circleCenter;
  Vec2 bowlPosition;
  
  int numSections = bowlWidth / circleRad * 2 + 1;
  int rotateOffset = 180 / numSections;
  
  PVector bridgeVec = PVector.sub( leftEnd, rightEnd );  
  float sectionSpacing = bridgeVec.mag() / (float) numSections;  
  
  ArrayList<CircleBody> getHalfCircle(PVector leftPoint, PVector rightPoint) { 
    ArrayList<CircleBody> halfCircle = new ArrayList<CircleBody>();
    circleCenter = new Vec2((rightPoint.x + leftPoint.x) / 2, (rightPoint.y + leftPoint.y) / 2); 
    //float radius = sqrt(pow(circleCenter.x - leftPoint.x, 2) + pow(circleCenter.y - leftPoint.y, 2));
    float radius = bowlWidth/2;
    //angleBetweenTwoPoints = atan((rightPoint.y - leftPoint.y) / (rightPoint.x - leftPoint.x));
    //println(degrees(angleBetweenTwoPoints));
    //println("numSections: " + numSections);
    
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
         section = new CircleBody( sectionPos.x, sectionPos.y, circleRad, BodyType.KINEMATIC, mBox2DRef);
      }
      else if ( i == numSections ) {
        PVector sectionPos = new PVector( RectanglePos.get(numSections - 1 ).x, RectanglePos.get(numSections - 1).y );
        section = new CircleBody( sectionPos.x, sectionPos.y, circleRad, BodyType.KINEMATIC, mBox2DRef);
      }
      else {//all middle sections
       PVector sectionPos = new PVector( RectanglePos.get(i).x, RectanglePos.get(i).y );
       section = new CircleBody(sectionPos.x, sectionPos.y, circleRad, BodyType.KINEMATIC, mBox2DRef);
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
  
  Bowl(Box2DProcessing box2D) {
    mBox2DRef = box2D;
    
    
    ArrayList<CircleBody> bufferBowl = getHalfCircle(leftEnd, rightEnd);
    bowl2 = bufferBowl;
    
  }
  
  void update(PVector posLeft, PVector posRight) {
      //ArrayList<RectangleBody> bufferBowl = getHalfCircle(posLeft, posRight);
      //destroyBowl();
      CircleBody leftMostBody = bowl2.get(bowl2.size() - 1);
      
      Vec2 previous = mBox2DRef.getBodyPixelCoord( leftMostBody.mBody );
      
      
      float velX = (mouseX - previous.x) / 2;
      float velY = -1 * (mouseY - previous.y) / 2;
      for (CircleBody shape : bowl2) {
        shape.MoveBody(new Vec2(velX, velY));
      }
      //bowl2 = bufferBowl;
      leftMostBody = bowl2.get(bowl2.size() - 1);
      bowlPosition = mBox2DRef.getBodyPixelCoord( leftMostBody.mBody );
      bowlPosition.y -= 10;
  }
  
  // A simple function to just draw the edge chain as a series of vertex points
  void display() {
    pushMatrix();
    translate(bowlPosition.x, bowlPosition.y - imageOffsetY);
      rotate(angleBetweenTwoPoints);
      image(bowlBack, 0, 0);
    popMatrix();
    //imageMode(CORNER);
    
  }
  
  void displayFront() {
    pushMatrix();
    //imageMode(CENTER);
    translate(bowlPosition.x, bowlPosition.y - imageOffsetY);
      rotate(angleBetweenTwoPoints);
      tint(255, 60);
      image(bowlFront, 0, 0);
      noTint();
    popMatrix();
    //imageMode(CORNER);\
    fill(0);
    /*for(CircleBody c : bowl2) {
      c.draw();
    }*/
    noFill();
  }
  
  void destroyBowl() {
    for (CircleBody shape : bowl2) {
        shape.DestroyBody();
      }
  }
}