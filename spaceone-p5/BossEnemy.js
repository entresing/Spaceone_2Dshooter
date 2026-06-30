// Boss. Converted from BossEnemy.pde.
// Chases the player and alternates two attack modes:
//   - a fast green cannon ball, then
//   - a slow spread of pink star projectiles.
class BossEnemy extends Enemy {
  constructor(pos, health, w, h, vel) {
    super(pos, health, w, h, vel);

    this.projectiles = []; // boss's own bullets
    this.ang = createVector(0, 0);
    this.dir = createVector(0, 0);

    this.scale = 1; // boss is not affected by the shrink scaling
    this.pSpeed = 10;
    this.recoil = 1;
    this.bounceTimer = -1;

    this.enemyColor = [193, 240, 26];
  }

  update() {
    super.update();

    if (this.hitCharacter(player) && this.enemyIsAlive()) {
      this.bounceTimer = 120;
      if (player.pHitCooldown === -1 && !this.enemyInvinci()) {
        player.pHitCooldown = 120;
      }
    }

    if (this.bounceTimer > 0 && player.playerIsAlive()) {
      const angle = atan2(this.pos.y - player.pos.y, this.pos.x - player.pos.x);
      this.dir.x = enemySpeed * cos(angle);
      this.dir.y = enemySpeed * sin(angle);
      this.bounceTimer--;
    }
    if (this.bounceTimer === 0) this.bounceTimer = -1;

    // Aim direction toward the player.
    this.ang = createVector(
      player.pos.x - this.pos.x,
      player.pos.y - this.pos.y,
    );
    this.ang.normalize();

    if (this.enemyIsAlive() && this.spawnInvinci < 0) {
      this.fireMode();
    }

    this.checkProjectile();
  }

  // Boss follows the player instead of drifting.
  moveCharacter() {
    if (this.bounceTimer === -1) {
      this.dir = createVector(
        player.pos.x - this.pos.x,
        player.pos.y - this.pos.y,
      );
      this.dir.normalize();
      this.dir.mult(enemySpeed);
    }
    this.pos.add(this.dir);
  }

  drawCharacter() {
    if (this.enemyIsAlive()) {
      noStroke();
      push();
      cFill(this.colour);
      rectMode(CENTER);
      translate(this.pos.x, this.pos.y);
      rotate(this.rotPos);
      scale(this.scale);
      rect(this.eShake.x, this.eShake.y, this._width, this._height);

      // rotated inner square (approximates the original packed-int colour math)
      push();
      rotate(PI / 4);
      fill(
        this.colour[0],
        constrain(this.colour[1] - 140, 0, 255),
        constrain(this.colour[2] + 100, 0, 255),
      );
      rect(this.eShake.x, this.eShake.y, this._width, this._height);
      pop();

      pop();

      fill(0);
      textAlign(CENTER);
      textSize(90);
      text(floor(this.health), this.pos.x, this.pos.y + 25);
    } else {
      this.debrisUpdate(this.eDeathCountDown);
    }
  }

  // Slow, spreading star attack (lowers player score on hit).
  fireSlow(_pSpeed, _fireRate) {
    this.projectiles.push(
      new BossProjectile(
        createVector(this.pos.x, this.pos.y),
        createVector(
          this.ang.x + random(-_fireRate, _fireRate),
          this.ang.y + random(-_fireRate, _fireRate),
        ),
        _pSpeed,
        [255, 0, 93, 200],
        -addScore,
      ),
    );
  }

  // Fast cannon attack (lowers player score on hit).
  fireFast(_pSpeed) {
    this.projectiles.push(
      new Projectile(
        createVector(this.pos.x, this.pos.y),
        createVector(this.ang.x, this.ang.y),
        _pSpeed,
        [193, 240, 26],
        -addScore,
      ),
    );
  }

  checkProjectile() {
    for (let i = 0; i < this.projectiles.length; i++) {
      const currProjectile = this.projectiles[i];
      currProjectile.update();
      if (this.enemyIsAlive()) {
        currProjectile.hit(player);
      }
    }
  }

  // First part of the cycle = fast cannon, second part = slow spread.
  fireMode() {
    bossAttackFrequency--;
    if (bossAttackFrequency > 240) {
      if (frameCount % 60 === 0) this.fireFast(this.pSpeed);
    }
    if (bossAttackFrequency > 0 && bossAttackFrequency < 239) {
      if (frameCount % 15 === 0)
        this.fireSlow(this.pSpeed - 9, this.recoil + 1);
    }
    if (bossAttackFrequency === 0) bossAttackFrequency = 480;
  }

  // Longer (3s) death animation than a normal enemy.
  decreaseHealth(damage) {
    super.decreaseHealth(damage);
    this.eShakeTimer = 60;
    if (this.health === 0) {
      printScore.killCount();
      this.eDeathCountDown = 180;
    }
  }

  // Boss debris trigger frame + larger pieces.
  debrisAdd(deathCountDown) {
    if (deathCountDown === 179) {
      for (let i = 0; i < this.debrisAmount; i++) {
        this.debris.push(
          new Debris(
            this.pos.x,
            this.pos.y,
            random(-3, 3),
            random(-3, 3),
            random(1, 4),
            110,
          ),
        );
      }
    }
  }

  // Confetti-coloured debris (does not inherit the body colour).
  debrisUpdate(deathCountDown) {
    if (deathCountDown > 0) {
      for (let i = 0; i < this.debris.length; i++) {
        const d = this.debris[i];
        if (deathCountDown > 0) {
          d.run();
          d.drawMe();
          d.rScale();
        } else if (deathCountDown === 0) {
          this.debris.splice(i, 1);
        }
      }
    }
  }

  // Simpler AABB (boss ignores the damage scaling).
  hitCharacter(other) {
    return (
      abs(this.pos.x - other.pos.x) < this._width / 2 + other._width / 2 &&
      abs(this.pos.y - other.pos.y) < this._height / 2 + other._height / 2
    );
  }
}
