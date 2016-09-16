//*******************************************************
// Zombie                          Ellen Chen, 9/29/2015
//
// A horrifying zom-errr, mutant
// Did someone released the T-Virus, Devil's Breath,
// or that drug in Time Crisis 5?
//*******************************************************

class Zombie extends Vehicle
{
  // attributes
  PVector steeringForce;

  boolean hunting;  // has it spotted a human?
  boolean checkForVictim = false;
  ArrayList<Human> prey = new ArrayList<Human>();
  Human victim = null;  // Oh gawd, it caught something

  // Constructor
  Zombie(PImage img, float x, float y, float r, float m, float ms, float mf)
  {
    super(img, x, y, r, m, ms, mf);

    // Set up PVectors
    steeringForce = new PVector(0, 0);

    hunting = true;  // default
  }

  //-------------------------------------
  // Abstract methods
  //-------------------------------------
  // Display!
  void display()
  {
    //calculate the direction of the current velocity 
    float angle = velocity.heading();   

    // Debugging - safe distance/aura
    if (DEBUG)
    {
      ellipseMode(CENTER);
      fill(252, 74, 77, 127);
      ellipse(position.x, position.y, safeDistance, safeDistance);
      noFill();
    }

    // Create the mutant
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

  // Get that puny human!
  // and ea-err, take them into your fold!
  void calcSteeringForces()
  {
    // Determine what the mutant will do depending on situation
    if (hunting)
    {
      float searchRadius = safeDistance*3;

      // Get the force to chase after a survivor
      PVector steerForce = new PVector(0, 0);

      if (!checkForVictim)
      {
        // No survivor to chase? Find one!
        wander(radius);  // wander for a bit

        // Get the force to avoid the obstacles from calling avoidObstacle()
        PVector avoidForce = new PVector(0, 0);
        for (int i = 0; i < obstacle.size(); i++)
        {
          avoidForce.add(avoidObstacle(obstacle.get(i), safeDistance));
        }

        // Apply the force to acceleration
        applyForce(avoidForce);

        // Check for any nearby survivors
        for (int i = 0; i < prey.size(); i++)
        {
          // Get distance from any survivor on the map
          PVector distanceVector = PVector.sub(prey.get(i).position, position);

          if (distanceVector.mag() <= searchRadius)
          {
            // Gotcha
            victim = prey.get(i);
            checkForVictim = true;
            break;
          }
        }
      } else
      {
        // Get the seeking and arriving forces to chase the survivor
        steerForce.add(pursue(victim));
        arrive(victim);

        // Get the force to avoid the obstacles from calling avoidObstacle()
        for (int i = 0; i < obstacle.size(); i++)
        {
          steeringForce.add(avoidObstacle(obstacle.get(i), safeDistance));
        }

        //add the above forces to this overall steering force
        steeringForce.add(steerForce);
        steeringForce.add(checkBoundaries());

        //limit this seeker's steering force to a maximum force
        steeringForce.limit(maxForce);  

        //apply this steering force to the vehicle's acceleration
        applyForce(steeringForce);

        //reset the steering force to 0
        steeringForce.mult(0);

        // Get the distance between the survivor and the mutant
        PVector distanceFromVictim = PVector.sub(victim.position, position);
        if (distanceFromVictim.mag() <= victim.radius && !CAUGHT)
        {
          CAUGHT = true;
          checkForVictim = false;
        }
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
  // Foooooooooooddddddd
  void getHumans(Human target)
  {
    prey.add(target);
  }
}