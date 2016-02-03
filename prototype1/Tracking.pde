class Tracking
{
  Kinect kinect;
  ArrayList <SkeletonData> bodies;
  int skeletonIndex;
  
  Tracking(processing.core.PApplet _p) 
  {
    kinect = new Kinect(_p);
    bodies = new ArrayList<SkeletonData>();
    
  }
  
  Kinect returnKinect()
  {
    return kinect;
  }
  
  int getBodySize()
  {
    return bodies.size();
  }
  
  SkeletonData getBodyData(int index)
  {
    skeletonIndex = index;
    return bodies.get(index);    
  }
  
  ArrayList <SkeletonData> getBodies()
  {
    return bodies;
  }
  
  void addJoint(SkeletonData _s)
  {
    bodies.add(_s);
  }
  
  void updateJoint(int i, SkeletonData _a)
  {
    bodies.get(i).copy(_a);
  }
  
  void removeJoint(int i)
  {
    bodies.remove(i);
  }
  
  PVector checkJoint( int _j1)
  {
    SkeletonData _s = bodies.get(skeletonIndex);
    PVector pos = null;
    if (_s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED)
    {
      pos = new PVector(_s.skeletonPositions[_j1].x*width, _s.skeletonPositions[_j1].y*height);
    }
    return pos;
  }
  
  PVector getLeftHandPos()
  {
    PVector pos = checkJoint(Kinect.NUI_SKELETON_POSITION_HAND_LEFT);
    return pos;
  }
  
  PVector getRightHandPos()
  {
    PVector pos = checkJoint(Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);
    return pos;
  }
  
  void drawPosition(SkeletonData _s) 
  {
    noStroke();
    fill(0, 100, 255);
    String s1 = str(_s.dwTrackingID);
    text(s1, _s.position.x*width, _s.position.y*height);
    //text(s1, _s.position.x*width/2, _s.position.y*height/2);
  }
  
  void drawSkeleton(SkeletonData _s) 
  {
    // Body
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HEAD, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
    Kinect.NUI_SKELETON_POSITION_SPINE);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
    Kinect.NUI_SKELETON_POSITION_SPINE);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_SPINE);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SPINE, 
    Kinect.NUI_SKELETON_POSITION_HIP_CENTER);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
    Kinect.NUI_SKELETON_POSITION_HIP_LEFT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
  
    // Left Arm
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
    Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT, 
    Kinect.NUI_SKELETON_POSITION_WRIST_LEFT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 
    Kinect.NUI_SKELETON_POSITION_HAND_LEFT);
    printTestCoord(_s, 
    Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 
    Kinect.NUI_SKELETON_POSITION_HAND_LEFT);
  
    // Right Arm
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);
    printTestCoord(_s, 
    Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);
  
    // Left Leg
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
    Kinect.NUI_SKELETON_POSITION_KNEE_LEFT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_KNEE_LEFT, 
    Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT, 
    Kinect.NUI_SKELETON_POSITION_FOOT_LEFT);
  
    // Right Leg
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT);
    DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_FOOT_RIGHT);
  }
  
  void DrawBone(SkeletonData _s, int _j1, int _j2) 
  {
    noFill();
    stroke(255, 255, 0);
    if (_s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
      _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
      line(_s.skeletonPositions[_j1].x*width, // /2,
      _s.skeletonPositions[_j1].y*height, // /2,
      _s.skeletonPositions[_j2].x*width, // /2,
      _s.skeletonPositions[_j2].y*height); // /2);
    }
  }
  
  void appearEvent(SkeletonData _s) 
  {
    if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
    {
      return;
    }
    synchronized(bodies) {
      bodies.add(_s);
    }
  }
  
  void disappearEvent(SkeletonData _s) 
  {
    synchronized(bodies) {
      for (int i=bodies.size ()-1; i>=0; i--) 
      {
        if (_s.dwTrackingID == bodies.get(i).dwTrackingID) 
        {
          bodies.remove(i);
        }
      }
    }
  }
  
  void moveEvent(SkeletonData _b, SkeletonData _a) 
  {
    if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
    {
      return;
    }
    synchronized(bodies) {
      for (int i=bodies.size ()-1; i>=0; i--) 
      {
        if (_b.dwTrackingID == bodies.get(i).dwTrackingID) 
        {
          bodies.get(i).copy(_a);
          break;
        }
      }
    }
  }
  
  void printTestCoord(SkeletonData _s, int _j1, int _j2)
  {
    if (_s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
      _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
      //print(" wristX: " + _s.skeletonPositions[_j1].x*width); 
      //print(" wristY: " + _s.skeletonPositions[_j1].y*height);
      noStroke();
      fill(0,255,0);
      ellipse(_s.skeletonPositions[_j1].x*width, _s.skeletonPositions[_j1].y*height,10,10);
      fill(0,0,255);
      ellipse(_s.skeletonPositions[_j2].x*width, _s.skeletonPositions[_j2].y*height,20,20);
      //print(" handX: " + _s.skeletonPositions[_j2].x*width);
      //print(" handY: " + _s.skeletonPositions[_j2].y*height);
    }
  }
  
  
  
}