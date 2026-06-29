// debris class for enemy explosion effect
class Debris {
  PVector pos,speed; 
  
  int opacityTimer;
  //ArrayList tail;
  float splash = 5;
  float rotPos;
  float rotVel;
  float radius = 10;
  float scale;
  float xspeed;
  float yspeed;
  float debrisDamp;
  float rScale = random(0.01,0.05);  
  
  color colour = (int)random(color(0, 0, 0),color(255,255,255)); //(gonna apply the confetti to the boss later)

  Debris(float tempx, float tempy, float xspeed, float yspeed, float scale, int opacityTimer) {
    // randomizes the start position and velocity of the debris.
    float startx = tempx + random(-splash,splash);
    float starty = tempy + random(-splash,splash);

    this.scale = scale;
    this.opacityTimer = opacityTimer;
    
    pos = new PVector(startx,starty);
    speed = new PVector(xspeed,yspeed);
    rotVel = random(-0.1, 0.1);
    debrisDamp = 0.98;

  }
  
  // update method
  void run() {
    rotPos += rotVel; // rotates the debris.
    opacityTimer--; // decreases the opacity so it looks natural when disappearing.
    pos.add(speed);
    speed.mult(debrisDamp);
    //scale -= 0.01;
  }
  
  // animate the debris to small after explodsion.
  void rScale(){ // shrink debris 
    scale -= 0.01;
  }


  void drawMe() {
    pushMatrix();
    translate(pos.x,pos.y);
    rectMode(CENTER);
    noStroke();
    rotate(rotPos); 
    scale(scale);
    fill(colour,opacityTimer);
    rect(0,0,radius,radius);
    popMatrix();
  }
}
