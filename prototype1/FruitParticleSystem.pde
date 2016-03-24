class FruitParticleSystem {
  int lifeTime = 3000;
  int numOfParticles = 30;
  ArrayList<FruitParticle> particles = new ArrayList<FruitParticle>();
  FruitParticleSystem(float xPos, float yPos, PImage image) {
    for (int i = 0; i < numOfParticles; i++) {
      particles.add(new FruitParticle(xPos, yPos, random(-5, 5), random(-5, 5), image));
    }
  }
  void update() {
    for (FruitParticle particle: particles) {
      particle.update();
    }
    lifeTime--;    
  }
  
  boolean isDead() {
    if (lifeTime <= 0) {
      return true;
    }
    else {
      return false;
    }
  }
  
  void display() {
    for (FruitParticle particle: particles) {
      particle.display();
    }
  }
}