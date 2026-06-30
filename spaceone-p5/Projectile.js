// Projectile used by the player and the boss's fast cannon.
// Converted from Projectile.pde. Has a fading tail, grows in as it travels,
// and bursts into debris on impact.
class Projectile {
  constructor(pos, ang, vel, colour, scorePerHit) {
    this.pos = pos;
    this.ang = ang;
    this.vel = vel;
    this.colour = colour;
    this.scorePerHit = scorePerHit;

    this.debrisAmount = floor(random(7, 15));
    this.bDeathCountDown = -1;

    this.pWidth = 25; // long thin bullet
    this.rotPos = 0;
    this.rotVel = vel / 120;
    this.scale = 0.1; // initial scale (grows in)

    this.xspeed = vel * ang.x;
    this.yspeed = vel * ang.y;

    this.tail = []; // trail positions
    this.taillength = 6;

    this.isAlive = true;
    this.debris = [];
  }

  checkWalls() {
    if (
      abs(this.pos.x - width / 2) > width / 2 ||
      abs(this.pos.y - height / 2) > height / 2
    ) {
      this.bDeathCountDown = 10; // delay destruction so the animation finishes cleanly
    }
  }

  move() {
    this.pos.add(this.xspeed, this.yspeed);
  }

  update() {
    this.move();
    this.projectileTail();
    this.checkWalls();
    this.rotPos += this.rotVel;

    if (this.scale < 1.3) this.scale += 0.05;

    if (this.bDeathCountDown > 0 && this.bDeathCountDown !== -1)
      this.bDeathCountDown--;
    if (this.bDeathCountDown === 0) this.isAlive = false;

    this.debrisAdd(this.bDeathCountDown);
  }

  drawMe(tempv, fade) {
    if (this.bDeathCountDown === -1) {
      push();
      translate(tempv.x, tempv.y);
      rotate(this.rotPos);
      scale((this.scale * fade) / 4);
      rectMode(CENTER);
      noStroke();
      cFill(this.colour, 30 * fade);
      rect(0, 0, this.pWidth, this.pWidth);
      pop();
    } else {
      this.debrisUpdate(this.bDeathCountDown);
    }
  }

  // Collision with a character.
  hit(ch) {
    if (
      this.bDeathCountDown < 0 &&
      abs(this.pos.x - ch.pos.x) < this.pWidth / 2 + ch._width / 2 &&
      abs(this.pos.y - ch.pos.y) < this.pWidth / 2 + ch._width / 2
    ) {
      ch.decreaseHealth(1);
      printScore.updateScore(this.scorePerHit);
      this.bDeathCountDown = 60;
      startScreenShake(10, 5);
      return true;
    }
    return false;
  }

  debrisAdd(deathCountDown) {
    if (deathCountDown === 59) {
      for (let i = 0; i < this.debrisAmount; i++) {
        this.debris.push(
          new Debris(
            this.pos.x,
            this.pos.y,
            random(-2.5, 2.5),
            random(-2.5, 2.5),
            random(0.5, 2),
            50,
          ),
        );
      }
    }
  }

  debrisUpdate(deathCountDown) {
    if (deathCountDown > 0) {
      for (let i = 0; i < this.debris.length; i++) {
        const d = this.debris[i];
        if (deathCountDown > 0) {
          d.colour = this.colour;
          d.run();
          d.drawMe();
        } else if (deathCountDown === 0) {
          this.debris.splice(i, 1);
        }
      }
    }
  }

  // Build and draw the fading trail.
  projectileTail() {
    this.tail.push(createVector(this.pos.x, this.pos.y, 0));
    if (this.tail.length > this.taillength) {
      this.tail.splice(0, 1);
    }
    for (let i = 0; i < this.tail.length; i++) {
      this.drawMe(this.tail[i], i);
    }
  }
}
