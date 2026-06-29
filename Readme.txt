# Spaceone

**Spaceone** is a 2D space shooter mini game built in **Processing** using Java-style object-oriented programming. The player controls a spaceship, avoids enemy collisions, and survives by eliminating waves of alien ships before facing a boss encounter.

This was my first fully self-coded game project. Unlike my earlier game projects where I mainly contributed as an artist or VFX designer, Spaceone was created through code from the ground up, using simple geometric shapes, motion, collision logic, particle effects, and screen feedback instead of pre-made sprite assets.

## Gameplay

The goal is to survive, destroy enemy ships, and defeat the final boss. The game starts with a wave-based enemy phase, then transitions into a boss fight after all regular enemies are cleared.

The player automatically fires projectiles toward the mouse cursor, allowing the player to focus on movement, aiming, dodging, and survival.

## Controls

| Action | Input |
| --- | --- |
| Move Up | `W` |
| Move Left | `A` |
| Move Down | `S` |
| Move Right | `D` |
| Aim | Mouse position |
| Shoot | Automatic |
| Start Game | `Enter` |
| Pause / Resume | `Enter` during gameplay |
| Restart after Win/Loss | `Enter` |

## Features

- Player movement using acceleration and damping
- Automatic projectile firing system
- Mouse-based aiming and crosshair feedback
- Enemy spawning, movement, collision, and death states
- Boss encounter with multiple projectile attack patterns
- Health, score, and enemy remaining UI
- Difficulty scaling as the player score increases
- Particle/debris explosion effects on enemy and projectile destruction
- Local hit shake on characters
- Global screen shake when projectiles hit or the player takes damage
- Game state system for title, gameplay, boss, win, loss, pause, and restart flows
- Geometry-based visual design using rectangles, ellipses, stars, and procedural effects

## Technical Overview

Spaceone is structured around several Processing classes:

| File | Purpose |
| --- | --- |
| `ShootEmUp19.pde` | Main game loop, state management, spawning, screen shake, and update flow |
| `Player.pde` | Player movement, firing, health, hit feedback, and death logic |
| `Enemy.pde` | Regular enemy behaviour, collisions, damage, and death effects |
| `BossEnemy.pde` | Boss enemy logic and attack pattern switching |
| `Projectile.pde` | Player and enemy projectile movement, collision, trails, and debris |
| `BossProjectile.pde` | Boss-specific star projectile behaviour |
| `Characters.pde` | Shared character movement, wall wrapping, collision, health, and visual feedback |
| `Debris.pde` | Particle fragments used for explosion effects |
| `Crosshair.pde` | Mouse cursor/crosshair rendering |
| `Score.pde` | Score display, enemy count, and difficulty progression |
| `keyBoard_module.pde` | Keyboard input, pause, start, and restart handling |

## How to Run

### Option 1: Run the exported application

1. Unzip the game folder.
2. Open the `Spaceone` folder.
3. Run `spaceone.exe`.

This exported version includes its own Java runtime, so Processing does not need to be installed.

### Option 2: Run from Processing source

1. Install Processing.
2. Create a sketch folder named `ShootEmUp19`.
3. Place the `.pde` source files inside that folder.
4. Copy the `data` folder into the sketch folder if the custom font is needed.
5. Open `ShootEmUp19.pde` in Processing.
6. Click **Run**.

## Project Context

Spaceone was developed as an early self-directed coding project while I was learning Processing, Java syntax, and object-oriented programming. The project helped me practice building a playable game loop, organizing gameplay systems into classes, handling collisions, and creating visual impact through code-driven effects.

For my portfolio, this project represents my ability to create game feel with minimal visual assets: screen shake, impact effects, motion trails, explosions, player damage feedback, and simple but readable arcade-style interactions.

## Development Notes

Recent improvements include:

- Changed shooting from mouse-hold input to automatic firing
- Added global screen shake on projectile hit and player damage
- Changed title and end screens so the game starts/restarts with one `Enter` press

## Tools

- Processing
- Java-style OOP
- Procedural/geometry-based visual effects

## Author

**Dennis Deng**  
Game Developer / Technical Artist / UX-UI Designer  
Portfolio: [dennisdeng.com](https://www.dennisdeng.com/)
