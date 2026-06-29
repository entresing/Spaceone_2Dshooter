// boss enemy class inherits from the enemy class.
// the boss holds two attack modes. One is to shot a fast greenish cannon ball
// and the other attack mode shots many slow stars projectiles that spreads all over screen.

class BossEnemy extends Enemy{
  //field
  // an arraylist that stores projectiles instances 
  ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
  PVector ang, dir; // firing angle
  
  int pSpeed; // projectile speed
  int attackModeTimer; // timer for it to switch attack mode
  int bounceTimer;

  float recoil;
  
  BossEnemy(PVector pos, int health, int _width, int _height, PVector vel){
    super(pos, health, _width, _height,vel);
    scale = 1;
    pSpeed = 10;
    recoil = 1;
    bounceTimer = -1;
    
    enemyColor = color(193, 240, 26);
  }
  
  // calling update method from the super class 
  // check the collision conditions if it collides the player.
  // call checkProjectiles and add projectiles.
  void update(){
    super.update();
    
    if(hitCharacter(player) && enemyIsAlive()){ // isAlive boolean avoids the enemy collide to the player during the death animation
      bounceTimer = 120;
      if(player.pHitCooldown == -1 && !enemyInvinci()) //to avoid player get hits multiple times within the invicinble countdown.
        player.pHitCooldown = 120; 
    } 
    
    if(bounceTimer > 0 && player.playerIsAlive()){
      float angle = atan2(pos.y - player.pos.y, pos.x - player.pos.x);      
      dir.x = enemySpeed * cos(angle);
      dir.y = enemySpeed * sin(angle);
      bounceTimer--;
    }        
    if(bounceTimer == 0) bounceTimer = -1;

    // calculate the player position angle and normalize it
    ang = new PVector((player.pos.x-pos.x),(player.pos.y-pos.y));
    ang.normalize();
    
    // check condition if the boss still alive and he exit the invincible time, fire projectiles towards the player
    if(enemyIsAlive() && spawnInvinci < 0){ 
      fireMode();
    }
    // check collision between projectiles and the player
    checkProjectile();
  }
  
  // override Boss move method so it follows the player.
  void moveCharacter() {
    if(bounceTimer == -1){
      dir = new PVector((player.pos.x-pos.x),(player.pos.y-pos.y));
      dir.normalize();
      dir.mult(enemySpeed);    
    }
    pos.add(dir);
  }
  
  // override the drawCharacter method from the Enemy class
  void drawCharacter(){

    if(enemyIsAlive()){ 
      noStroke();
      pushMatrix();
      
      fill(colour);
      
      rectMode(CENTER);
      translate(pos.x, pos.y);
      rotate(rotPos);
      scale(scale);
      rect(eShake.x, eShake.y, _width, _height);
      
      pushMatrix();
      rotate(PI/4);
      fill(colour-color(0, 140, 0)+color(0,0,100));      
      rect(eShake.x, eShake.y, _width, _height); 
      popMatrix();
      
      popMatrix();
      
      fill(0);
      textAlign(CENTER);
      textSize(90);
      text((int)health,pos.x,pos.y+25); // convert to int so it doesn't display decimals
    } else {
      debrisUpdate(eDeathCountDown);
    }      

  }
  
  // fire slow stars projectiles
  void fireSlow(int _pSpeed,float _fireRate){ 
    // slow, spreading attack that launches stars projectile. (decrease player score when hit)
    projectiles.add(new BossProjectile (new PVector(pos.x, pos.y), new PVector(ang.x+random(-_fireRate,_fireRate), ang.y+random(-_fireRate,_fireRate)),_pSpeed,color(255, 0, 93, 200),-addScore)); 
  }  
  
  // fire fast cannon projectiles
  void fireFast(int _pSpeed){
    // fast cannon attack that deals double damage. (decrease player score when hit)
    projectiles.add(new Projectile (new PVector(pos.x, pos.y), new PVector(ang.x, ang.y),_pSpeed,color(193, 240, 26),-addScore));
  }
  
  // iterates through each projectile and check if it hits the player
  void checkProjectile(){
    for(int i=0; i<projectiles.size(); i++){ 
      Projectile currProjectile = projectiles.get(i);
      currProjectile.update();
      if(enemyIsAlive()) // to avoid the player from hitting the projectile even the boss is killed
        currProjectile.hit(player);       
    }     
  }
  // assign two attack modes for the boss. first half within the timer will shoot high speed cannon, 
  // and the last half shoots spreading projectile with slow speed.
  void fireMode(){
    bossAttackFrequency--;
    if(bossAttackFrequency > 240){
      if(frameCount%60==0)
        fireFast(pSpeed);
    } 

    if(bossAttackFrequency > 0 && bossAttackFrequency < 239){
      if(frameCount%15==0)
        fireSlow(pSpeed-9,recoil+1);      
    }
    if(bossAttackFrequency == 0)
      bossAttackFrequency = 480;
  }
  
  // Overrides from the enemy because I have to increase the death animation to 3 seconds
  void decreaseHealth(int damage){
    super.decreaseHealth(damage);
    eShakeTimer = 60; // 1 second
    if(health == 0){
      printScore.killCount();// update score
      eDeathCountDown = 180; //3 seconds for death animation count down
    }
  }  
  
  // overrides its random debris sizes.
  void debrisAdd(int deathCountDown){ 
    // add debris to the arraylist
    if(deathCountDown == 179){
      for (int i = 0; i < debrisAmount; i ++) {
        debris.add(new Debris(pos.x,pos.y,random(-3,3),random(-3,3),random(1,4),110)); // fill ArrayList with debris
      }
    }  
  }  
  
  // overrides the debris colour
  void debrisUpdate(int deathCountDown){
    // extract debris from the arraylist and play the animations
    if(deathCountDown > 0){
      for(int i = 0; i < debris.size(); i++) {
        Debris d = (Debris) debris.get(i); 
        //makes d a debris equivalent to ith debris in ArrayList
        if(deathCountDown > 0){
          //d.colour = colour; over ride this so boss spawn confetti during death animation
          d.run();
          d.drawMe();
          d.rScale();
        } else if (deathCountDown == 0){
          debris.remove(d);
        }    
      }
    }
  }
  
  // override hitCharacters method since the boss does not affect by the scaling.
  boolean hitCharacter(Characters other){
    //boolean check = false;
    if(abs(pos.x-other.pos.x) < _width/2 + other._width/2 && abs(pos.y-other.pos.y) < _height/2 + other._height/2){
      return true;
    }
    return false;
  }  
}
