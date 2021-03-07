
boolean mouseInRectangle(float x,float y,float w,float h)
{
  return (mouseX>x)&&(mouseY>y)&&(mouseX<(x+w))&&(mouseY<(y+h));
}


//A class to hold a float variable that can be modified and accessed in different scopes using the class.
class FloatHolder
{
  float value;
  FloatHolder(float value)
  {
    this.value=value;
  }
}

//A class for a slider control that allows a variable to be set.
class ValueSlider
{
  float x,y,w,h;
  float minimumValue,maximumValue;
  float sliderFraction;
  String label;
  
  FloatHolder variable;
  
  ValueSlider(float x,float y,float w,float h,float minimumValue,float maximumValue,String label,FloatHolder variable)
  {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.label=label;
    this.minimumValue=minimumValue;
    this.maximumValue=maximumValue;
    this.variable=variable;
  }
  
  void updateSlider()
  {
    if(mouseInRectangle(x,y,w,h))
    {
      if(mousePressed)
      {
        sliderFraction=(mouseX-x)/w;
        variable.value=minimumValue+(sliderFraction*(maximumValue-minimumValue));
      }
    }
  }
  
  
  void drawSlider()
  {
    //Draws the outline rectangle
    stroke(255,255,0);
    noFill();
    rect(x,y,w,h);
    
    //Draws the label and current value text.
    sliderFraction=(variable.value-minimumValue)/(maximumValue-minimumValue);
    String valueText=str(variable.value);
    String fullText=label+": "+valueText;
    fill(255,255,255);  
    text(fullText,x,y-10.0);

    //The slider is drawn.
    noStroke();
    fill(0,255,255);
    rect(x+(sliderFraction*w),y,w/20.0,h);
  }
}


//A class for one of many options to be chosen by cycling through them using buttons.
class OptionChooser
{
  float x,y;
  float bw,bh; //Button widths and heights.
  String[] labels;
  String title;
  FloatHolder variable;
  
  
  OptionChooser(float x,float y,float bw,float bh,String[] labels,String title,FloatHolder variable)
  {
    this.x=x;
    this.y=y;
    this.bw=bw;
    this.bh=bh;
    this.labels=labels;
    this.title=title;
    this.variable=variable;
  }
  
  void updateOptionChooser()
  {
    boolean mouseInLeftButton=mouseInRectangle(x,y,(bw/2.0)-(bw/10.0),bh);
    boolean mouseInRightButton=mouseInRectangle(x+(bw/2.0)+(bw/10.0),y,(bw/2.0)-(bw/10.0),bh);
    
    //The value for variable is incremented, decremented or wrapped around if necessary.
    if(mouseInLeftButton&&mouseHasBeenClicked)
    {
      variable.value=(variable.value==0.0) ? (float)(labels.length)-1.0:variable.value-1.0;
    }
    
    if(mouseInRightButton&&mouseHasBeenClicked)
    {
      variable.value=(variable.value==(float)(labels.length)-1.0) ? 0.0:variable.value+1.0;
    }
  }
  
  void drawOptionChooser()
  {
    //Draws the title.
    fill(255,255,255);
    text(title,x,y-10.0);
    
    //Draws the buttons.
    noStroke();
    fill(255,255,0);
    triangle(x,y+(bh/2.0),x+(bw/2.0)-(bw/10.0),y,x+(bw/2.0)-(bw/10.0),y+bh);
    triangle(x+(bw/2.0)+(bw/10.0),y,x+(bw/2.0)+(bw/10.0),y+bh,x+bw,y+(bh/2.0));
    
    //Draws the current selection text based on the current value of variable.
    text(labels[(int)(variable.value)],x,y+bh+10.0);
    
  }
}
