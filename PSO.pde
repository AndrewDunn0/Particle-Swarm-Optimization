import processing.pdf.*;



final boolean USE_IMAGE = true;
    // If you are using an image, define the image file name
    final String IMAGE_NAME = "blotches.png";
   
    // If you are not using an image, define the size
    final int IMAGE_WIDTH = 1000;
    final int IMAGE_HEIGHT = 500;

    
final int FILL_AMOUNT = 150;
final int STROKE_AMOUNT = 55;


final int NUM_SWARM_UPDATES = 40;
final int NUM_OUTPUT = 10;

final boolean SAVE_IMAGES = false;


PImage sourceImg;

int timesOutputed;
int timesDrawn;


Swarm _swarm;

// returns a number between 0 and 255 where 255 is the center of the image 
// and 0 is the furthest point from the center
float distanceFromCenter(int x, int y)
  {
      // distance from the middle
      float dis = sqrt(pow((width/2.0 - x),2) + pow((height/2.0 - y),2));
      
      // max distance from middle
      float maxDistanceFromMiddle = sqrt(pow(width,2) + pow(height,2));
      dis = maxDistanceFromMiddle - dis;
  
      //System.out.println(x + " " + y + " " + dis);
  
      // Normalize the result to be between 0 and 255
      dis = (dis - sqrt(pow(width/2,2) + pow(height/2,2))) * 255/sqrt(pow(width/2,2) + pow(height/2,2)); 
  
      return dis;
  }

void setup() 
{

  timesDrawn = 0;
  
  background(255);


  if(USE_IMAGE)
  {
    sourceImg = loadImage(IMAGE_NAME);
    size(sourceImg.width, sourceImg.height);
  }
  else
  {
    size(IMAGE_WIDTH,IMAGE_HEIGHT);
  }

  smooth();
 

  stroke(0,STROKE_AMOUNT);
  
  frameRate(10);
  
  
  if(USE_IMAGE)
  {
    sourceImg.loadPixels(); 
  }
  
  // create the Swarm
  _swarm = new Swarm();

}




void draw() 
{
    background(255);
  
//    for( int i = 0; i < width; i++ )
//    {
//      for( int j = 0; j < height; j++ )
//      {
//        float f = distanceFromCenter(i, j);
//        
//        color c = color(f, f, f);
//        set(i, j, c);
//      }
//    }
    
    //image(sourceImg, 0, 0);
    
    
    
    
    
    
    _swarm.updateLocations();   
    _swarm.display();
    
    
    timesDrawn++;
    
    if( SAVE_IMAGES )
    {
      saveFrame("ParticleSwarm" + timesOutputed + "-######.png");
    }
    

    System.out.println("UPDATE " + (timesDrawn) + "/" + NUM_SWARM_UPDATES + " " + _swarm.getBestF() + " (" + _swarm.getBestX() + "," + _swarm.getBestY()+ ")");
    

    if(timesDrawn % NUM_SWARM_UPDATES == 0)
    {
      timesDrawn = 0;
      timesOutputed++;
      
      System.out.println("****************************************");
      _swarm.randomize();
    }

    
    if( timesOutputed > NUM_OUTPUT -1)
    {
      //saveFrame("coverPicture-######.png");
      noLoop();
    }
    
    
}


////////////////////////////////////////////////////////////////////////
class Swarm
{
  int NUM_PARTICLES = 75;
  Particle [] particles = new Particle[NUM_PARTICLES];
  
  float gBestF = -1;
  
  int gBestX = -1;
  int gBestY = -1;
  
  
  Swarm()
  {
    for( int i = 0; i < NUM_PARTICLES; i++)
    {
      particles[i] = new Particle();
    }
    //randomize();
    
  }
  
  float getBestF()
  {
    return gBestF;
  }
  
  float getBestX()
  {
    return gBestX;
  }
  
  float getBestY()
  {
    return gBestY;
  }
  
  void randomize()
  {
    gBestF = -1;
  
    gBestX = -1;
    gBestY = -1;
    
    for( int i = 0; i < NUM_PARTICLES; i++)
    {
      particles[i].randomize();
    }
    
    updateGlobalBest();
  }
  
  void updateGlobalBest()
  {
    for( int i = 0; i < NUM_PARTICLES; i++)
    {
      if(particles[i].f() > gBestF)
      {
        gBestF = particles[i].f();
        gBestX = particles[i].getX();
        gBestY = particles[i].getY();
      }
    }
  }
  
  void updateLocations()
  {
    for( int i = 0; i < NUM_PARTICLES; i++)
    {
      particles[i].updateLocation(gBestX, gBestY);
    }
    
    updateGlobalBest();
  }
  
  void display()
  {
    for( int i = 0; i < NUM_PARTICLES; i++)
    {
      particles[i].display();
    }
  }
}

////////////////////////////////////////////////////////////////////////
class Particle
{
  // used for different display types
  final int ELLIPSESIZE = 10;
  final int NUM_CURVE_POINTS = 4;
  
  // store all the previous positions of the particle
  ArrayList<Integer> xList = new ArrayList<Integer>();
  ArrayList<Integer> yList = new ArrayList<Integer>();
  
  // the information for the best local point seen so far
  float bestF = -1;
  
  int bestX = -1;
  int bestY = -1;
  
  // the current velocity
  float vX = 0;
  float vY = 0;
  
  //Constants as suggested by :http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=870279&tag=1 
  // Found via squishyMage at http://stackoverflow.com/questions/8802744/particle-swarm-optimization
  float w = 0.729844;
  float c1 = 1.49618;
  float c2 = 1.49618;
  
  // Particle constructor
  Particle()
  {

    randomize();
  }
  
  // return the x coord
  int getX()
  { 
    if(xList.size() > 0)
    {
      return xList.get(xList.size()-1);
    }
    return -1;
  }
  
  // return the y coord
  int getY()
  { 
    if(yList.size() > 0)
    {
      return yList.get(yList.size()-1);
    }
    return -1;
  }
  
  // randomize the position of the particle
  void randomize()
  {
    
    xList.clear();
    yList.clear();
    
  
     bestF = -1;
  
     bestX = -1;
     bestY = -1;
  
     vX = 0;
     vY = 0;
    
    int x = (int)random(width);
    int y = (int)random(height);
    
    xList.add(x);
    yList.add(y);
    
    
    updateBestF();
  }
  
  // the value of the function at the current position
  // the function can be either the value from an image or a 
  // mathematical function
  float f()
  {
    
    float avg;
    
    if(USE_IMAGE)
    {
      int loc = getX() + getY()*width;
      
      
      // The functions red(), green(), and blue() pull out the 3 color components from a pixel.
      float r = red(sourceImg.pixels[loc]);
      float g = green(sourceImg.pixels[loc]);
      float b = blue(sourceImg.pixels[loc]);
      
      avg = (r+g+b)/3.0;
      
      // reverse the result
      avg = 255 - avg;
    }
    else
    {
      
      avg = distanceFromCenter(getX(), getY());
    }
    return avg;
  }
  
  
  // updates the location of the particle after calculating the velocity
  void updateLocation(int gBestX, int gBestY)
  {
    float r1 = random(0,1);
    float r2 = random(0,1);

    if(gBestX == -1 && gBestY == -1)
    {
      r2 = 0;
    }
    
    if(bestX == -1 && bestY == -1)
    {
      r1 = 0;
    }


    vX = w * vX + c1 * r1 * (bestX-getX()) + c2 * r2 * (gBestX-getX());
    vY = w * vY + c1 * r1 * (bestY-getY()) + c2 * r2 * (gBestY-getY());
    
    
    
    int x = (int)(getX() + vX);
    int y = (int)(getY() + vY);
    
    
    
    if( x >= width){ x = width-1;}
    
    if( x < 0 ){x = 0; }
    
    if( y >= height){ y = height-1;}
    
    if( y < 0 ){y = 0; }
    
    xList.add(x);
    yList.add(y);
    
    updateBestF();
  }
  
  // update the best location if applicable
  void updateBestF()
  {
    if( f() > bestF)
    {
      bestX = getX();
      bestY = getY();
      
      bestF = f();
    }
  }
  
  void display()
  {
      //displayAsEllipse();
      //displayAsLineFromCurrentToLastPoint();
      //displayAsCurveOfAllPastLocations();
      displayAsCurveOfLimitedPastLocations(NUM_CURVE_POINTS);
      
  }
  
  void displayAsEllipse()
  {
    fill(FILL_AMOUNT);
    ellipse(getX(), getY(), ELLIPSESIZE, ELLIPSESIZE); 
  }
  
  void displayAsLineFromCurrentToLastPoint()
  {
    if(xList.size() > 1 && yList.size() > 1)
      {
        line(xList.get(xList.size()-2), yList.get(yList.size()-2),
             xList.get(xList.size()-1), yList.get(yList.size()-1));

      }
  }
  
  // using splice curves:
  // https://www.processing.org/tutorials/curves/
  void displayAsCurveOfAllPastLocations()
  {
    
    displayAsCurveOfLimitedPastLocations(xList.size());
    
  }
  
  void displayAsCurveOfLimitedPastLocations(int numLocations)
  {
    int startIndex = max(xList.size()-numLocations, 0);
    
    noFill();
    if(xList.size() > 1 && yList.size() > 1)
    {
      beginShape();
      curveVertex(xList.get(startIndex), yList.get(startIndex)); // the first control point
      for( int i = startIndex; i < xList.size(); i++)
      {
        curveVertex(xList.get(i), yList.get(i));
      }
      curveVertex(xList.get(xList.size()-1), yList.get(yList.size()-1)); // the last control point
      endShape();
      
    }
    
  }
  


  
}



