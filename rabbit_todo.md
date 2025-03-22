# RABBIT

## remaining steps

### highest fuckin' priority

- maps
  - [ ] rabbit_tutorial
  - [x] rabbit_a
  - [x] rabbit_b
  - [ ] clean up tetrisk's maps
- [ ] tutorial / tutorializing how to play
  - controls
  - how to block
  - goon AOE group-stunning
  - punching restores MP lets you block
- [ ] PRESS <KEY> TO RESTART

### small tasks

- [ ] content warnings (cartoon pixelated blood, gore, and violence)
- [ ] "Submissions should include a 1-minute video showcasing gameplay."
  - i converted from WAV to OGG using ffmpeg
- [ ] help with uploading to itch
- [ ] clean up README (desc, game title, etc)
- [ ] convert README.md to HTML for itch
- [ ] make sure materials are grouped properly in each map (water in a fountain should be a separate func_detail than the concrete of the fountain)
- [ ] volume mixing pass
- [ ] make level1.map match my tutorial tracks
- [ ] REPLACE MARIO JUMP SOUND!
- [ ] remove magic overcharge
- playtest feedback
  - [ ] taking damage indicator
  - [ ] footsteps too loud
  - [ ] nerf alleys ending
- [ ] make metal containers have metal sound

---

- [-] fix gravel sfx
  - i need to remember to group things into GEO or DETAIL
- NO fix portrait after healing
- NO layed overcharge bar for magic
- [x] health and magic -> progress bars
- [x] get final versions of tetrisk's levels
- [x] add all levels to level select
- [x] assign each level a song
- [x] implement new footsteps from Hawk
- [x] sniper beep should be heard from further away
- [x] get final music OGGs from Dated (see design gDoc)
  - [x] 3 main tracks
  - [x] small loops (title, intermission, ending?)

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
