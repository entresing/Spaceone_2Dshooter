// Boss's slow spreading projectile. Converted from BossProjectile.pde.
// Drawn as a star and uses player-specific hit rules (respects hit-cooldown).
class BossProjectile extends Projectile {
  constructor(pos, ang, vel, colour, scorePerHit) {
    super(pos, ang, vel, colour, scorePerHit);
    this.taillength = 2;
  }

  drawMe(tempv, fade) {
    if (this.bDeathCountDown === -1) {
      push();
      translate(tempv.x, tempv.y);
      rotate(this.rotPos);
      scale((this.scale * fade) / 3);
      noStroke();
      cFill(this.colour);
      this.star(0, 0, this.pWidth, this.pWidth + 10, 6);
      pop();
    } else {
      this.debrisUpdate(this.bDeathCountDown);
    }
  }

  // Overridden so the player only takes a hit when not already cooling down.
  hit(p) {
    if (
      this.bDeathCountDown < 0 &&
      player.pHitCooldown === -1 &&
      abs(this.pos.x - p.pos.x) < this.pWidth / 2 + p._width / 2 &&
      abs(this.pos.y - player.pos.y) < this.pWidth / 2 + p._width / 2
    ) {
      player.pHitCooldown = 120;
      this.bDeathCountDown = 60;
      printScore.updateScore(this.scorePerHit);
      startScreenShake(18, 10);
      return true;
    }
    return false;
  }

  // Star shape.
  star(x, y, radius1, radius2, npoints) {
    const angle = TWO_PI / npoints;
    const halfAngle = angle / 2.0;
    beginShape();
    for (let a = 0; a < TWO_PI; a += angle) {
      let sx = x + cos(a) * radius2;
      let sy = y + sin(a) * radius2;
      vertex(sx, sy);
      sx = x + cos(a + halfAngle) * radius1;
      sy = y + sin(a + halfAngle) * radius1;
      vertex(sx, sy);
    }
    endShape(CLOSE);
  }
}
