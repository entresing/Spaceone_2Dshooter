// Spaceone - p5.js conversion of the original Processing/Java project.
// Main sketch: globals, state machine, setup/draw, screen overlays and input.

// ---- Global config (from Spaceone_2Dshooter.pde) ----
const characterWidth = 100;

let numEnemies = 5;
let killCount = 15;
let addScore = 5;
let threshold;

let playerHealth = 5;
let enemyHealth = 1; // randomised (1..4) per enemy
let bossHealth = 20; // randomised (20..23)
let bossAttackFrequency = 480;

let enemyDeathTimer;
let difficulties = 5;
let warningTimer = 240; // 4 seconds

// Screen shake
let screenShakeTimer = 0;
let screenShakeAmount = 0;

let enemySpeed = 3;

// Reset backups
let reNumEnemies;
let reKillCount;
let reEnemySpeed;

let enemies = []; // ArrayList<Enemy> -> array

let player;
let crosshair; // renamed from `cursor` to avoid clashing with p5's cursor()
let printScore;

// Game states
let state;
const LEVEL_ONE = 0;
const BOSS = 1;
const WON = 2;
const LOST = 3;
const MAIN = 4;

// Pause flag for in-game Enter toggle.
let paused = false;

// ---- Movement controls (from keyBoard_module.pde) ----
let up = false,
  down = false,
  left = false,
  right = false;
let upAcc, downAcc, leftAcc, rightAcc;

// Small helper to fill from an [r,g,b] / [r,g,b,a] array, with optional alpha override.
function cFill(c, a) {
  if (a !== undefined) fill(c[0], c[1], c[2], a);
  else if (c.length >= 4) fill(c[0], c[1], c[2], c[3]);
  else fill(c[0], c[1], c[2]);
}

function setup() {
  const cnv = createCanvas(1280, 900);
  cnv.parent("game-container");
  frameRate(60);

  // Acceleration vectors (must be created after p5 is ready).
  upAcc = createVector(0, -1.3);
  downAcc = createVector(0, 1.3);
  leftAcc = createVector(-1.3, 0);
  rightAcc = createVector(1.3, 0);

  state = MAIN;

  player = new Player(
    createVector(width / 2, height / 2),
    playerHealth,
    characterWidth / 2,
    characterWidth / 2,
    [0, 0, 0],
  );
  crosshair = new Crosshair();

  // Invincibility grace period at the start.
  player.pHitCooldown = 118;

  for (let i = 0; i < numEnemies; i++) addEnemy();

  printScore = new Score();

  // The original .vlw bitmap font cannot be loaded in the browser, so we use
  // Orbitron (a bold sci-fi Google Font) for the same heavy display feel.
  textFont("Orbitron");
  textStyle(BOLD);
  textSize(20);

  // Web fonts load asynchronously; force the weights we need, then redraw so the
  // frozen title screen picks up Orbitron instead of a fallback font.
  if (document.fonts && document.fonts.load) {
    Promise.all([
      document.fonts.load("700 30px Orbitron"),
      document.fonts.load("900 30px Orbitron"),
    ]).then(() => {
      if (typeof redraw === "function") redraw();
    });
  }

  // Store reset values.
  reNumEnemies = numEnemies;
  reKillCount = killCount;
  reEnemySpeed = enemySpeed;
}

function draw() {
  switch (state) {
    case LEVEL_ONE:
      gamePlay();
      if (enemies.length === 0) warningTimer--;
      warningScreen("WARNING!!!");
      if (warningTimer === 0) state = BOSS;
      break;

    case BOSS:
      gamePlay();
      if (warningTimer === 0) {
        addBoss();
        warningTimer = -1;
      }
      if (enemies.length === 0 && enemyDeathTimer === 0) state = WON;
      break;

    case WON:
      gamePlay();
      textScreen("YOU WIN!", "Press ENTER TO RESTART", 75, 75);
      achievement(createVector(width / 2, height / 2 + 175), 50);
      printScore.drawScore(createVector(width / 2, height / 2 + 125), 50);
      break;

    case LOST:
      gamePlay();
      textScreen("GAME OVER", "Press ENTER TO RESTART", 75, 75);
      printScore.drawScore(createVector(width / 2, height / 2 + 125), 50);
      break;

    case MAIN:
      gamePlay();
      textScreen("SPACE ONE", "Press ENTER to Start", 75, 75);
      break;
  }
}

// ---- Core gameplay update (from gamePlay()) ----
function gamePlay() {
  background(255);

  push();
  applyScreenShake();

  threshold = numEnemies - 1;

  if (threshold > enemies.length && killCount !== 0) {
    addEnemy();
    killCount--;
  }

  if (player.pHitCooldown === 119) player.decreaseHealth(1);

  if (player.pHitCooldown > 0) player.pHitCooldown--;
  else if (player.pHitCooldown === 0) player.pHitCooldown = -1;

  enemyUpdate();
  playerUpdate();

  pop();
}

function addEnemy() {
  enemies.push(
    new Enemy(
      createVector(
        random(characterWidth / 2, width - characterWidth / 2),
        random(characterWidth / 2, height - characterWidth / 2),
      ),
      floor(random(enemyHealth, enemyHealth + 3)),
      characterWidth,
      characterWidth,
      createVector(
        random(-enemySpeed, enemySpeed),
        random(-enemySpeed, enemySpeed),
      ),
    ),
  );
}

function addBoss() {
  enemies.push(
    new BossEnemy(
      createVector(
        random(characterWidth / 2, width - characterWidth / 2),
        random(characterWidth / 2, height - characterWidth / 2),
      ),
      floor(random(bossHealth, bossHealth + 3)),
      characterWidth,
      characterWidth,
      createVector(
        random(-enemySpeed + 2, enemySpeed - 2),
        random(-enemySpeed, enemySpeed),
      ),
    ),
  );
}

function enemyUpdate() {
  for (let i = 0; i < enemies.length; i++) {
    const currEnemies = enemies[i];
    for (let j = i + 1; j < enemies.length; j++) {
      const otherEnemies = enemies[j];
      if (
        currEnemies.hitCharacter(otherEnemies) &&
        currEnemies.enemyIsAlive()
      ) {
        currEnemies.bounceCollision(otherEnemies);
      }
    }
    currEnemies.update();
    currEnemies.drawCharacter();
    enemyDeathTimer = currEnemies.eDeathCountDown;
  }
}

function playerUpdate() {
  player.update();
  player.drawCharacter();

  // Faithful to the original operator precedence: (alive && LEVEL_ONE) || BOSS
  if ((player.playerIsAlive() && state === LEVEL_ONE) || state === BOSS) {
    crosshair.crossHair();
    player.drawHealthBar();

    textAlign(LEFT);
    printScore.drawScore(createVector(50, 50), 30);

    if (up) player.accelerate(upAcc);
    if (left) player.accelerate(leftAcc);
    if (right) player.accelerate(rightAcc);
    if (down) player.accelerate(downAcc);

    // Hold left click to fire, limited by fireRate.
    if (
      //   mouseIsPressed &&
      //   mouseButton === LEFT &&
      frameCount % player.fireRate === 0 &&
      player.pDeathCountDown === -1
    ) {
      player.fire();
    }
  }

  if (player.gameOver()) state = LOST;
}

// ---- Screen shake ----
function startScreenShake(duration, amount) {
  screenShakeTimer = max(screenShakeTimer, duration);
  screenShakeAmount = max(screenShakeAmount, amount);
}

function applyScreenShake() {
  if (screenShakeTimer > 0) {
    translate(
      random(-screenShakeAmount, screenShakeAmount),
      random(-screenShakeAmount, screenShakeAmount),
    );
    screenShakeTimer--;
    screenShakeAmount *= 0.85;
  } else {
    screenShakeAmount = 0;
  }
}

// ---- Overlays ----
function textScreen(t, t2, size, y_axis) {
  noLoop(); // freeze the frame; resumed by loop() on the next Enter
  fill(0, 0, 0, 50);
  rectMode(CORNER);
  rect(0, 0, width, height);

  // drop shadow
  fill(0);
  textAlign(CENTER);
  textSize(size);
  text(t, width / 2 + 4, height / 2 - y_axis + 4);
  textSize(size - 25);
  text(t2, width / 2 + 4, height / 2 + 4);

  // text
  fill(80);
  textAlign(CENTER);
  textSize(size);
  text(t, width / 2, height / 2 - y_axis);
  textSize(size - 25);
  text(t2, width / 2, height / 2);
}

function warningScreen(t) {
  const delay = 30;
  if (warningTimer > 0 && warningTimer < 239) {
    noStroke();
    fill(255, 0, 0, 100);
    rectMode(CORNER);
    rect(0, 0, width, height);
    if (frameCount % (2 * delay) < delay) {
      textAlign(CENTER);
      textSize(75);
      fill(0, 100);
      text(t, width / 2 + 4, height / 2 + 4);
      fill(0);
      text(t, width / 2, height / 2);
    }
  }
}

function achievement(scorePos, size) {
  if (player.health === playerHealth && state === WON) {
    fill(255, 111, 0);
    textSize(size - 5);
    text("ACHIEVEMENT OBTAIN: EASY PEASY", scorePos.x, scorePos.y);
  }
}

// ---- Reset (from resetGame()) ----
function resetGame() {
  printScore.score = 0;

  reEnemySpeed = enemySpeed;
  numEnemies = reNumEnemies;
  killCount = reKillCount;
  printScore.count = killCount + numEnemies;

  warningTimer = 240;
  player.pHitCooldown = 118;

  for (let i = 0; i < numEnemies; i++) addEnemy();
  player.health = playerHealth;
}

// ---- Input ----
// Single Enter starts, pauses/resumes, and restarts depending on state.
function handleEnter() {
  if (state === MAIN) {
    state = LEVEL_ONE;
    paused = false;
    loop();
    return;
  }

  if (state === WON || state === LOST) {
    left = right = up = down = false;
    paused = false;

    enemies = [];
    player = new Player(
      createVector(width / 2, height / 2),
      playerHealth,
      characterWidth / 2,
      characterWidth / 2,
      [0, 0, 0],
    );
    resetGame();
    state = LEVEL_ONE;
    loop();
    return;
  }

  if (state === LEVEL_ONE || state === BOSS) {
    paused = !paused;
    if (paused) {
      textScreen("PAUSED", "PRESS ENTER TO RESUME", 60, 75); // draws + noLoop()
    } else {
      loop();
    }
  }
}

function keyPressed() {
  if (keyCode === ENTER) {
    handleEnter();
  }

  if (player && player.playerIsAlive()) {
    if (key === "a" || key === "A" || keyCode === LEFT_ARROW) left = true;
    if (key === "w" || key === "W" || keyCode === UP_ARROW) up = true;
    if (key === "s" || key === "S" || keyCode === DOWN_ARROW) down = true;
    if (key === "d" || key === "D" || keyCode === RIGHT_ARROW) right = true;
  }

  // Stop arrow keys / space from scrolling the host page.
  if (
    keyCode === LEFT_ARROW ||
    keyCode === RIGHT_ARROW ||
    keyCode === UP_ARROW ||
    keyCode === DOWN_ARROW ||
    keyCode === 32
  ) {
    return false;
  }
}

function keyReleased() {
  if (player && player.playerIsAlive()) {
    if (key === "a" || key === "A" || keyCode === LEFT_ARROW) left = false;
    if (key === "w" || key === "W" || keyCode === UP_ARROW) up = false;
    if (key === "s" || key === "S" || keyCode === DOWN_ARROW) down = false;
    if (key === "d" || key === "D" || keyCode === RIGHT_ARROW) right = false;
  }
}
