ArrayList<Particle> particles=new ArrayList<Particle>();
ArrayList<Wall> walls=new ArrayList<Wall>();
QuadtreeNode quadtree;


FloatHolder tS=new FloatHolder(1.0); //Tool strength
FloatHolder g=new FloatHolder(50.0); //Gravitational acceleration.
FloatHolder pM=new FloatHolder(2.5); //Particle mass.
FloatHolder pH=new FloatHolder(15.0); //Smoothing length
FloatHolder pC=new FloatHolder(100.0); //Speed of sound
FloatHolder pRd=new FloatHolder(0.01); //Default density
FloatHolder pV=new FloatHolder(1000.0); //Viscosity.

ValueSlider tsControl=new ValueSlider(1500.0,180.0,200.0,30.0,0.5,3.0,"Tool strength",tS);
ValueSlider gravityControl=new ValueSlider(1500.0,350.0,200.0,30.0,0.0,200.0,"Gravity",g);
ValueSlider mControl=new ValueSlider(1500.0,420.0,200.0,30.0,0.0,10.0,"Mass",pM);
ValueSlider hControl=new ValueSlider(1500.0,490.0,200.0,30.0,5.0,30.0,"Smoothing length",pH);
ValueSlider cControl=new ValueSlider(1500.0,560.0,200.0,30.0,10.0,400.0,"Speed of sound",pC);
ValueSlider rdControl=new ValueSlider(1500.0,630.0,200.0,30.0,0.0025,0.04,"Rest density",pRd);
ValueSlider vControl=new ValueSlider(1500.0,700.0,200.0,30.0,100.0,2000.0,"Viscosity",pV);



FloatHolder toolType=new FloatHolder(0.0);
String[] toolTypes=new String[]{"Up","Down","Left","Right","Inwards","Outwards","Add","Remove"};
OptionChooser toolChooser=new OptionChooser(1500.0,100.0,70.0,30.0,toolTypes,"Selected tool",toolType);

boolean mouseHasBeenClicked=false;
void mouseClicked()
{
  mouseHasBeenClicked=true;
}


//Adds particles inside a 50x50 pixel region at the clicked mouse location if the particle adding tool is selected.
void addParticlesWithClick()
{
  float regionSize=50.0*tS.value;
  
  if((toolType.value==6.0)&&mouseHasBeenClicked&&mouseInRectangle(regionSize,regionSize,1400.0,700.0))
  {
    int newParticleCount=floor((pRd.value*regionSize*regionSize)/pM.value); //The number of particles needed for the the average density for the new particles in a 
    //regionSize X regionSize pixel region to be equal to the default density.
    
    for(int i=0;i<newParticleCount;i++)
    {
      //A random locaiton is chosen for the new particle inside the regionSize x regionSize pixel zone.
      Particle newParticle=new Particle(pM,pH,pC,pRd,pV,random(mouseX-(regionSize/2.0),mouseX+(regionSize/2.0)),random(mouseY-(regionSize/2.0),mouseY+(regionSize/2.0)));
      particles.add(newParticle);
    }
  }
}

//Removes particles inside a 50x50 pixel region of the clicked mouse location if the particle removing tool is selected.
void removeParticlesWithClick()
{
  float regionSize=50.0*tS.value;
  
  if((toolType.value==7.0)&&mouseHasBeenClicked)
  {
    ArrayList<Particle> particlesToRemove=new ArrayList<Particle>(); //A list of particles to remove.
    
    for(Particle i:particles)
    {
      if(i.withinRectangle(mouseX-(regionSize/2.0),mouseY-(regionSize/2.0),regionSize,regionSize))
      {
        particlesToRemove.add(i); //The current particle is added to the removal list because it is in the removal zone.
      }
    }
    
    particles.removeAll(particlesToRemove); //The particles that are in the removal list are removed from the main particle list.
  }
}

void setup()
{
  //frameRate(200);
  size(1800,800,P2D);
  quadtree=new QuadtreeNode(-100.0,-100.0,width+200.0,height+200.0);
    
  Wall leftWall=new Wall(1.0,0.0,50.0,50.0,700.0,10000.0,5.0,0.8,false);
  Wall rightWall=new Wall(-1.0,0.0,1450.0,50.0,700.0,10000.0,5.0,0.8,false);
  Wall bottomWall=new Wall(0.0,-1.0,50.0,750.0,1400.0,10000.0,5.0,0.8,false);
  Wall topWall=new Wall(0.0,1.0,50.0,50.0,1400.0,10000.0,5.0,0.8,false);
  
  walls.add(leftWall);
  walls.add(rightWall);
  walls.add(bottomWall);
  walls.add(topWall);
}

void draw()
{
  addParticlesWithClick();
  removeParticlesWithClick();
  background(0);
  
  //The quadtree is remade.
  quadtree.clearTree();
  for(Particle i:particles)
  {
    quadtree.addParticle(i);
  }

  for(Particle i:particles)
  {
    i.neighbours.clear();
    quadtree.getParticleNeighbours(i);   

    i.updateDensity();
    i.updatePressure();
    i.integratePosition();      
  }

  //This needs to be done after the density,pressure and new positions are calculated for all particles.
  for(Particle i:particles)
  {
    i.integrateVelocity(walls);   
    i.drawParticle();
  }
  
  for(Wall i:walls)
  {
    i.drawWall();
  }
  
  
  toolChooser.updateOptionChooser();
  toolChooser.drawOptionChooser();
  tsControl.updateSlider();
  tsControl.drawSlider();
  
  gravityControl.updateSlider();
  gravityControl.drawSlider();  
  mControl.updateSlider();
  mControl.drawSlider();
  hControl.updateSlider();
  hControl.drawSlider();
  cControl.updateSlider();
  cControl.drawSlider();
  rdControl.updateSlider();
  rdControl.drawSlider();
  vControl.updateSlider();
  vControl.drawSlider();
  

  mouseHasBeenClicked=false;
}
