// Base class for every moving entity (player, enemies, boss).
// Converted from Characters.pde. Adds the shared invincible-flash, debris,
// and shake helpers that every character reuses.
class Characters {
  constructor(pos, health, w, h, colour) {
    this.pos = pos; // p5.Vector
    this.vel = createVector();
    this.colour = colour; // [r,g,b] or [r,g,b,a]
    this.health = health;
    this._width = w;
    this._height = h;

    this.rotPos = 0;
    this.rotVel = 0;

    this.damp = 0.95;
    this.scale = random(1, 1.3);
    this.hitScale = enemyHealth + 2.5;

    this.debrisAmount = floor(random(15, 25));
    this.debris = []; // ArrayList<Debris> -> array
  }

  update() {
    this.moveCharacter();
    this.checkWalls();
  }

  // Moves using velocity, then damps it.
  moveCharacter() {
    this.pos.add(this.vel);
    this.vel.mult(this.damp);
  }

  accelerate(force) {
    this.vel.add(force);
  }

  // AABB collision that accounts for the damage-driven scaling.
  hitCharacter(other) {
    const s = (this.scale * this.health) / this.hitScale;
    return (
      abs(this.pos.x - other.pos.x) <
        (this._width / 2) * s + (other._width / 2) * s &&
      abs(this.pos.y - other.pos.y) <
        (this._height / 2) * s + (other._height / 2) * s
    );
  }

  decreaseHealth(damage) {
    this.health -= damage;
  }

  // Default placeholder body.
  drawCharacter() {
    push();
    translate(this.pos.x, this.pos.y);
    noStroke();
    cFill(this.colour);
    ellipse(0, 0, this._width, this._height);
    pop();
  }

  // Wrap to the opposite side of the screen.
  checkWalls() {
    if (this.pos.x < -this._width / 2) this.pos.x = width + this._width / 2;
    if (this.pos.x > width + this._width / 2) this.pos.x = -this._width / 2;
    if (this.pos.y < -this._height / 2) this.pos.y = height + this._height / 2;
    if (this.pos.y > height + this._height / 2) this.pos.y = -this._height / 2;
  }

  // Flashing colour effect used while invincible.
  invincible_Anim(aColour, bColour) {
    const delay = 8;
    this.colour = aColour;
    if (frameCount % (2 * delay) < delay) {
      this.colour = bColour;
    }
  }

  // Spawn debris once, when the death timer reaches the trigger frame.
  debrisAdd(deathCountDown) {
    if (deathCountDown === 119) {
      for (let i = 0; i < this.debrisAmount; i++) {
        this.debris.push(
          new Debris(
            this.pos.x,
            this.pos.y,
            random(-3, 3),
            random(-3, 3),
            random(1, 2),
            170,
          ),
        );
      }
    }
  }

  // Play the debris explosion animation.
  debrisUpdate(deathCountDown) {
    if (deathCountDown >= 0) {
      for (let i = 0; i < this.debris.length; i++) {
        const d = this.debris[i];
        if (deathCountDown >= 0) {
          d.colour = this.colour;
          d.run();
          d.drawMe();
          d.rScale();
        } else if (deathCountDown === 0) {
          this.debris.splice(i, 1);
        }
      }
    }
  }

  // Returns an offset vector for the shake effect and flashes the colour.
  shakeEffect(shakePos, shakeTimer, shakeDelay, shakeScale, nColour) {
    if (frameCount % (2 * shakeDelay) < shakeDelay && shakeTimer > 0) {
      shakePos.x = shakeScale;
      shakePos.y = shakeScale;
      this.colour = nColour;
    } else {
      shakePos.x = 0;
      shakePos.y = 0;
    }
    return shakePos;
  }
}
