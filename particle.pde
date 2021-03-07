
//A class for a SPH particle.
class Particle
{
  FloatHolder mass,h,c,restDensity,viscosity;
  float density,pressure;

  float x,y; //Position.

  float vx,vy; //Velocity.
  float ax,ay; //Total acceleration.
  float pax,pay; //Previous acceleration.

  float gpX,gpY; //Pressure gradient.
  float lvX,lvY; //Laplacian of velocity.
  float raX,raY; //Wall repulsion acceleration.
  float maX,maY; //Mouse tool acceleration.
  
  float dt;
  ArrayList<Particle> neighbours;
  boolean checked;
  
  Particle(FloatHolder mass,FloatHolder h,FloatHolder c,FloatHolder restDensity,FloatHolder viscosity,float x,float y)
  {
    this.h=h;
    this.mass=mass;
    this.c=c;
    this.restDensity=restDensity;
    this.viscosity=viscosity;
    this.x=x;
    this.y=y;
    
    vx=0.0;
    vy=0.0;
    ax=0.0;
    ay=0.0;
    pax=0.0;
    pay=0.0;
    
    gpX=0.0;
    gpY=0.0;
    lvX=0.0;
    lvY=0.0;
    raX=0.0;
    raY=0.0;
    maX=0.0;
    maY=0.0;
    
    dt=1.0/60.0;
    neighbours=new ArrayList<Particle>();
    checked=false;
  }
  
  
  
  //A gaussian kernal function done from this particle to another particle. From page 3 in https://arxiv.org/abs/1012.1885
  float W(Particle otherParticle)
  {
    float expodent=((-1.0)/(h.value*h.value))*(sq(x-otherParticle.x)+sq(y-otherParticle.y));
    return (1.0/(PI*h.value*h.value))*exp(expodent);
  }      
  
  //The derivative of W along the x axis.
  float dWdX(Particle otherParticle)
  {
    float dEdX=((-1.0)/(h.value*h.value))*(2.0*(x-otherParticle.x));
    return dEdX*W(otherParticle);
  }
  
  //The derivative of W along the y axis.
  float dWdY(Particle otherParticle)
  {
    float dEdY=((-1.0)/(h.value*h.value))*(2.0*(y-otherParticle.y));
    return dEdY*W(otherParticle);
  } 
  
  //The 2nd derivative of W along the x axis.
  float d2WdX2(Particle otherParticle)
  {
    float dEdX=((-1.0)/(h.value*h.value))*(2.0*(x-otherParticle.x));
    float d2EdX2=-2.0/(h.value*h.value);
    return (sq(dEdX)+d2EdX2)*W(otherParticle);
  }
  
  //The 2nd derivative of W along the y axis.
  float d2WdY2(Particle otherParticle)
  {
    float dEdY=((-1.0)/(h.value*h.value))*(2.0*(y-otherParticle.y));
    float d2EdY2=-2.0/(h.value*h.value);
    return (sq(dEdY)+d2EdY2)*W(otherParticle);
  }
  
  float laplacianW(Particle otherParticle)
  {
    return max(d2WdX2(otherParticle)+d2WdY2(otherParticle),0.0); //The lapalacian is prevented from going below zero so particles always try to match their neighbours' speed. 
  }
  
  
  //Determines if the particle is within a rectangle.
  boolean withinRectangle(float x,float y,float w,float h)
  {
    boolean withinX=(this.x>=x)&&(this.x<=(x+w));
    boolean withinY=(this.y>=y)&&(this.y<=(y+h));
    return withinX&&withinY;
  }
  
  
  
  void updateDensity()
  {
    density=0.0;
    
    for(Particle i:neighbours)
    {
      density+=i.mass.value*W(i);    
    }      
  }
  
  void updatePressure()
  {
    //The Cole equation of state (adiabatic equation of state for liquids, from http://www.sklogwiki.org/SklogWiki/index.php/Cole_equation_of_state).
    pressure=((restDensity.value*c.value*c.value)/7.0)*(pow(density/restDensity.value,7.0)-1.0);
  }
  
  void updatePressureGradient() //Pressure gradient from pages 8 and 9 of https://arxiv.org/abs/1007.1245
  {
    //The pressure gradients are reset.
    gpX=0.0;
    gpY=0.0;
    
    for(Particle i:neighbours)
    {
      if(i.density==0.0)
      {
        continue; //This particle contributes nothing to the pressure.
      }
        
      float constantFactor=density*i.mass.value*((pressure/sq(density))+(i.pressure/sq(i.density)));  //The forces are symmetric for both particles.   
 
      gpX+=constantFactor*dWdX(i);
      gpY+=constantFactor*dWdY(i);
    }
  }
  
  void updateVelocityLaplacian()
  {
    //The velocity laplacian is reset.
    lvX=0.0;
    lvY=0.0;
    
    for(Particle i:neighbours)
    {        
      if(i.density==0.0)
      {
        continue; //The current particle contributes nothing to the viscosity.
      }
          
      float constantFactorX=(1.0/density)*i.mass.value*(i.vx-vx); //The forces are symmetric for both particles.
      float constantFactorY=(1.0/density)*i.mass.value*(i.vy-vy);
      
      float laplacian=laplacianW(i);
      lvX+=constantFactorX*laplacian;
      lvY+=constantFactorY*laplacian;      
    }
  }
  
  
  void updateWallRepulsion(ArrayList<Wall> walls)
  {
    raX=0.0;
    raY=0.0;
    for(Wall i:walls)
    {
      float repulsionAcceleration=i.getRepulsionAcceleration(x,y,vx,vy);
      raX+=(repulsionAcceleration*i.nx);
      raY+=(repulsionAcceleration*i.ny);
    }
  }
  
  //Adds accelerations due to tool use.
  void updateMouseAcceleration()
  {
    maX=0.0;
    maY=0.0;
    
    if(mouseInRectangle(x-25.0,y-25.0,50.0,50.0)&&mousePressed&&(mouseButton==LEFT))
    {
      //Gets a unit vector from the particle to the mouse position.
      float distanceToCentre=dist(x,y,mouseX,mouseY);
      float toCentreX=(mouseX-x)/distanceToCentre;
      float toCentreY=(mouseY-y)/distanceToCentre;
      
      int toolTypeInt=floor(toolType.value);      
      switch(toolTypeInt)
      {
        case 0: //Up.
          maY=(-400.0)*tS.value;
          break;
        case 1: //Down.
          maY=400.0*tS.value;
          break;
        case 2: //Left.
          maX=(-400.0)*tS.value;
          break;
        case 3: //Right.
          maX=400.0*tS.value;
          break;
        case 4: //Inwards.
          maX=400.0*toCentreX*tS.value;
          maY=400.0*toCentreY*tS.value;
          break;
        case 5: //Outwards.
          maX=(-400.0)*toCentreX*tS.value;
          maY=(-400.0)*toCentreY*tS.value;
          break;
      }
    }
    
  }
  
  
  void updateAcceleration(ArrayList<Wall> walls)
  {
    updatePressureGradient();
    updateVelocityLaplacian();
    updateWallRepulsion(walls);
    updateMouseAcceleration();
    
    ax=(((-1.0)/density)*gpX)+(viscosity.value*lvX)+raX+maX;
    ay=(((-1.0)/density)*gpY)+(viscosity.value*lvY)+raY+maY+g.value;   
  }
  
  //The two functions below perform velocity verlet integration.
  void integratePosition()
  {
    x+=((vx*dt)+(0.5*ax*dt*dt));
    y+=((vy*dt)+(0.5*ay*dt*dt));
    pax=ax;
    pay=ay;
  }
  
  void integrateVelocity(ArrayList<Wall> walls)
  {    
    updateAcceleration(walls);   
    vx+=0.5*dt*(pax+ax);
    vy+=0.5*dt*(pay+ay);   
  }
  
  
  void drawParticle()
  {
    noStroke();
    fill(255,0,0);
    circle(x,y,10);
    
  }
}
