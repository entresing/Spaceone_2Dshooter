// Press 'ENTER' to start or restart the game depends on the game state.
// ENTER can also pause and continue the game during the game play.
// CONTROLS: W,A,S,D to move. MOUSE to aim and shoots automatically.

// STAGE_ONE: Player will need to eliminate numbers of enemies for them to enter BOSS phrase.
// BOSS_PHRASE: Player defeats the boss will clear the game.

// I applied a switch in the draw for changing state when the player clear the level.

//Global field
int characterWidth=100;

int numEnemies = 5;
int killCount = 15;
int addScore = 5;
int threshold;

int playerHealth = 5;
// enemy health will have a + 3 random varity 
int enemyHealth = 1; // it will random between (1,4)
int bossHealth = 20;  // it will random between (6,9)
int bossAttackFrequency = 480;

int enemyDeathTimer;
int difficulties = 5; // game difficulty
int warningTimer = 240; // 4 seconds

// Screen shake variables
int screenShakeTimer = 0;
float screenShakeAmount = 0;

float enemySpeed = 3; // enemy move speed

// reset variable
int reNumEnemies;
int reKillCount;
float reEnemySpeed;

ArrayList<Enemy> enemies = new ArrayList<Enemy>(); // Enemy arraylist

Player player;
Crosshair cursor;
Score printScore;

// game states
int state;
final int LEVEL_ONE = 0;
final int BOSS = 1;
final int WON = 2;
final int LOST = 3;
final int MAIN = 4;

void setup(){
  size(1280, 900);
  frameRate(60);
  
  state = MAIN ;  
  //noStroke(); 
  //add Player when addPlayer is true
  player = new Player(new PVector(width/2,height/2),playerHealth,characterWidth/2,characterWidth/2,color(0,0,0));
  
  //add cursor
  cursor = new Crosshair();
  
  // giving invincible time to the player at the beginning of the game  
  player.pHitCooldown = 118;
  
  // add enemy
  for (int i=0; i<numEnemies; i++) addEnemy(); 
  
  // add score
  printScore = new Score();
  
  // set font
  PFont wagon = loadFont("SpeedwagonExpanded-48.vlw"); 
  textFont(wagon, 30);
  
  //reset variable (store variable for reset purposes)
  reNumEnemies = numEnemies;
  reKillCount = killCount;
  reEnemySpeed = enemySpeed;
}

void draw(){
  switch(state){
    case LEVEL_ONE:
      gamePlay();
      // add a boss after eliminates all the enemies
      if(enemies.size() == 0)
        warningTimer--;
        warningScreen("WARNING!!!");
          if(warningTimer == 0){
            state = BOSS;
          }  
    break;
      
    case BOSS: // speed up the mons and add
      gamePlay();
      // add boss when enter to boss state
      if(warningTimer == 0){
        addBoss();
        warningTimer = -1;
      }
      // if boss is eliminated, enter to win state
      if(enemies.size() == 0 && enemyDeathTimer == 0)
        state = WON;
    break;
  
    case WON:
      gamePlay();
      textScreen("YOU WIN!","Press ENTER TO RESTART",75,75); 
      achievement(new PVector(width/2,height/2+175),50);
      printScore.drawScore(new PVector(width/2,height/2+125),50);
      if(paused){
        // reset player position
        player.pos = new PVector(width/2,height/2);
        
        state = LEVEL_ONE;
        resetGame();
      }      
    break;
    
    case LOST:
      gamePlay();
      textScreen("GAME OVER","Press ENTER TO RESTART",75,75);    
      
      printScore.drawScore(new PVector(width/2,height/2+125),50);        
      if(paused){        
        // clear enemies list before restarting the game
        enemies.clear();
        // add new player
        player = new Player(new PVector(width/2,height/2),playerHealth,characterWidth/2,characterWidth/2,color(0,0,0)); 
        // reset player position
        player.pos = new PVector(width/2,height/2);        
        
        state = LEVEL_ONE;
        resetGame();
      }
    break;
      
    case MAIN:
      gamePlay();
      if(paused){
        textScreen("SPACE ONE","Press ENTER to Start",75,75);
        state = LEVEL_ONE;
      }
    break;      
  }
}
// game play update.
void gamePlay(){
  background(255);

  // Everything drawn after this gets a temporary camera offset.
  pushMatrix();
  applyScreenShake();

  threshold = numEnemies-1;

  if(threshold > enemies.size() && killCount != 0){
    addEnemy();   
    killCount--;
  } 
  
  if(player.pHitCooldown == 119) 
    player.decreaseHealth(1);

  if(player.pHitCooldown > 0) player.pHitCooldown--;
  else if(player.pHitCooldown == 0) player.pHitCooldown = -1;

  enemyUpdate();  
  playerUpdate();

  popMatrix();
}

// add enemy method. It calls from the enemy class and add a new enemy to the enemies arraylist
void addEnemy(){
  enemies.add(new Enemy(new PVector(random(characterWidth/2, width-characterWidth/2),
  random(characterWidth/2, height-characterWidth/2)),(int)random(enemyHealth,enemyHealth+3),characterWidth,characterWidth,new PVector(random(-enemySpeed, enemySpeed), random(-enemySpeed, enemySpeed))));
}

// add boss method. It calls from the BossEnemy class and add a new boss to the enemies arraylist.
void addBoss(){
  enemies.add(new BossEnemy(new PVector(random(characterWidth/2, width-characterWidth/2),
  random(characterWidth/2, height-characterWidth/2)),(int)random(bossHealth,bossHealth+3),characterWidth,characterWidth,new PVector(random(-enemySpeed+2, enemySpeed-2), random(-enemySpeed, enemySpeed))));
}

void enemyUpdate(){
  for (int i=0; i<enemies.size(); i++) {
    Enemy currEnemies = enemies.get(i);
    for(int j=i+1; j<enemies.size(); j++){
      Enemy otherEnemies = enemies.get(j);
      
      if(currEnemies.hitCharacter(otherEnemies) && currEnemies.enemyIsAlive()){ // isAlive boolean avoids the enemy collisions during the death animation
        currEnemies.bounceCollision(otherEnemies);
      }
    }

  currEnemies.update();
  currEnemies.drawCharacter();
  enemyDeathTimer = currEnemies.eDeathCountDown;
  }
}



void playerUpdate(){
  player.update();
  player.drawCharacter();
  
  // disable the following methonds if the player character die.
  if(player.playerIsAlive() && state == LEVEL_ONE || state == BOSS){
    cursor.crossHair(); // crosshair enable
    player.drawHealthBar();
    
    textAlign(CORNER); // Align score to corner
    
    // print score on the left corner
    printScore.drawScore(new PVector(50,50),30); 
    
    // applied forces via player controller
    if(up) player.accelerate(upAcc);
    if(left) player.accelerate(leftAcc);
    if(right) player.accelerate(rightAcc);
    if(down) player.accelerate(downAcc);
    
    // hold to fire, also restrict the frame so it doesn't spray crazy.
    //if(mousePressed && frameCount%player.fireRate==0 && player.pDeathCountDown == -1){
    //  player.fire();
    //}
    // auto fire, restricted by fireRate so it does not spray too fast.
    if(frameCount % player.fireRate == 0 && player.pDeathCountDown == -1){
      player.fire();
    }
  } 

   // print score after game over 
  if(player.gameOver()){ // gameover screen
    state = LOST;
  }
}

void startScreenShake(int duration, float amount){
  // Keep the strongest shake if multiple hits happen close together.
  screenShakeTimer = max(screenShakeTimer, duration);
  screenShakeAmount = max(screenShakeAmount, amount);
}

void applyScreenShake(){
  if(screenShakeTimer > 0){
    translate(
      random(-screenShakeAmount, screenShakeAmount), 
      random(-screenShakeAmount, screenShakeAmount)
    );

    screenShakeTimer--;

    // Gradually reduce the shake strength so it feels punchy.
    screenShakeAmount *= 0.85;
  } else {
    screenShakeAmount = 0;
  }
}

// display info
void textScreen(String text,String text2,int size, int y_axis){
    noLoop();
    fill(0,0,0,50);
    rectMode(CORNER);
    rect(0,0,width,height);
    
    // drop shadow
    fill(0);
    textAlign(CENTER); // align score to the middle
    textSize(size);
    text(text,width/2+4,(height/2)-y_axis+4);
    
    textSize(size - 25);
    text(text2,width/2+4,(height/2)+4);
    
    // text
    fill(80);
    textAlign(CENTER); // align score to the middle
    textSize(size);
    text(text,width/2,(height/2)-y_axis);
    
    textSize(size - 25);
    text(text2,width/2,(height/2));    
}
// warning screen before boss spawn
void warningScreen(String text){
  float delay = 30;
  if(warningTimer > 0 && warningTimer < 239){
    noStroke();
    fill(255,0,0,100);
    rectMode(CORNER);
    rect(0,0,width,height);
    if(frameCount%(2*delay)<delay){      
      
      textAlign(CENTER); // align score to the middle
      textSize(75);
      
      fill(0,100);
      text(text,width/2+4,(height/2)+4);      
      
      fill(0);
      text(text,width/2,(height/2));
    }
  }
  
}
// reset game method when the player restart the game
void resetGame(){
  // reset values for restart
  printScore.score = 0;
  
  reEnemySpeed = enemySpeed;
  numEnemies = reNumEnemies;
  killCount = reKillCount;  
  printScore.count = killCount + numEnemies;
  
  // reset timer
  warningTimer = 240;
  player.pHitCooldown = 118;
  
  // reset enemies and player's health
  for (int i=0; i<numEnemies; i++) addEnemy(); 
  player.health = playerHealth;
}

void achievement(PVector scorePos,int size){
  // achievement of not getting hit until the end
  if(player.health == playerHealth && state == WON){
    fill(255, 111, 0);
    textSize(size-5);
    text ("ACHIEVEMENT OBTAIN: EASY PEASY", scorePos.x, scorePos.y);    
  }
}
