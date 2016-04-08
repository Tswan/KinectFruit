class FruitParticle 
{
  float gravity = 0.2;
  float position_x, position_y;
  float velocity_x, velocity_y;
  float angle;
  float angular_velocity;
  PImage particle_image;
  
  FruitParticle(float xPos, float yPos, float xVel, float yVel, PImage image) 
  {
    angle = random(0, 360);
    position_x = xPos;
    position_y = yPos;
    velocity_x = xVel;
    velocity_y = yVel;
    particle_image = image;
  }
  
  void display() 
  {
    pushMatrix();
    translate(position_x, position_y);
    rotate(radians(angle));
    image(particle_image, 0, 0);
    popMatrix();
  }
  
  void update() 
  {
    position_x += velocity_x * 0.5;
    velocity_y += gravity;
    position_y += velocity_y * 0.5;
  }

}