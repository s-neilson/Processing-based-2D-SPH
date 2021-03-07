
//A class for a wall that repels particles with an expodential force.
class Wall
{
  float nx,ny; //The normal of the wall.
  float x1,y1; //First endpoint of wall.
  float x2,y2; //Second endpoint of wall.
  float wallLength;
  float lvX,lvY; //The unit vector pointing from the first endpoint to the second endpoint.
  
  float repulsionStrength; //Controls the strength of repulsion at the source.
  float repulsionDistance; //Controls how the repulsion changes with the distance from the wall.
  float bounceFactor; //The strength of repulsion when the particle is moving away from the normal in order to reduce energy.
  boolean doubleSided; //Whether the wall repels from both sides.
  
  Wall(float nx,float ny,float x1,float y1,float wallLength,float repulsionStrength,float repulsionDistance,float bounceFactor,boolean doubleSided)
  {
    //The input normal vector is normalized if needed.
    float inputNormalVectorLength=dist(0.0,0.0,nx,ny);
    this.nx=nx/inputNormalVectorLength;
    this.ny=ny/inputNormalVectorLength;
    
    this.x1=x1;
    this.y1=y1;
    this.wallLength=wallLength;
    
    //Creates a vector along the direction of the wall.
    lvX=((this.ny==0.0) ? 0.0:1.0);
    lvY=((this.ny==0.0) ? 1.0:(((-1.0)*this.nx)/this.ny));
    float lvLength=dist(0.0,0.0,lvX,lvY);
    lvX/=lvLength;
    lvY/=lvLength;
    
    //The second point in the wall is created from extending from the user selected point.
    x2=this.x1+(lvX*this.wallLength);
    y2=this.y1+(lvY*this.wallLength);
    
    this.repulsionStrength=repulsionStrength;
    this.repulsionDistance=repulsionDistance;
    this.bounceFactor=bounceFactor;
    this.doubleSided=doubleSided;
  }
  
  //Determines the perpendicular distance of the particle to the wall and if the particle is outside the wall endpoints a distance of 9999.0 is returned.
  float getDistanceFromWall(float x,float y)
  {
    float perpendicularDistance=(nx*(x-x1))+(ny*(y-y1));
    float lineDistanceToParticle=(lvX*(x-x1))+(lvY*(y-y1)); //The projection of the particle location on the line.
    boolean particleOutsideLine=(lineDistanceToParticle>wallLength)||(lineDistanceToParticle<0);
    
    return particleOutsideLine ? 9999.0:perpendicularDistance;
  }
  
  float getRepulsionAcceleration(float x,float y,float vx, float vy)
  {
    float distanceFromWall=getDistanceFromWall(x,y);
    float repulsionDirection=doubleSided ? ((distanceFromWall>0.0) ? 1.0:-1.0):1.0; //Is negative if the wall is double sided and the distance to the wall is negative.
    distanceFromWall=doubleSided ? abs(distanceFromWall):distanceFromWall;
    boolean bouncingUpward=repulsionDirection*((nx*vx)+(ny*vy))>0.0;
    
    return repulsionDirection*(bouncingUpward ? bounceFactor:1.0)*repulsionStrength*exp(((-1.0)*distanceFromWall)/repulsionDistance);  
  }
  
  void drawWall()
  {
    stroke(0,0,255);
    noFill();
    line(x1,y1,x2,y2);
  }
}
