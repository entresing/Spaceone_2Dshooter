// Explosion particle. Converted from Debris.pde.
// Fades out, rotates, drifts, and shrinks for a natural-looking burst.
class Debris {
  constructor(tempx, tempy, xspeed, yspeed, scale, opacityTimer) {
    this.splash = 5;

    const startx = tempx + random(-this.splash, this.splash);
    const starty = tempy + random(-this.splash, this.splash);

    this.scale = scale;
    this.opacityTimer = opacityTimer;

    this.pos = createVector(startx, starty);
    this.speed = createVector(xspeed, yspeed);

    this.rotPos = 0;
    this.rotVel = random(-0.1, 0.1);
    this.radius = 10;
    this.debrisDamp = 0.98;

    // Random colour (used for the boss confetti effect).
    this.colour = [random(255), random(255), random(255)];
  }

  run() {
    this.rotPos += this.rotVel;
    this.opacityTimer--;
    this.pos.add(this.speed);
    this.speed.mult(this.debrisDamp);
  }

  rScale() {
    this.scale -= 0.01;
  }

  drawMe() {
    push();
    translate(this.pos.x, this.pos.y);
    rectMode(CENTER);
    noStroke();
    rotate(this.rotPos);
    scale(this.scale);
    cFill(this.colour, this.opacityTimer);
    rect(0, 0, this.radius, this.radius);
    pop();
  }
}
