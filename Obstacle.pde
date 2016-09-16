//*******************************************************
// Obstacle                        Ellen Chen, 9/29/2015
//
// An obstacle
//*******************************************************

class Obstacle
{
  // attributes
  PImage sprite;
  PVector position;
  float radius, debugArea;
  
  // Constructor
  Obstacle(PImage img, float x, float y, float r)
  {
    sprite = img;
    position = new PVector(x, y);
    
    radius = r;
    debugArea = radius*4;
  }
  
  // Display!
  void display()
  {
    if (DEBUG)
    {
      fill(111, 203, 192, 127);
      ellipse(position.x, position.y, debugArea, debugArea);
      noFill();
    }
    imageMode(CENTER);
    image(sprite, position.x, position.y);
  }
}