// Score + difficulty tracker. Converted from Score.pde.
class Score {
  constructor() {
    this.score = 0;
    this.count = killCount + numEnemies; // enemies remaining
  }

  // Add to the score and ramp enemy speed at thresholds.
  updateScore(scor) {
    this.score += scor;
    if (this.score < 0) this.score = 0;
    if (this.score === 1 * difficulties) enemySpeed += 1;
    if (this.score === 5 * difficulties) enemySpeed += 1;
    if (this.score === 10 * difficulties) enemySpeed += 1;
  }

  killCount() {
    this.count--;
  }

  drawScore(scorePos, size) {
    textSize(size);
    fill(0);

    if (state === LEVEL_ONE) {
      text("Score: " + this.score, scorePos.x, scorePos.y);
    }

    if (state === BOSS) {
      textSize(size + 10);
      text("Score: " + this.score, scorePos.x, scorePos.y + 20);
    }

    if (state === WON || state === LOST) {
      textSize(size - 5);
      text("SCORE: " + this.score, scorePos.x, scorePos.y);
    }

    if (state === LEVEL_ONE) {
      textSize(size - 5);
      text(this.count + " Enemies Remaining", scorePos.x, scorePos.y + 30);
    }
  }
}
