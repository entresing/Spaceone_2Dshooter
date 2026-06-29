// projectile class that uses for both the boss and the player
class Projectile{
  //field
  PVector pos, ang; //projectile angle to its target
  
  int debrisAmount = (int)random(7,15);
  int bDeathCountDown = -1;
  int scorePerHit;
  
  float pWidth;
  float rotPos;
  float rotVel;
  float vel;
  float scale;
  
  float xspeed;
  float yspeed;  
  
  //arraylist to store the tail instance for tail effect
  ArrayList tail = new ArrayList();
  int taillength = 6;    
  
  boolean isAlive; //current bullet will be destroyed if false
  color colour;
  
  // arraylist to store the debris for projectile explosion effect when it collides on something.
  ArrayList<Debris> debris = new ArrayList<Debris>();
  
  //constructor to initialize the field
  Projectile(PVector pos, PVector ang, float vel, color colour, int scorePerHit){
    this.pos = pos;
    this.ang = ang;
    this.vel = vel;
    this.colour = colour;
    this.scorePerHit = scorePerHit;
    
    rotVel = vel/120; 
    scale = 0.1; // bullet initial scale
    pWidth = 25; //it creates a long thin bullet  
    isAlive = true;
    
    xspeed = vel*ang.x;
    yspeed = vel*ang.y;    
  }
  
  void checkWalls(){
    if(abs(pos.x - width/2) > width/2 || abs(pos.y - height/2) > height/2)
      // destroy after 10 frame of sec. 
      // I kinda hack this cuz when I set isAlive to false, 
      // my animation for the projectile destruction kinda messed up
      bDeathCountDown = 10; 
  }
  
  void move(){    
    pos.add(xspeed,yspeed); 
  }
  
  void update(){
    move();
    // projectileTail calls the drawMe methods and giving it a fading property
    projectileTail();     
    checkWalls();
    rotPos += rotVel;   

    if(scale < 1.3)
      scale += 0.05; // anime the bullet from small the large

    if(bDeathCountDown > 0 && bDeathCountDown != -1)
      bDeathCountDown --; 
      
    if(bDeathCountDown == 0)
        isAlive = false; 
      
    debrisAdd(bDeathCountDown);      
  }
  
  void drawMe(PVector tempv, int fade){
    if(bDeathCountDown == -1){
      pushMatrix();
      translate(tempv.x,tempv.y);
      rotate(rotPos);
      scale(scale*fade/4);
      noStroke();
      fill(colour,30*fade);
      rect(0,0,pWidth,pWidth);
      
      popMatrix();
    } else {
      debrisUpdate(bDeathCountDown); 
    }
  }
  
  //method for collision detection between current bullet and an enemy 
  boolean hit(Characters ch){
    if(bDeathCountDown < 0 && abs(pos.x-ch.pos.x) < pWidth/2 + ch._width/2 && abs(pos.y-ch.pos.y) < pWidth/2 + ch._width/2){
      ch.decreaseHealth(1);
      printScore.updateScore(scorePerHit);
      bDeathCountDown = 60;
  
      startScreenShake(10, 5);
  
      return true;
    }    
    return false;  
  }
  
  // method to add debris to the arraylist
  void debrisAdd(int deathCountDown){ 
    // add debris to the arraylist
    if(deathCountDown == 59){
      for (int i = 0; i < debrisAmount; i ++) {
        debris.add(new Debris(pos.x,pos.y,random(-2.5,2.5),random(-2.5,2.5),random(0.5,2), 50)); // fill ArrayList with debris
      }
    }  
  }
  // debris animation after object destroyed 
  void debrisUpdate(int deathCountDown){
    // extract debris from the arraylist and play the animations
    if(deathCountDown > 0){
      for(int i = 0; i < debris.size(); i++) {
        Debris d = (Debris) debris.get(i); 
        //makes d a debris equivalent to ith debris in ArrayList
        if(deathCountDown > 0){
          d.colour = colour;          
          d.run();
          d.drawMe();
        } else if (deathCountDown == 0){
          debris.remove(d);
        }    
      }
    }
  }
  
  void projectileTail(){
    tail.add(new PVector(pos.x,pos.y,0));
    if(tail.size() > taillength) {
      tail.remove(0);
    }
    
    for (int i = 0; i < tail.size(); i++) {
      PVector tempv = (PVector)tail.get(i);
      drawMe(tempv,i);
    }       
  }  
}
