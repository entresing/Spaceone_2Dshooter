// Player ship. Converted from Player.pde.
// Aims at the mouse, auto/hold fires, flashes red + shakes while invincible,
// and plays a crash -> debris death animation.
class Player extends Characters {
  constructor(pos, health, w, h, colour) {
    super(pos, health, w, h, colour);

    this.pShake = createVector(0, 0);
    this.ang = createVector(0, 0); // firing angle toward the mouse

    this.pSpeed = 15; // projectile speed
    this.pHitCooldown = -1; // invincibility timer
    this.pDeathCountDown = -1; // death animation timer
    this.pShakeTimer = -1; // shake-on-hit timer
    this.fireRate = 25;

    this.healthBar = health; // stored for the health-bar frame
    this.recoil = 0.15;

    this.projectiles = []; // ArrayList<Projectile> -> array

    this.rotVel = random(-0.25, 0.25);
  }

  update() {
    super.update();

    this.rotPos += this.rotVel;
    this.pShakeTimer--;

    // Angle from the ship to the mouse, normalized so bullet speed stays constant.
    this.ang = createVector(mouseX - this.pos.x, mouseY - this.pos.y);
    if (this.ang.x !== 0 && this.ang.y !== 0) {
      this.ang.normalize();
    }

    this.checkProjectiles();

    if (this.pDeathCountDown > 0 && this.pDeathCountDown !== -1) {
      this.vel = createVector(0, 0); // freeze during death animation
      this.pDeathCountDown--;
    }

    if (this.pHitCooldown > 0 && this.pHitCooldown < 118 && this.health !== 0) {
      this.invincible_Anim([255, 0, 0], [0, 0, 0, 200]);
    } else {
      this.colour = [0, 0, 0];
    }

    this.debrisAdd(this.pDeathCountDown);
    this.pShake = this.shakeEffect(
      createVector(this.pos.x, this.pos.y),
      this.pShakeTimer,
      6,
      random(-5, 5),
      [255, 0, 0, 200],
    );
  }

  // Fire a bullet toward the mouse with a little random spread.
  fire() {
    this.projectiles.push(
      new Projectile(
        createVector(this.pos.x, this.pos.y),
        createVector(
          this.ang.x + random(-this.recoil, this.recoil),
          this.ang.y + random(-this.recoil, this.recoil),
        ),
        this.pSpeed,
        [3, 177, 252],
        addScore,
      ),
    );
  }

  drawCharacter() {
    if (this.playerIsAlive()) {
      push();
      noStroke();
      translate(this.pos.x, this.pos.y);
      rotate(atan2(mouseY - this.pos.y, mouseX - this.pos.x) + PI / 2); // point the launcher at the mouse
      rectMode(CENTER);

      // gun
      fill(232, 140, 35);
      rect(this.pShake.x, this.pShake.y - 15, this._width / 2, this._height);

      // body (white underlay hides the gun silhouette)
      fill(255);
      ellipse(this.pShake.x, this.pShake.y, this._width, this._height);
      cFill(this.colour);
      ellipse(this.pShake.x, this.pShake.y, this._width, this._height);

      pop();
    } else {
      if (this.pDeathCountDown > 120) {
        // crash animation: spin + shrink
        push();
        noStroke();
        translate(this.pos.x, this.pos.y);
        rotate(this.rotPos);
        scale(this.pDeathCountDown / 240);
        rectMode(CENTER);
        fill(232, 140, 35);
        rect(0, -15, this._width / 2, this._height);
        cFill(this.colour);
        ellipse(0, 0, this._width, this._height);
        pop();
      } else if (this.pDeathCountDown < 119 && this.pDeathCountDown > 0) {
        this.debrisUpdate(this.pDeathCountDown);
      }
    }
  }

  // Health bar, top-left of the screen.
  drawHealthBar() {
    if (this.health !== 0 && this.playerIsAlive()) {
      push();
      translate(50, 95);
      rectMode(CORNER);

      noStroke();
      fill(0, 200, 0);
      rect(0, 0, 25 * this.health, 15);

      strokeWeight(5);
      stroke(0);
      noFill();
      rect(0, 0, 25 * this.healthBar, 15);

      pop();
    }
  }

  // Update bullets and test them against every enemy.
  checkProjectiles() {
    for (let i = 0; i < this.projectiles.length; i++) {
      const currProjectile = this.projectiles[i];
      currProjectile.update();

      for (let j = 0; j < enemies.length; j++) {
        const e = enemies[j];
        if (!e.enemyInvinci() && e.enemyIsAlive()) {
          currProjectile.hit(e);
        }
      }

      if (!currProjectile.isAlive) {
        this.projectiles.splice(i, 1);
      }
    }
  }

  // Overridden to add the shake + screen-shake + death trigger.
  decreaseHealth(damage) {
    super.decreaseHealth(damage);
    this.pShakeTimer = 120;
    startScreenShake(18, 10);
    if (this.health === 0) {
      this.pDeathCountDown = 240;
    }
  }

  playerIsAlive() {
    return this.pDeathCountDown === -1;
  }

  gameOver() {
    return this.pDeathCountDown === 0;
  }
}
