# RABBIT

# web export issues

- [-] SUPER lag on first gib/gore
- [x] 1 sec lag on EVERY block
  - had to write my own shader DX
- [x] add "ENTER to PAUSE" hint

## remaining steps

- [ ] upload to itch
  - [ ] add Steam as author
- [ ] convert README.md to HTML for itch
- from Steam
  - cover art
  - brother art
  - clip factory a lil

---

- [-] style the itch page (CSS)
  - apparently you can't use CSS ahaha

### small tasks

- [x] stylized 3d model or sprite/image of title
- itch: cover image
- [x] itch: screenshots
- [x] itch: gameplay video
- [x] "Submissions should include a 1-minute video showcasing gameplay."

### highest fuckin' priority

- [x] intermission scene
  - wait for input, show stats
  - kills, time
- [x] game should start with menu showing / title screen
  - [x] add content warning TO THE TITLE SCREEn
- [x] PRESS <KEY> TO RESTART
- [x] NAME THE GAME
  - steam suggestions
  - Punchopolis
  - Streets of Beasts
  - Streets of BEAsTS <-
- [x] tutorial / tutorializing how to play
  - controls
  - how to block
  - goon AOE group-stunning
  - punching restores MP lets you block
- [x] maps
  - [x] rabbit_tutorial
  - add a button
  - [x] rabbit_a
  - [x] rabbit_b
  - [x] clean up tetrisk's maps

# done

- [-] loading ui
  - CANT GET IT WORKING, NO TIME :(
- playtest feedback
  - a
  - [ ] taking damage indicator
  - [x] footsteps too loud
  - [-] nerf alleys ending
  - b
  - [x] fix tutorial door going wrong way
  - [-] make tutorial grunt at end easier to get
  - clip brush to pipes in Factory
  - NO rename factory to Foundry ?
  - [x] hook up enemy spawns in factory
- [x] REPLACE MARIO JUMP SOUND!
- [x] clean up README (desc, game title, etc)
- [x] clip boxes near L button in factory
- [x] make sure materials are grouped properly in each map (water in a fountain should be a separate func_detail than the concrete of the fountain)
- [x] volume mixing pass
- [x] content warnings (cartoon pixelated blood, gore, and violence)
- [-] make level1.map match my tutorial tracks
- [x] remove magic overcharge
- PROBABLY NO make metal containers have metal sound
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
  - i converted from WAV to OGG using ffmpeg
  - [x] 3 main tracks
  - [x] small loops (title, intermission, ending?)

### big tasks

- [ ] enemy spawn fx
  - "the code that handles activating enemies is on character base"
- [ ] goon AOE stun visual effect
- [x] button sounds
- [x] door sounds

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
