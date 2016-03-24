class Tree {
  int treeTypeIndex;
  float fruit_w, fruit_h;
  boolean dead;
  PImage tree_img;
  int tree_height;
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
    image(tree_img, 0, 0); 
    popMatrix();
  }
}