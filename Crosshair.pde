// crosshair that follows the mouse position for aiming purpose
class Crosshair{
  
  //field
  color c = color(0,255,0,150);
  int size = 35;

  void crossHair(){    
    pushMatrix();
    translate(mouseX,mouseY);
    
    popMatrix();
    
    pushMatrix();
    noStroke();
    translate(mouseX,mouseY);
    rotate( (float) mouseX / width * PI * 5 );
    rectMode(CENTER);
    
    fill(c);
        
    rect(0, 0, size, size);
    popMatrix();
  
  }

}
