class Fruit {
  Box2DProcessing box2d;
  PolygonShape bananaShape;
  Body body;
  float fruit_w, fruit_h;
  PImage banana = loadImage("PENTANANA_500.png");
  
  /*Fruit(float x, float y, float w, float h) {
    fruit_w = w;
    fruit_h = h;
    // This function puts the fruit in the Box2d world
    makeBody(new Vec2(x, y), w, h);
  }*/
  
  Fruit(float x, float y, ArrayList<PVector> vrts, Box2DProcessing mBox2DRef) {
    box2d = mBox2DRef;
    int numVrts = vrts.size();
    Vec2 center = new Vec2(x, y);
    Vec2[] vertices = new Vec2[numVrts];
    for(int i = 0; i < numVrts; i++ )
    {
        vertices[i] = box2d.vectorPixelsToWorld(new Vec2(vrts.get(i).x,vrts.get(i).y)); 
    }
    
    // This function puts the fruit in the Box2d world
    PolygonShape sd = new PolygonShape();
    //float box2dW = box2d.scalarPixelsToWorld(w_/2);
    //float box2dH = box2d.scalarPixelsToWorld(h_/2);
    //sd.setAsBox(box2dW, box2dH);
    //println(vertices[0] + " " + vertices[numVrts]);
    sd.set(vertices, vertices.length);
    bananaShape = sd;
    
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1f;
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
  
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-a);
    stroke(0);
    fill(225,35,0);
    image(banana, 0, 0); 
    beginShape();
    //println(vertices.length);
    // For every vertex, convert to pixel vector
    for (int i = 0; i < bananaShape.getVertexCount(); i++) {
      Vec2 v = box2d.vectorWorldToPixels(bananaShape.getVertex(i));
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
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
    fd.density = 1f;
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
}