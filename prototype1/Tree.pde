class Tree {
  int treeTypeIndex;
  float fruit_w, fruit_h;
  boolean dead;
  PImage tree_img;
  int tree_height;
  int fadeInLife = 120;
  float x, y;
  
  //Sound effect variables
  boolean collided;
  boolean collidedWithTheBowl;
  int timer;
  int soundDelay = 10000;
  String name;
  
  Tree(float xPos, float yPos, PImage treeImage, int treeIdx) {
    treeTypeIndex = treeIdx;
    tree_img = treeImage;
    tree_height = treeImage.height;
    x = xPos;
    y = yPos - tree_height;
  }
  
  void display() {
    pushMatrix();
    translate(x, y);
    imageMode(CORNER);
    float initialOpacity = 120 - fadeInLife;
    float opacity = map(initialOpacity, 0.0f, 60.0f, 0.0f, 255.0f);
    tint(255, opacity);  // Display at half opacity
    image(tree_img, 0, 0); 
    popMatrix();
    if (fadeInLife > 0) {
      fadeInLife--;
    }
    noTint();
  }
}