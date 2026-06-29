// Basic Enemy subclass inherits from the character
// Each bounce between enemy will speed them up (increase difficulty)
class Enemy extends Characters{
  //field
  PVector vel, eShake;
  
  int spawnInvinci = 120; // 2 seconds
  int eShakeTimer = -1;
  int eDeathCountDown = -1; // it will set to 2 seconds when enemy dies
  
  float shakeScale = random(-10,10);
  float shakeDelay = 6;
  
  float eVariation = health*20;
  
  color enemyColor;
  
  //constructor to initialize the field
  Enemy(PVector pos, int health, int _width, int _height, PVector vel){
    super(pos, health, _width, _height, color(130, 130, 130));
    this.vel = vel;
    this.eShake = new PVector(0,0);
    
    enemyColor = color(130, 130, 130);
    
    rotVel = random(-0.03, 0.03);
    
  }
  void update(){
    super.update();
    rotPos += rotVel;
    if(enemyIsAlive()){
      spawnInvinci--;
      eShakeTimer--;
    }
 
    if(eDeathCountDown > 0 && eDeathCountDown != -1)
      eDeathCountDown --;
      debrisAdd(eDeathCountDown); // add debris to arraylist      
    
    if(eDeathCountDown == 0 && !enemyIsAlive())
      enemies.remove(this);
      
    // call spawn invincible method  
    spawnInv();
    // call shaking effect method
    eShake = shakeEffect(new PVector(pos.x,pos.y), eShakeTimer,6,random(-10,10),color(255,0,0,150)); 
    
    // CHECK COLLISION WITH THE PLAYER
    if(hitCharacter(player) && enemyIsAlive()){ // isAlive boolean avoids the enemy collide to the player during the death animation
      bouncePlayer(player);
      if(player.pHitCooldown == -1 && !enemyInvinci()) //to avoid player get hits multiple times within the invicinble countdown.
        player.pHitCooldown = 120; 
    }    
  }

  void moveCharacter() {
    pos.add(vel);
  }
  
  void drawCharacter(){
    if(enemyIsAlive()){ 
      noStroke();
      pushMatrix();
      
      fill(colour);
      
      rectMode(CENTER);
      translate(pos.x, pos.y);
      rotate(rotPos);
      scale(scale*health/hitScale); //when hit it gets smaller
      rect(eShake.x, eShake.y, _width, _height);    
   
      popMatrix();
      
      fill(0);
      textAlign(CENTER);
      textSize(20*health);
      text((int)health,pos.x,pos.y+5*health); // convert to int so it doesn't display decimals
    } else {
      debrisUpdate(eDeathCountDown);
    }
  }

  // Overrides decrease health method because I added the timers for both shaking effect and death animation
  void decreaseHealth(int damage){
    super.decreaseHealth(damage);
    eShakeTimer = 60; // 1 second
    if(health == 0){
      printScore.killCount();// update score
      eDeathCountDown = 120; //2 seconds for death animation count down
    }
  }
  
  // spawn invincible method that allows the enemy to ignore projectile or not to hit player after the spawn.
  void spawnInv(){
    if(spawnInvinci > 0){
      invincible_Anim(enemyColor,enemyColor-color(0,0,0,200));
    } else {
      colour = enemyColor; // reset the colour back to default
    }
  }
  
  // code cited from the lecture 7
  void bounceCollision(Characters other) {
      //find the angle they hit and send them away from each other
      float angle = atan2(pos.y - other.pos.y, pos.x - other.pos.x);
      
      //calculate average velocity. Each bounce between enemy will speed them up
      float avgSpeed = ((vel.mag() + other.vel.mag()+ enemySpeed/10)/2);
      
      
      //off we go in opposite directions (this is a gross approximation, but looks decent)
      vel.x = avgSpeed * cos(angle);
      vel.y = avgSpeed * sin(angle);
      other.vel.x = avgSpeed * cos(angle - PI);
      other.vel.y = avgSpeed * sin(angle - PI);
  }
  
  // code cited from the lecture 7
  void bouncePlayer(Player player){
      float angle = atan2(pos.y - player.pos.y, pos.x - player.pos.x);
  
      vel.x = enemySpeed * cos(angle);
      vel.y = enemySpeed * sin(angle);
  }
  
  boolean enemyIsAlive() {
    return eDeathCountDown==-1;
  }  
  
  boolean enemyInvinci(){
    return spawnInvinci > 0;
  }
}
