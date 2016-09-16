//*******************************************************
// Humans vs. Zombies              Ellen Chen, 10/20/2015
//
// HW3 - Forces (version B)
// A bunch of humans are stuck in an enclosed park with a zom-errr, mutant
// RUN!
//*******************************************************

// attributes
PImage survivorSprite, mutantSprite, treeSprite, parkBackground;

static boolean DEBUG, CAUGHT;
static float BUFFER_AREA = 30;  // checks if the survivors and/or zombies is past the boundaries

Human survivor;
Zombie mutant;  // They're called mutants, not zombies!

ArrayList<Human> survivors = new ArrayList<Human>();
ArrayList<Zombie> mutants = new ArrayList<Zombie>();
ArrayList<Obstacle> blockade;

void setup()
{
  size(800, 600);

  DEBUG = false;

  survivorSprite = loadImage("survivor.png");
  mutantSprite = loadImage("mutant.png");
  treeSprite = loadImage("tree.png");
  parkBackground = loadImage("background.png");

  // Set up the cast of the game
  // Human survivors
  for (int i = 0; i < 5; i++)
  {
    survivors.add(new Human(survivorSprite, random(BUFFER_AREA, (width/2)-BUFFER_AREA), random(BUFFER_AREA, height/2), survivorSprite.width/2, 10, 2, 5));
  }

  // Zom-errr, mutants
  Zombie patientZero = new Zombie(mutantSprite, random((width/2)+BUFFER_AREA, width-BUFFER_AREA), random(height/2, height-BUFFER_AREA), mutantSprite.width/2, 10, 2, 2.75);
  mutants.add(patientZero);

  // Get each other
  // Survivors, know your enemy!
  for (int i = 0; i < survivors.size(); i++)
  {
    for (int j = 0; j < mutants.size(); j++)
    {
      survivors.get(i).getZombies(mutants.get(j));
    }
  }
  // Mutants, know your food!
  for (int i = 0; i < mutants.size(); i++)
  {
    for (int j = 0; j < survivors.size(); j++)
    {
      mutants.get(i).getHumans(survivors.get(j));
    }
  }

  // Set up the obstacles - version B
  blockade = new ArrayList<Obstacle>();
  Obstacle obs1 = new Obstacle(treeSprite, 200, 500, treeSprite.width/2);
  Obstacle obs2 = new Obstacle(treeSprite, 600, 250, treeSprite.width/2);
  Obstacle obs3 = new Obstacle(treeSprite, 350, 400, treeSprite.width/2);
  
  blockade.add(obs1);
  blockade.add(obs2);
  blockade.add(obs3);
  
  for (int i = 0; i < blockade.size(); i++)
  {
    // Get the obstacles for the cast
    for (int j = 0; j < survivors.size(); j++)
    {
      survivors.get(j).getObstacles(blockade.get(i));
    }
    for (int j = 0; j < mutants.size(); j++)
    {
      mutants.get(j).getObstacles(blockade.get(i));
    }
  }
}

void draw()
{
  background(95, 86, 75);
  imageMode(CENTER);
  image(parkBackground, width/2, height/2);
  update();
}

void update()
{
  // Debugging boundaries
  if (DEBUG)
  {
    strokeWeight(2);
    rectMode(CORNERS);
    rect(BUFFER_AREA, BUFFER_AREA, width-BUFFER_AREA, height-BUFFER_AREA);
    strokeWeight(1);
  }

  textSize(16);
  fill(0);
  text("Press 'SPACE' to toggle Debug Mode", width/2+(BUFFER_AREA*2), height-(BUFFER_AREA/3));
  if (DEBUG)
  {
    text("Alt = nuke 'em", BUFFER_AREA*2, height-(BUFFER_AREA/3));
    fill(62, 247, 171);
    text("Left click = spawn mutant", BUFFER_AREA*2, BUFFER_AREA/1.5);
    text("Right click = spawn human", BUFFER_AREA*10, BUFFER_AREA/1.5);
  }
  noFill();

  // Survivors/humans
  for (int i = 0; i < survivors.size(); i++)
  {
   survivors.get(i).update();
   survivors.get(i).display();
  }

  // Zom-errr, mutants
  for (int i = 0; i < mutants.size(); i++)
  {
   mutants.get(i).update();
   mutants.get(i).display();

   // Checks if any mutant has caught any living survivor
   if (CAUGHT && survivors.size() != 0)
   {
     // Convert him into the mutants' fold! Mwahahahahahaha!
     // I mean, spawn a new mutant
     removeSurvivor(mutants.get(i));
   }
  }

  // Blockades
  for (int i = 0; i < blockade.size(); i++)
  {
  blockade.get(i).display();
  }
}

void removeSurvivor(Zombie z)
{
  // Get the mutant's victim
  Human tempSurvivor = z.victim;
  survivors.remove(tempSurvivor);

  // Spawn a new mutant
  Zombie survivorVictim = new Zombie(mutantSprite, tempSurvivor.position.x, tempSurvivor.position.y, tempSurvivor.radius, 10, 1.5, 2.5);

  // Carry over the mutants' lists to the new mutant
  for (int i = 0; i < survivors.size(); i++)
  {
    survivorVictim.getHumans(survivors.get(i));

    survivors.get(i).getZombies(survivorVictim);
  }
  for (int i = 0; i < blockade.size(); i++)
  {
   survivorVictim.getObstacles(blockade.get(i));
  }

  mutants.add(survivorVictim);

  // Remove the survivor from the mutants' list (if any)
  for (int i = 0; i < mutants.size(); i++)
  {
    // From the mutants' list of prey...
    mutants.get(i).prey.remove(tempSurvivor);
    mutants.get(i).checkForVictim = false;  // reset
  }

  // Reset
  z.victim = null;
  CAUGHT = false;
}


//----------------------------
// Mouse and key events
//----------------------------
// Spawn new survivors or mutants
void mousePressed()
{
  if (DEBUG)
  {
    if (mouseButton == LEFT)
    {
      // Spawn a mutant
      Zombie newMutant = new Zombie(mutantSprite, mouseX, mouseY, mutantSprite.width/2, 10, 2, 2.75);

      // Get the list of survivors on the map
      for (int i = 0; i < survivors.size(); i++)
      {
        newMutant.getHumans(survivors.get(i));

        survivors.get(i).getZombies(newMutant);
      }

      // Get the list of obstacles on the map
      for (int i = 0; i < blockade.size(); i++)
      {
        newMutant.getObstacles(blockade.get(i));
      }

      mutants.add(newMutant);  // add the mutant into the group
    }
    if (mouseButton == RIGHT)
    {
      // Spawn a survivor
      Human newSurvivor = new Human(survivorSprite, mouseX, mouseY, survivorSprite.width/2, 10, 2, 3);

      // Get the list of mutants on the map
      for (int i = 0; i < mutants.size(); i++)
      {
        newSurvivor.getZombies(mutants.get(i));

        mutants.get(i).getHumans(newSurvivor);
      }

      // Get the list of obstacles on the map
      for (int i = 0; i < blockade.size(); i++)
      {
        newSurvivor.getObstacles(blockade.get(i));
      }

      survivors.add(newSurvivor);  // add the mutant into the group
    }
  }
}

// Toggle Debug Mode on or off
// or detonate a nuclear bomb in a split second
void keyPressed()
{
  if (key == ' ')
  {
    if (!DEBUG)
    {
      DEBUG = true;
    } else
    {
      DEBUG = false;
    }
  }
  if (key == CODED)
  {
    if (keyCode == ALT)
    {
      if (DEBUG)
      {
        survivors.clear();
        mutants.clear();
      }
    }
  }
}