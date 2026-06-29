// player character inherits from the character class
// I added a pHitCooldown timer for the player only takes one hit from the enemy
// instead of taking multiple damages at the same time.
// Player character will flash in red and shakes as its invincible visual feedback.

class Player extends Characters{
  //field
  PVector vel, pShake, ang; // ang is the firing angle
  
  int pSpeed; // projectile speed
  
  int pHitCooldown = -1; //invincible timer. (2 seconds when initiates) 
  int pDeathCountDown = -1; // death animation timer
  int pShakeTimer = -1; // shaking effect timer
  int fireRate = 25;
  
  float healthBar = health; // store health value to create a health bar's frame
  float recoil = 0.15;

  // arraylist to store projectiles instances
  ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
  
  //constructor to initialize the field
  Player(PVector pos,  int health, int _width, int _height, color colour){
    super(pos, health, _width, _height, colour);
    this.pShake = new PVector(0,0);
    
    rotVel = random(-0.25, 0.25);
    pSpeed = 15;  
  }
  
  void update(){
    super.update();
    
    rotPos += rotVel;   
    pShakeTimer--;
    
    // find angle from the player position to the mouse position
    ang = new PVector((mouseX-pos.x),(mouseY-pos.y));
    // if the direction is not equal to (0,0), normalize the angle value to length 1. 
    // this is to hold a vector which tells the projectile in which direction to go.
    // so the velocity of the bullet is consistant.
    if(ang.x != 0 && ang.y !=0){
      ang.normalize();
    }
    
    // call checkProjectiles method
    checkProjectiles();
    
    if(pDeathCountDown > 0 && pDeathCountDown != -1){
      // stops the player movement during the death animation
      vel = new PVector(0,0);
      // plays death animation
      pDeathCountDown --; 
    }
      
    if(pHitCooldown > 0 && pHitCooldown < 118 && health != 0){ // set hitCooldown condition less than 58 so it will not flash red when death.
      invincible_Anim(color(255,0,0),color(0,0,0,200));
    } else {
      colour = color(0,0,0); // reset the colour back to default
    }
    
    // debris effect and shaking effect
    debrisAdd(pDeathCountDown);
    pShake = shakeEffect(new PVector(pos.x,pos.y), pShakeTimer,6,random(-5,5),color(255,0,0,200)); // random offset for shaking effect

  }
  
  // fire method that access the ang vector of the mouse.
  void fire(){
    projectiles.add(new Projectile(new PVector(pos.x, pos.y), new PVector(ang.x+random(-recoil,recoil), ang.y+random(-recoil,recoil)),pSpeed,color(3, 177, 252), addScore)); // shoot projectile towards the mouse cursor with velocity of 10  (randomize the start angle to create fire rate when shoot) 
  }
  
  void drawCharacter(){
    if(playerIsAlive()){
      pushMatrix();
      translate(pos.x, pos.y);
      rotate(atan2(mouseY - pos.y, mouseX - pos.x) + PI/2); //Launcher that rotates and points toward the mouse cursor
      
      //gun
      fill(232, 140, 35);
      rect(pShake.x ,pShake.y-15 ,_width/2,_height);
      
      //body
      fill(255);
      ellipse(pShake.x, pShake.y,_width,_height);// to cover the gun's silhouette
      fill(colour);
      ellipse(pShake.x, pShake.y,_width,_height);
      
      popMatrix();
    } else {
      // crash animation
      if(pDeathCountDown > 120){
        pushMatrix();
        translate(pos.x, pos.y);
        rotate(rotPos);
        scale((float) pDeathCountDown/240);
        //gun
        fill(232, 140, 35);
        rect(0 ,-15 ,_width/2,_height);
        
        //body
        fill(colour);
        ellipse(0, 0,_width,_height);
        
        popMatrix();    
      } else if (pDeathCountDown < 119 && pDeathCountDown > 0){ 
        // explode into debris after crash animation
        debrisUpdate(pDeathCountDown);
      }     
    }
  }
  // draw health bar on the top left of the screen
  void drawHealthBar(){
    if(health != 0 && playerIsAlive()){ // healthBar
      pushMatrix();

      translate(50, 95);
      rectMode(CORNER);
      //health 
      noStroke();      
      fill(0,200,0);
      rect(0,0,25*health,15);
      
      //health bar
      strokeWeight(5);      
      stroke(0);      
      fill(0,200,0);
      noFill();
      rect(0,0,25*healthBar,15);
      
      popMatrix();
    }  
  
  }
  // iterate through each projectiles and check if it hit the enemies
  void checkProjectiles(){
    for(int i=0; i<projectiles.size(); i++){ // loop and get each projectile
      Projectile currProjectile = projectiles.get(i);
      currProjectile.update();
      
      //check each enemy for collision with the ith projectile.
      for(int j=0; j<enemies.size(); j++){
        Enemy e = enemies.get(j);
        if(!e.enemyInvinci() && e.enemyIsAlive()) // avoid killing the enemy while it is invincible
          currProjectile.hit(e);       
      }
       
      
      if(!currProjectile.isAlive)
        projectiles.remove(i);
    }       
  }
  
  // I override the decrease Health method because I added the timers for the shake effect and death animations
  void decreaseHealth(int damage) {
    super.decreaseHealth(damage);
    pShakeTimer = 120;
  
    startScreenShake(18, 10);
  
    if(health == 0)
      pDeathCountDown = 240;
  }
  
  boolean playerIsAlive() {
    return pDeathCountDown == -1;
  }
    
  boolean gameOver(){
    return pDeathCountDown == 0;
  }
}
