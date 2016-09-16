//*******************************************************
// Human                          Ellen Chen, 9/29/2015
//
// An unlucky human
// RUN!
//*******************************************************

class Human extends Vehicle
{
  // attributes
  PVector steeringForce;

  boolean evading;  // is there a zombie nearby?
  boolean checkForZombie = false;
  ArrayList<Zombie> predators = new ArrayList<Zombie>();

  Zombie hunter = null;

  // Constructor
  Human(PImage img, float x, float y, float r, float m, float ms, float mf)
  {
    super(img, x, y, r, m, ms, mf);

    // Set up Pvectors
    steeringForce = new PVector(0, 0);

    evading = true;  // default
  }

  //-------------------------------------
  // Abstract methods
  //-------------------------------------
  // Display
  void display()
  {
    // Calculate the direction of current velocity 
    float angle = velocity.heading();   

    // Debugging - safe distance/aura
    if (DEBUG)
    {
      ellipseMode(CENTER);
      fill(74, 252, 185, 127);
      ellipse(position.x, position.y, safeDistance, safeDistance);
      noFill();
    }

    // Draw the character
    imageMode(CENTER);
    pushMatrix();
    translate(position.x, position.y);
    rotate(angle);
    image(sprite, 0, 0);
    popMatrix();

    // Debugging - forward and right vectors
    if (DEBUG)
    {
      strokeWeight(2);
      stroke(237, 154, 65);
      line(position.x, position.y, position.x+(forward.copy().x*radius), position.y+(forward.copy().y*radius));  // forward vector
      stroke(65, 140, 237);
      line(position.x, position.y, position.x+(right.copy().x*radius), position.y+(right.copy().y*radius));      // right vector
      strokeWeight(1);
      stroke(0);
    }
  }

  // No, seriously. RUN!
  void calcSteeringForces()
  { 
    // Determine what the survivor will do depending on situation
    if (evading)
    {
      float searchRadius = safeDistance*5;

      if (!checkForZombie)
      {
        // No mutants around? You sure?
        wander(radius);  // wander for a bit

        // Get the force to avoid the obstacles from calling avoidObstacle()
        for (int i = 0; i < obstacle.size(); i++)
        {
         steeringForce.add(avoidObstacle(obstacle.get(i), safeDistance));
        }

        // Check for any nearby mutants
        for (int i = 0; i < predators.size(); i++)
        {
          // Get distance from any mutant on the map
          PVector distanceVector = PVector.sub(predators.get(i).position, position);

          if (distanceVector.mag() <= searchRadius)
          {
            // Oh no! Warning mode activate!
            searchRadius = distanceVector.mag();
            checkForZombie = true;
            break;
          }
        }
      } else
      {
        // Get the force to run from a mutant
        PVector fleeForce = new PVector(0, 0);
        for (int i = 0; i < predators.size(); i++)
        {
          if ((PVector.sub(predators.get(i).position, position)).mag() <= searchRadius)
          {
            searchRadius = safeDistance*3;
            
            fleeForce.add(evade(predators.get(i)));
          }
          else
          {
            searchRadius = safeDistance*5;
          }
        }
        
        // No mutants around for now?
        if (fleeForce.mag() == 0)
        {
          wander(radius);
        }

        // Get the force to avoid the obstacles from calling avoidObstacle()
        for (int i = 0; i < obstacle.size(); i++)
        {
         steeringForce.add(avoidObstacle(obstacle.get(i), safeDistance));
        }

        // Add the above forces to this overall steering force
        steeringForce.add(fleeForce);
        steeringForce.add(checkBoundaries());

        // Limit this survivor's steering force to the vehicle's acceleration
        steeringForce.limit(maxForce);

        // Apply this steering force to the survivor's acceleration
        applyForce(steeringForce);

        // Reset the steering force
        steeringForce.mult(0);
      }
    } else
    {
      // THIS IS ENTIRELY FOR DEBUGGING PURPOSES!
      wander(radius);

      // Get the force to avoid the obstacles from calling avoidObstacle()
      PVector avoidForce = new PVector(0, 0);
      for (int i = 0; i < obstacle.size(); i++)
      {
       avoidForce = avoidObstacle(obstacle.get(i), safeDistance);
      }

      applyForce(avoidForce);
    }
  }


  //-------------------------------------
  // Class methods
  //-------------------------------------
  // We're not alone, are we?
  void getZombies(Zombie z)
  {
    predators.add(z);
  }
}