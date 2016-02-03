class Bowl {
  // We'll keep track of all of the surface points
  ArrayList<Vec2> bowl;
  Body previousShape;
  PVector leftEnd = new PVector(0, 0);
  PVector rightEnd = new PVector(300, 100);
  
  ArrayList<Vec2> getHalfCircle(PVector leftPoint, PVector rightPoint) {
    ArrayList<Vec2> halfCircle = new ArrayList<Vec2>();
    Vec2 circleCenter = new Vec2((rightPoint.x + leftPoint.x) / 2, (rightPoint.y + leftPoint.y) / 2); 
    float radius = sqrt(pow(circleCenter.x - leftPoint.x, 2) + pow(circleCenter.y - leftPoint.y, 2));
    float angleBetweenTwoPoints = atan((rightPoint.y - leftPoint.y) / (rightPoint.x - leftPoint.x));
    println(degrees(angleBetweenTwoPoints));
    for (int i = (int) degrees(angleBetweenTwoPoints); i < (int) degrees(angleBetweenTwoPoints) + 180; i++) {
      float newPointX = radius * cos(radians(i)) + circleCenter.x;
      float newPointY = radius * sin(radians(i)) + circleCenter.y;
      halfCircle.add(new Vec2((int) newPointX, (int) newPointY));
      i += 1;
    }
    return halfCircle;
  }
  
  Bowl() {
    ArrayList<Vec2> bufferBowl = getHalfCircle(leftEnd, rightEnd);
    bowl = bufferBowl;
    // This is what box2d uses to put the surface in its world
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
    previousShape.createFixture(chain,1);
  }
  
  void update(PVector posLeft, PVector posRight) {
      ArrayList<Vec2> bufferBowl = getHalfCircle(posLeft, posRight);
      bowl = bufferBowl;
      box2d.destroyBody(previousShape);

      // This is what box2d uses to put the surface in its world
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
      previousShape.createFixture(chain,1);
  }
  
  // A simple function to just draw the edge chain as a series of vertex points
  void display() {
    strokeWeight(2);
    stroke(0);
    noFill();
    beginShape();
    for (Vec2 v: bowl) {
      vertex(v.x,v.y);
    }
    endShape();
  }
}