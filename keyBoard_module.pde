// CONTROL MODULES
boolean up, down, left, right;

PVector upAcc = new PVector(0,-1.3);
PVector downAcc = new PVector(0,1.3);
PVector leftAcc = new PVector(-1.3,0);
PVector rightAcc = new PVector(1.3,0);

boolean paused = true;

void keyPressed(){
  if(player.playerIsAlive()){
    if(key == 'a' || key == 'A') left = true;   
    if(key == 'w' || key == 'W') up = true;    
    if(key == 's' || key == 'S') down = true;
    if(key == 'd' || key == 'D') right = true;
  }

  if (key == ENTER || key == RETURN) {
    // One Enter starts the game from the title screen.
    if(state == MAIN){
      state = LEVEL_ONE;
      loop();
      return;
    }

    // One Enter restarts after winning or losing.
    if(state == WON || state == LOST){
      left = false;
      right = false;
      up = false;
      down = false;
      paused = false;

      player = new Player(new PVector(width/2,height/2),playerHealth,characterWidth/2,characterWidth/2,color(0,0,0));
      resetGame();
      state = LEVEL_ONE;
      loop();
      return;
    }

    // During gameplay, Enter still works as pause/resume.
    if(state == LEVEL_ONE || state == BOSS){
      paused = !paused;
      if(paused){
        noLoop();
        textScreen("PAUSED","PRESS ENTER TO RESUME",60,75);
      } else {
        loop();
      }
    }
  }       
}

void keyReleased(){
  if(player.playerIsAlive()){
    if(key == 'a' || key == 'A') left = false;   
    if(key == 'w' || key == 'W') up = false;    
    if(key == 's' || key == 'S') down = false;
    if(key == 'd' || key == 'D') right = false;
  }

}

/*
void mousePressed(){
  if(player.playerIsAlive())
    player.fire();
}*/
