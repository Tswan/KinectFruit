class Bowl {
  Box2DProcessing mBox2DRef;

  PImage bowlBack = loadImage("bowl_back_200.png");
  PImage bowlFront = loadImage("bowl_front_200.png");
  
  // We'll keep track of all of the surface points
  //ArrayList<Vec2> bowl;
  ArrayList<RectangleBody> bowl2;
  Body previousShape;
  PVector leftEnd = new PVector(800,500);
  PVector rightEnd = new PVector(1000, 500);
  
  float angleBetweenTwoPoints;
  Vec2 circleCenter;
  
  int numSections = 20;
  
  PVector bridgeVec = PVector.sub( leftEnd, rightEnd );  
  float sectionSpacing = bridgeVec.mag() / (float) numSections;  
  
  ArrayList<RectangleBody> getHalfCircle(PVector leftPoint, PVector rightPoint) { 
    ArrayList<RectangleBody> halfCircle = new ArrayList<RectangleBody>();
    circleCenter = new Vec2((rightPoint.x + leftPoint.x) / 2, (rightPoint.y + leftPoint.y) / 2); 
    //float radius = sqrt(pow(circleCenter.x - leftPoint.x, 2) + pow(circleCenter.y - leftPoint.y, 2));
    float radius = 100;
    angleBetweenTwoPoints = atan((rightPoint.y - leftPoint.y) / (rightPoint.x - leftPoint.x));
    //println(degrees(angleBetweenTwoPoints));
    //println("numSections: " + numSections);
    
    ArrayList<Vec2> RectanglePos = new ArrayList<Vec2>();
    
    for (int i = (int) degrees(angleBetweenTwoPoints); i < (int) degrees(angleBetweenTwoPoints) + 180; i+=9) {
      float newPointX = radius * cos(radians(i)) + circleCenter.x;
      float newPointY = radius * sin(radians(i)) + circleCenter.y;
      RectanglePos.add(new Vec2((int) newPointX, (int) newPointY));
    }
    
    for(int i = 0; i < numSections + 1; i++ ) {
      RectangleBody section = null;
      if (i == 0 ) {
        PVector sectionPos = new PVector( RectanglePos.get(0).x, RectanglePos.get(0).y );
         section = new RectangleBody( sectionPos.x, sectionPos.y, 15, 10, (int) degrees(angleBetweenTwoPoints) + 90 - (i * 9), BodyType.STATIC, mBox2DRef);
      }
      else if ( i == numSections ) {
        PVector sectionPos = new PVector( RectanglePos.get(numSections - 1 ).x, RectanglePos.get(numSections - 1).y );
        section = new RectangleBody( sectionPos.x, sectionPos.y, 15, 10, (int) degrees(angleBetweenTwoPoints) + 90 - (i * 9), BodyType.STATIC, mBox2DRef);
      }
      else {//all middle sections
       PVector sectionPos = new PVector( RectanglePos.get(i).x, RectanglePos.get(i).y );
       section = new RectangleBody(sectionPos.x, sectionPos.y, 15, 10, (int) degrees(angleBetweenTwoPoints) + 90 - (i * 9), BodyType.STATIC, mBox2DRef);
       }
       
       //now that we have all pieces we want to connect them together with a "stretchy" joint
       if (i > 0) {
         DistanceJointDef djd = new DistanceJointDef();
         RectangleBody previous = halfCircle.get(i-1);
         
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
    
    
    ArrayList<RectangleBody> bufferBowl = getHalfCircle(leftEnd, rightEnd);
    bowl2 = bufferBowl;
  }
  
  void update(PVector posLeft, PVector posRight) {
      ArrayList<RectangleBody> bufferBowl = getHalfCircle(posLeft, posRight);
      destroyBowl();
      bowl2 = bufferBowl;
  }
  
  // A simple function to just draw the edge chain as a series of vertex points
  void display() {
    pushMatrix();
    imageMode(CENTER);
    translate(circleCenter.x, circleCenter.y);
      rotate(angleBetweenTwoPoints);
      image(bowlBack, 0,bowlBack.height/2);
    popMatrix();
    imageMode(CORNER);
    /*for(RectangleBody c : bowl2) {
      c.draw();
    }*/
  }
  
  void displayFront() {
    pushMatrix();
    imageMode(CENTER);
    translate(circleCenter.x, circleCenter.y);
      rotate(angleBetweenTwoPoints);
      tint(255, 85);
      image(bowlFront, 0,bowlFront.height/2);
      noTint();
    popMatrix();
    imageMode(CORNER);
  }
  
  void destroyBowl() {
    for (RectangleBody shape : bowl2) {
        shape.DestroyBody();
      }
  }
}