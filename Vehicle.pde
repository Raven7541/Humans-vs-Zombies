//*******************************************************
// Vehicle                        Ellen Chen, 9/29/2015
//
// Vehicle movement
//*******************************************************

abstract class Vehicle
{
  // attributes
  PImage sprite;
  PShape body;
  PVector position, velocity, acceleration;

  PVector forward, right;  // orientation vectors
  float maxSpeed, maxForce;  // limits
  float radius, mass;

  float safeDistance;

  float wanderTheta = 0;  // angle at which the vehicle will wander randomly

  ArrayList<Obstacle> obstacle = new ArrayList<Obstacle>();  // obstacles on the map - version B

  // Constructor
  Vehicle(PImage img, float x, float y, float r, float m, float ms, float mf)
  {
    sprite = img;

    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);

    forward = new PVector(0, 0);
    right = new PVector(0, 0);

    radius = r;
    mass = m;
    maxSpeed = ms;
    maxForce = mf;

    safeDistance = radius*4;
  }

  //--------------------------------
  //Abstract methods
  //--------------------------------
  abstract void calcSteeringForces();
  abstract void display();


  //--------------------------------
  // Class methods
  //--------------------------------

  // Update!
  void update()
  {
    // Calculate the steering forces
    calcSteeringForces();

    //add acceleration to velocity, limit the velocity, and add velocity to position
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);

    //calculate forward and right vectors
    forward = velocity.copy();  // forward vector
    forward.normalize();

    right = forward.copy();  // right vector
    right.rotate(PI/2);

    //reset acceleration
    acceleration.mult(0);
  }

  // Apply force onto vehicle
  void applyForce(PVector force)
  {
    acceleration.add(PVector.div(force, mass));
  }

  // Get where the obstacles are on the map
  void getObstacles(Obstacle block)
  {
    obstacle.add(block);
  }


  //---------------------------------
  // Steering methods
  //---------------------------------
  // Seek the target
  PVector seek(PVector targetPos)
  {
    //float chaseSpeed = maxSpeed*5;  // speed to chase

    // Calculate desired velocity
    PVector desiredVelocity = PVector.sub(targetPos, position); 

    desiredVelocity.normalize();
    desiredVelocity.mult(maxSpeed);

    // Calculate steering force
    PVector steeringForce = PVector.sub(desiredVelocity, velocity);
    steeringForce.limit(maxForce);

    return steeringForce;
  }


  // Flee from the mutant
  PVector flee(PVector targetPos)
  {
    // Calculate desired velocity
    PVector desiredVelocity = PVector.sub(position, targetPos); 

    desiredVelocity.normalize();
    desiredVelocity.mult(maxSpeed);

    // Calculate the steering force
    PVector steeringForce = PVector.sub(desiredVelocity, velocity);
    steeringForce.limit(maxForce);

    return steeringForce;
  }


  // Pursue the survivor
  PVector pursue(Human target)
  {
    // Calculate desired velocity from distance between mutant and survivor
    PVector distanceVector = PVector.sub(target.position, position);

    // Calculate the time it'll take to pursue
    float time = distanceVector.mag() / target.maxSpeed;

    // Predict the future position of survivor
    PVector futurePos = PVector.add(target.position, PVector.mult(target.velocity, time));

    // Debug - futurePos
    if (DEBUG)
    {
      stroke(255, 10, 10);
      line(position.x, position.y, futurePos.x, futurePos.y);
      ellipseMode(CENTER);
      ellipse(futurePos.x, futurePos.y, 10, 10);
      stroke(0);
    }

    // Return with seek()
    return seek(futurePos);
  }


  // Evade the mutant
  PVector evade(Zombie target)
  {
    // Calculate desired velocity from distance between mutant and survivor
    //PVector distanceVector = PVector.sub(target.position, position);

    // Calculate the time it'll take to evade
    float time = 20;

    // Predict the future position of mutant
    PVector futurePos = PVector.add(target.position, PVector.mult(target.velocity, time));

    // Debug - futurePos
    if (DEBUG)
    {
      stroke(255, 227, 10);
      line(position.x, position.y, futurePos.x, futurePos.y);
      ellipseMode(CENTER);
      ellipse(futurePos.x, futurePos.y, 10, 10);
      stroke(0);
    }

    // Return with flee()
    return flee(futurePos);
  }

  // What to do when arriving at target
  void arrive(Human target)
  {
    PVector desiredVelocity = PVector.sub(target.position, position);

    float distance = desiredVelocity.mag();  
    desiredVelocity.normalize();

    // Checks if the pursuer has reached within the target's safe zone
    if (distance < target.safeDistance)
    {
      // Set the magnitude according to how close it is
      float m = map(distance, 0, target.safeDistance, 0, maxSpeed);
      desiredVelocity.mult(m);
    } else if (distance == 0)
    {
      CAUGHT = true;
    } else
    {
      // Otherwise, proceed at max speed
      desiredVelocity.mult(maxSpeed);
    }

    // Calculate steering force
    PVector steeringForce = PVector.sub(desiredVelocity, velocity);
    steeringForce.limit(maxForce);

    applyForce(steeringForce);
  }


  // Wander around
  void wander(float r)
  {  
    // Predict future position
    PVector futurePos = velocity.copy();
    futurePos.normalize();
    futurePos.mult(safeDistance);
    futurePos.add(position);

    // Set the desired point
    PVector futureOffSet = new PVector(r*cos(wanderTheta), r*sin(wanderTheta));  // polar coordinates
    PVector target = PVector.add(futurePos, futureOffSet);

    wanderTheta += random(-PI, PI);

    // Debugging
    if (DEBUG)
    {
      ellipseMode(CENTER);         
      line(position.x, position.y, futurePos.x, futurePos.y);    // future position
      ellipse(futurePos.x, futurePos.y, r*2, r*2);                   
      line(futurePos.x, futurePos.y, target.x, target.y);        // desired point
      ellipse(target.x, target.y, 5, 5);
    }

    //Make the vehicle wander 
    applyForce(seek(target));
    applyForce(checkBoundaries());  // and check for boundaries
  }


  // Avoid any obstacles on the map - version B
  PVector avoidObstacle(Obstacle block, float safeDistance)
  {
    // Instantiate steering force and desired velocity
    PVector steerForce = new PVector(0, 0);
    PVector desiredVelocity = new PVector(0, 0);

    // Calculate vector from the character to the center of the obstacle
    PVector vectorToCenter = PVector.sub(block.position, position);

    // Debugging - distance from obstacle
    if (DEBUG)
    {
      stroke(255, 72, 252, 127);
      line(position.x, position.y, position.x+vectorToCenter.x, position.y+vectorToCenter.y);
      stroke(0);
    }

    // Calculate distance
    float vectorToCenterMag = vectorToCenter.mag();

    if (safeDistance < (vectorToCenterMag - (block.radius + radius)) || PVector.dot(vectorToCenter, forward) < 0)
    {
      // Too far!
      return steerForce;
    }

    // Find the distance between the centers of vehicle and obstacle
    float distance = PVector.dot(vectorToCenter, right); 

    if (abs(distance) > (radius + block.radius))
    {
      // Still too far!
      return steerForce;
    } else if (distance > 0)
    {
      // Turn left!
      desiredVelocity = PVector.mult(right, -maxSpeed);
    } else
    {
      // Turn right!
      desiredVelocity = PVector.mult(right, maxSpeed);
    }

    // Calculate the steering force to dodge
    steerForce = PVector.sub(desiredVelocity, velocity);
    steerForce.mult(safeDistance/distance);  // multipily force with weight

    return steerForce;
  }


  // Check if vehicle has gone out of bounds
  PVector checkBoundaries()
  {
    PVector desiredVelocity = new PVector(0, 0);
    PVector steer = new PVector(0, 0);

    PVector center = new PVector(width/2, height/2);  // center of screen

    // Check if it has gone out of bounds
    if (position.x <= BUFFER_AREA || position.y < BUFFER_AREA || position.x > width-BUFFER_AREA || position.y > height-BUFFER_AREA)
    {
      //Calculate desired velocity while retaining y-position
      desiredVelocity = PVector.sub(center, position);

      desiredVelocity.normalize();
      desiredVelocity.mult(10);

      // Calculate steering force to move back inside
      steer = PVector.sub(desiredVelocity, velocity);
    } 

    return steer;
  }
}