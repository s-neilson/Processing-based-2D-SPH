
//Determines two rectangles have overlapping areas.
boolean rectanglesIntersect(float x1,float y1,float w1,float h1,float x2,float y2,float w2,float h2)
{
  //If an edge of the first rectngle is within the oppisite edge of the second rectangle, it intersects with the second rectangle
  //if the other three edges of the rectangle are in a position that does not cause the rist rectangle to be outside the second rectangle
  //(the other edges are also within the opposite edges of the second rectangle).
  return (x1<(x2+w2))&&((x1+w1)>x2)&&(y1<(y2+h2))&&((y1+h1)>y2);
}



//A class for a quadtree node.
class QuadtreeNode
{
  boolean isLeafNode;
  boolean isSplit;  
  float x,y,w,h;
    
  QuadtreeNode[] childNodes;
  Particle particle;
  
  
  QuadtreeNode(float x,float y,float w,float h)
  {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    
    isLeafNode=false;
    isSplit=false;
    childNodes=null;
  }
  
  //Recursively clears the tree.
  void clearTree()
  {
    if(isSplit)
    {
      for(QuadtreeNode i:childNodes)
      {
        i.clearTree();
      }
      
      childNodes=null;
    }
    
    isLeafNode=false;
    isSplit=false;
    particle=null;
  }
  
  void splitNode()
  {
    //New widths and heights for the child nodes.
    float nw=w/2.0;
    float nh=h/2.0;
    
    //The centrepoint of the current node.
    float cx=x+nw;
    float cy=y+nh;
    
    //The child nodes are created.
    childNodes=new QuadtreeNode[4];
    childNodes[0]=new QuadtreeNode(x,y,nw,nh);
    childNodes[1]=new QuadtreeNode(cx,y,nw,nh);
    childNodes[2]=new QuadtreeNode(x,cy,nw,nh);
    childNodes[3]=new QuadtreeNode(cx,cy,nw,nh);
    
    isSplit=true;
  }
  
  
  void addParticleToChildren(Particle particle)
  {
    for(QuadtreeNode i:childNodes)
    {
      boolean particleAdded=i.addParticle(particle);      
      if(particleAdded)
      {
        break; //If the particle has been successfully added the other children do not need to be checked.
      }
    }
  }
  
  //Returns true if the particle has been added to the node or any of its descendants.
  boolean addParticle(Particle particle)
  {   
    if(!particle.withinRectangle(x,y,w,h))
    {
      return false; //The particle cannot go inside this node or any of its descendants.
    }
    
    if((!isLeafNode)&&(!isSplit)) //If the node can accept a particle.
    {
      this.particle=particle;
      isLeafNode=true;
      return true;
    }
    
    if(isLeafNode)
    {
      isLeafNode=false;
      splitNode();
      
      //The current particle in this node is moved to one of its children.
      addParticleToChildren(this.particle);
      this.particle=null;
      
      addParticleToChildren(particle); //The original particle to be added is added to one of the node's children.
      return true;     
    }
    
    addParticleToChildren(particle); //Occurs if the node is not a leaf node and is already split.
    return true;
  }
 

  //Finds the neighbouring particles around a square centred at a particular point.
  void getParticleNeighbours(Particle particle)
  {
    float sw=particle.h.value*4.0;
    float sx=particle.x-(sw/2.0);
    float sy=particle.y-(sw/2.0);
    
    if(!rectanglesIntersect(x,y,w,h,sx,sy,sw,sw))
    {
      return; //There are no neighbours inside this node or in any of its descendants.
    }    
    
    if(isLeafNode) //If the node has a particle.
    { 
      
      if(this.particle.withinRectangle(sx,sy,sw,sw))
      {       
        particle.neighbours.add(this.particle); //The current node's particle is added to the neighbour list. 
        return;
      }
    }
    
    //If the node has child nodes the child nodes are searches recursively.
    if(isSplit)
    {
      for(QuadtreeNode i:childNodes)
      {
        i.getParticleNeighbours(particle);
      }
    }
  }
}
