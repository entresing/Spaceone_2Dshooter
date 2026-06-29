// BOSS projectile inherit from projectile class
class BossProjectile extends Projectile{

  BossProjectile(PVector pos, PVector ang, float vel, color colour, int scorePerHit){
    super(pos,ang,vel,colour,scorePerHit);
    taillength = 2;
  }  
  
  // override the projectile draw method for different appearance.
  void drawMe(PVector tempv,int fade){ // fast projectile
    if(bDeathCountDown == -1){
      pushMatrix();
      translate(tempv.x,tempv.y);
      rotate(rotPos);
      scale(scale*fade/3); // make the bullet tail smaller as it goes.
      noStroke();
      fill(colour);

      pushMatrix();
      star(0,0,pWidth,pWidth+10,6);
      popMatrix();


      popMatrix();
    } else {
      debrisUpdate(bDeathCountDown); 
    }
  } 
  // overrides hit method because player decrease health when phitcooldown timers is set. (avoiding player being constantly hit by projectiles)
  boolean hit(Characters p){
    if(bDeathCountDown < 0 && player.pHitCooldown == -1 && abs(pos.x-p.pos.x) < 
       pWidth/2 + p._width/2 && abs(pos.y-player.pos.y) < pWidth/2 + p._width/2){
      player.pHitCooldown = 120; // player hitCooldown timer set to 120
      bDeathCountDown = 60; 
      printScore.updateScore(scorePerHit);
      startScreenShake(18, 10);
      return true;
    }    
    return false;  
  }
   

  // draw star method 
  void star(float x, float y, float radius1, float radius2, int npoints) {
    float angle = TWO_PI / npoints;
    float halfAngle = angle/2.0;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius2;
      float sy = y + sin(a) * radius2;
      vertex(sx, sy);
      sx = x + cos(a+halfAngle) * radius1;
      sy = y + sin(a+halfAngle) * radius1;
      vertex(sx, sy);
    }
    endShape(CLOSE);
  }      
}
