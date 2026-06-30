// Rotating square crosshair that follows the mouse. Converted from Crosshair.pde.
class Crosshair {
  constructor() {
    this.c = [0, 255, 0, 150];
    this.size = 35;
  }

  crossHair() {
    push();
    noStroke();
    translate(mouseX, mouseY);
    rotate((mouseX / width) * PI * 5);
    rectMode(CENTER);
    cFill(this.c);
    rect(0, 0, this.size, this.size);
    pop();
  }
}
