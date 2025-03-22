# RABBIT

## remaining steps

### highest fuckin' priority

- maps
  - [ ] rabbit_tutorial
  - [ ] rabbit_a
  - [ ] rabbit_b
- [ ] tutorial / tutorializing how to play
  - controls
  - how to block
  - goon AOE group-stunning

### small tasks

- [ ] content warnings (cartoon pixelated blood, gore, and violence)
- [ ] "Submissions should include a 1-minute video showcasing gameplay."
- [ ] get final music OGGs from Dated (see design gDoc)
  - i converted from WAV to OGG using ffmpeg
- [ ] assign each level a song
- [ ] get final versions of levels
- [ ] add all levels to level select
- [ ] help with uploading to itch
- [ ] clean up README (desc, game title, etc)
- [ ] convert README.md to HTML for itch
- [ ] make sure materials are grouped properly in each map (water in a fountain should be a separate func_detail than the concrete of the fountain)
- [ ] health and magic -> progress bars
- [ ] layed overcharge bar for magic
- [ ] implement new footsteps from Hawk

### big tasks

- [ ] enemy spawn fx
  - "the code that handles activating enemies is on character base"
- [ ] goon AOE stun visual effect

---

- [x] reimplement head velocity away from player
- [x] implement portrait
- [x] make sure music loops properly
- [x] list tools
  - [x] dated (music)
  - [x] hawk (sfx)
- [x] gore, gibs
  - "do_damage on the health component"
  - [x] blood particle spray
  - [x] head phys sprite
  - [x] phys giblets
- [x] music (how?)
  - how = node in global scene

# ui

- [x] resume button
- [x] mouse sens
- [x] volume
- [x] music volume slider
- [x] music display ("now playing:")
- NO - rebinding / remapping
- [x] level select
- [x] credit(s)
- [x] material-sounds
  - [x] working on player
  - [x] footsteps (fs)
  - [x] landing
  - [x] jumping (generic)
- [x] ring flash on super block
- [x] redo arms
  - [x] mesh
  - [x] squash and stretch
  - [x] low-fps stop motion

# rebinding / remapping

_this is REALLY low priority._

- https://github.com/KoBeWi/Godot-Input-Remap <- THIS ONE
- https://github.com/IsItLucas/godot_easy_remap
- https://github.com/bend-n/remap
