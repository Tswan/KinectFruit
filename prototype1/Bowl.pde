class Bowl {
  Box2DProcessing mBox2DRef;
  int bowlDiameter = 50;
  
  
  // We'll keep track of all of the surface points
  //ArrayList<Vec2> bowl;
  ArrayList<RectangleBody> bowl2;
  Body previousShape;
  PVector leftEnd = new PVector(800,500);
  PVector rightEnd = new PVector(1000, 500);
  
  int numSections = 20;
  
  PVector bridgeVec = PVector.sub( leftEnd, rightEnd );  
  float sectionSpacing = bridgeVec.mag() / (float) numSections;  
  
  ArrayList<RectangleBody> getHalfCircle(PVector leftPoint, PVector rightPoint) { 
    ArrayList<RectangleBody> halfCircle = new ArrayList<RectangleBody>();
    Vec2 circleCenter = new Vec2((rightPoint.x + leftPoint.x) / 2, (rightPoint.y + leftPoint.y) / 2); 
    //float radius = sqrt(pow(circleCenter.x - leftPoint.x, 2) + pow(circleCenter.y - leftPoint.y, 2));
    float radius = 100;
    float angleBetweenTwoPoints = atan((rightPoint.y - leftPoint.y) / (rightPoint.x - leftPoint.x));
    //println(degrees(angleBetweenTwoPoints));
    //println("numSections: " + numSections);
    
    ArrayList<Vec2> RectanglePos = new ArrayList<Vec2>();
    ArrayList anglesOfPoints = new ArrayList();
    
    for (int i = (int) degrees(angleBetweenTwoPoints); i < (int) degrees(angleBetweenTwoPoints) + 180; i+=9) {
      float newPointX = radius * cos(radians(i)) + circleCenter.x;
      float newPointY = radius * sin(radians(i)) + circleCenter.y;
      RectanglePos.add(new Vec2((int) newPointX, (int) newPointY));
      anglesOfPoints.add(i);
    }
    
    for(int i = 0; i < numSections + 1; i++ ) {
      RectangleBody section = null;
      if (i == 0 ) {
        PVector sectionPos = new PVector( RectanglePos.get(0).x, RectanglePos.get(0).y );
         section = new RectangleBody( sectionPos.x, sectionPos.y, 15, 10, (int) anglesOfPoints.get(i) + 90 - (i * 9), BodyType.STATIC, mBox2DRef);
      }
      else if ( i == numSections ) {
        PVector sectionPos = new PVector( RectanglePos.get(numSections - 1 ).x, RectanglePos.get(numSections - 1).y );
        section = new RectangleBody( sectionPos.x, sectionPos.y, 15, 10, (int) anglesOfPoints.get(i - 1) + 90 - (i * 9), BodyType.STATIC, mBox2DRef);
      }
      else {//all middle sections
         //println(sectionSpacing);
       PVector sectionPos = new PVector( RectanglePos.get(i).x, RectanglePos.get(i).y );
       //PVector sectionPos = new PVector( leftPoint.x, leftPoint.y);
       //sectionPos.add((float) i * sectionSpacing, 0);
       section = new RectangleBody(sectionPos.x, sectionPos.y, 15, 10, (int) anglesOfPoints.get(i) + 90 - (i * 9), BodyType.STATIC, mBox2DRef);
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
    
    /*for (int i = (int) degrees(angleBetweenTwoPoints); i < (int) degrees(angleBetweenTwoPoints) + 180; i++) {
      float newPointX = radius * cos(radians(i)) + circleCenter.x;
      float newPointY = radius * sin(radians(i)) + circleCenter.y;
      halfCircle.add(new Vec2((int) newPointX, (int) newPointY));
      i += 1;
    }*/
    return halfCircle;
  }
  
  Bowl(Box2DProcessing box2D) {
    mBox2DRef = box2D;
    
    
    ArrayList<RectangleBody> bufferBowl = getHalfCircle(leftEnd, rightEnd);
    bowl2 = bufferBowl;
    /*// This is what box2d uses to put the surface in its world
    ChainShape chain = new ChainShape();
    // We can add 9 vertices by making an array of 9 Vec2 objects
    Vec2[] vertices = new Vec2[bowl.size()];
    for (int i = 0; i < vertices.length; i++) {
      Vec2 edge = box2d.coordPixelsToWorld(bowl.get(i));  
      vertices[i] = edge;
    }
    
    chain.createChain(vertices,vertices.length);
    
    // The edge chain is now a body!
    BodyDef bd = new BodyDef();
    previousShape = box2d.createBody(bd);
    // Shortcut, we could define a fixture if we
    // want to specify frictions, restitution, etc.
    previousShape.createFixture(chain,1);*/
  }
  
  void update(PVector posLeft, PVector posRight) {
      ArrayList<RectangleBody> bufferBowl = getHalfCircle(posLeft, posRight);
      for (RectangleBody shape : bowl2) {
        shape.DestroyBody();
      }
      bowl2 = bufferBowl;
      //box2d.destroyBody(previousShape);

      /*// This is what box2d uses to put the surface in its world
      ChainShape chain = new ChainShape();
      
      // We can add 9 vertices by making an array of 9 Vec2 objects
      Vec2[] vertices = new Vec2[bowl.size()];
      for (int i = 0; i < vertices.length; i++) {
        Vec2 edge = box2d.coordPixelsToWorld(bowl.get(i));  
        vertices[i] = edge;
      }
      
      chain.createChain(vertices,vertices.length);
      
      // The edge chain is now a body!
      BodyDef bd = new BodyDef();
      previousShape = box2d.createBody(bd);
      // Shortcut, we could define a fixture if we
      // want to specify frictions, restitution, etc.
      previousShape.createFixture(chain,1);*/
  }
  
  // A simple function to just draw the edge chain as a series of vertex points
  void display() {
    /*strokeWeight(2);
    stroke(0);
    noFill();
    beginShape();
    for (Vec2 v: bowl) {
      vertex(v.x,v.y);
    }
    endShape();
    */
    print (bowl2.size());
    for(RectangleBody c : bowl2) {
      c.draw();
    }
  }
}