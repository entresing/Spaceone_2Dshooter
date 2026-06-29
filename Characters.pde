// I added a invincible effect method and a shaking effect method because they apply to every character in this game
// I also create an arraylist for debris for it to spawn and update whenever a character dies.
class Characters {

  //field
  PVector pos, vel;
  float health, _width, _height, shakeTimer, rotPos, rotVel;
  
  float damp = 0.95;
  float scale = random(1,1.3); 
  float hitScale = enemyHealth + 2.5;  
  
  color colour;
  
  int debrisAmount = (int)random(15,25);
  
  ArrayList<Debris> debris = new ArrayList<Debris>();// create an arraylist of debris for death animation
  
  //constructor to initialize the field
  Characters(PVector pos, int health, int _width, int _height, color colour){
    this.pos = pos;
    this.vel = new PVector();    
    this.colour = colour;
    this.health = health;
    this._width = _width;
    this._height = _height;
  }
  
  // update
  void update(){

    moveCharacter();
    checkWalls();

  }
  // a moveCharacter method that moves the Character, using its velocity and position fields
  void moveCharacter(){ 
    pos.add(vel);
    vel.mult(damp);   
  }
  
  void accelerate(PVector force){
    vel.add(force);
  }
  // a hitCharacter method that detects when two Characters have collided:
  boolean hitCharacter(Characters other){
    return abs(pos.x-other.pos.x) < ((_width/2)*(scale*health/hitScale)) + ((other._width/2)*(scale*health/hitScale)) && abs(pos.y-other.pos.y) < ((_height/2)*(scale*health/hitScale)) + ((other._height/2)*(scale*health/hitScale));
  }
  // a decreaseHealth method that decreases the health of the Character
  void decreaseHealth(int damage) {
      health -= damage;    
  }
  
  // draw a dummy character
  void drawCharacter(){
    pushMatrix();
    translate(pos.x, pos.y);
    
    fill(colour);
    ellipse(0, 0,_width,_height);

    popMatrix();
  }
  
  // a checkwalls method that teleport the character to the other side.
  void checkWalls() {
    if (pos.x<-_width/2) 
      pos.x = width+_width/2; 
    if (pos.x>width+_width/2) 
      pos.x = -_width/2;
    if (pos.y<-_height/2) 
      pos.y = height+_height/2;
    if (pos.y>height+_height/2) 
      pos.y = -_height/2;
  }
  
  // character invincible flashing effect
  void invincible_Anim(color aColour, color bColour){
    float delay = 8;
    colour = aColour; //235,165,160
    if(frameCount%(2*delay)<delay){ //https://stackoverflow.com/questions/22746938/time-gap-between-the-two-colors-flashing-in-processing
      colour = bColour;
    }
  }  
  
  // add debris to the arraylist after character is destroyed
  void debrisAdd(int deathCountDown){ 
    // add debris to the arraylist
    if(deathCountDown == 119){
      for (int i = 0; i < debrisAmount; i ++) {
        debris.add(new Debris(pos.x,pos.y,random(-3,3),random(-3,3),random(1,2),170)); // fill ArrayList with debris
      }
    }  
  }
  
  // debris exploding animation method
  void debrisUpdate(int deathCountDown){
    // extract debris from the arraylist and play the animations
    if(deathCountDown >= 0){
      for(int i = 0; i < debris.size(); i++) {
        Debris d = (Debris) debris.get(i); 
        //makes d a debris equivalent to ith debris in ArrayList
        if(deathCountDown >= 0){
          d.colour = colour;
          d.run();
          d.drawMe();
          d.rScale();
        } else if (deathCountDown == 0){
          debris.remove(d);
        }    
      }
    }
  }
  
  // shaking effect, returns pvector values for the shake position
  PVector shakeEffect(PVector shakePos, int shakeTimer, float shakeDelay, float shakeScale, color nColour){
    if(frameCount%(2*shakeDelay)<shakeDelay && shakeTimer>0){ // shaking effect upon hit
        shakePos.x = shakeScale;
        shakePos.y = shakeScale;
        colour = nColour;
    } else {
      shakePos.x = 0;
      shakePos.y = 0;      
    }  
    return shakePos;
  }
  
}
