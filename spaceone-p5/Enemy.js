// Basic enemy. Converted from Enemy.pde.
// Drifts around, bounces off other enemies (which speeds everyone up),
// has spawn invincibility, shrinks as it takes damage, then bursts into debris.
class Enemy extends Characters {
  constructor(pos, health, w, h, vel) {
    super(pos, health, w, h, [130, 130, 130]);

    this.vel = vel;
    this.eShake = createVector(0, 0);

    this.spawnInvinci = 120; // ~2s of ignore-everything
    this.eShakeTimer = -1;
    this.eDeathCountDown = -1; // set when the enemy dies

    this.shakeScale = random(-10, 10);
    this.shakeDelay = 6;
    this.eVariation = health * 20;

    this.enemyColor = [130, 130, 130];

    this.rotVel = random(-0.03, 0.03);
  }

  update() {
    super.update();
    this.rotPos += this.rotVel;

    if (this.enemyIsAlive()) {
      this.spawnInvinci--;
      this.eShakeTimer--;
    }

    if (this.eDeathCountDown > 0 && this.eDeathCountDown !== -1) {
      this.eDeathCountDown--;
    }
    this.debrisAdd(this.eDeathCountDown);

    if (this.eDeathCountDown === 0 && !this.enemyIsAlive()) {
      const idx = enemies.indexOf(this);
      if (idx !== -1) enemies.splice(idx, 1);
    }

    this.spawnInv();
    this.eShake = this.shakeEffect(
      createVector(this.pos.x, this.pos.y),
      this.eShakeTimer,
      6,
      random(-10, 10),
      [255, 0, 0, 150],
    );

    // Collision with the player.
    if (this.hitCharacter(player) && this.enemyIsAlive()) {
      this.bouncePlayer(player);
      if (player.pHitCooldown === -1 && !this.enemyInvinci()) {
        player.pHitCooldown = 120;
      }
    }
  }

  moveCharacter() {
    this.pos.add(this.vel);
  }

  drawCharacter() {
    if (this.enemyIsAlive()) {
      noStroke();
      push();
      cFill(this.colour);
      rectMode(CENTER);
      translate(this.pos.x, this.pos.y);
      rotate(this.rotPos);
      scale((this.scale * this.health) / this.hitScale); // shrinks as it loses health
      rect(this.eShake.x, this.eShake.y, this._width, this._height);
      pop();

      fill(0);
      textAlign(CENTER);
      textSize(20 * this.health);
      text(floor(this.health), this.pos.x - 1, this.pos.y + 6.5 * this.health);
    } else {
      this.debrisUpdate(this.eDeathCountDown);
    }
  }

  // Overridden to add the shake + death timers.
  decreaseHealth(damage) {
    super.decreaseHealth(damage);
    this.eShakeTimer = 60;
    if (this.health === 0) {
      printScore.killCount();
      this.eDeathCountDown = 120;
    }
  }

  // Flash while spawn-invincible.
  spawnInv() {
    if (this.spawnInvinci > 0) {
      this.invincible_Anim(this.enemyColor, [
        this.enemyColor[0],
        this.enemyColor[1],
        this.enemyColor[2],
        55,
      ]);
    } else {
      this.colour = this.enemyColor;
    }
  }

  // Enemy-vs-enemy bounce: each collision speeds them up slightly.
  bounceCollision(other) {
    const angle = atan2(this.pos.y - other.pos.y, this.pos.x - other.pos.x);
    const avgSpeed = (this.vel.mag() + other.vel.mag() + enemySpeed / 10) / 2;

    this.vel.x = avgSpeed * cos(angle);
    this.vel.y = avgSpeed * sin(angle);
    other.vel.x = avgSpeed * cos(angle - PI);
    other.vel.y = avgSpeed * sin(angle - PI);
  }

  // Knock the enemy away from the player on contact.
  bouncePlayer(p) {
    const angle = atan2(this.pos.y - p.pos.y, this.pos.x - p.pos.x);
    this.vel.x = enemySpeed * cos(angle);
    this.vel.y = enemySpeed * sin(angle);
  }

  enemyIsAlive() {
    return this.eDeathCountDown === -1;
  }

  enemyInvinci() {
    return this.spawnInvinci > 0;
  }
}
