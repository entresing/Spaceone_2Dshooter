// score class to calculate and show the score for the player.
class Score {
  int score;  //field to store score
  int count; // store killed enemies
  
  //constructor to initialize the field
  Score() {
    score = 0;
    count = killCount + numEnemies;
  }
  
 //update score by the amount of scor
  void updateScore (int scor){
    score += scor;
    if(score < 0) score = 0; // reset score to 0 when below 0.
    if(score == 1*difficulties){ // increase enemies move speed when score is over the threshold
      enemySpeed += 1;
    }

    if(score == 5*difficulties){  
      enemySpeed += 1;
    }
    
    if(score == 10*difficulties){ 
      enemySpeed += 1;
    }    
  }
  
  void killCount(){
    //kill Count
    count--;
  }
  
  void drawScore(PVector scorePos,int size) {
      textSize(size);
    //set its color to black
      fill(0);    
      //draw score near the left edge of the window during LEVEL_ONE
      if(state == LEVEL_ONE)
        text ("Score: " + score, scorePos.x, scorePos.y);
      
      // print score in bigger font during BOSS state
      if(state == BOSS){
        textSize(size+10);
        text ("Score: " + score, scorePos.x, scorePos.y+20);
      }
      
      // print score in the middle in WON state
      if(state == WON || state == LOST){
        textSize(size-5);
        text ("SCORE: " + score, scorePos.x, scorePos.y);
      }
        
      // print enemies remaining during level one
      if(state == LEVEL_ONE){
        textSize(size-5);  
        text(count + " Enemies Remaining",scorePos.x,scorePos.y+30);
      }
  }
  
}
