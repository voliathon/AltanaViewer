# AltanaViewer

AltanaViewer is a dedicated 3D model and asset viewer for Final Fantasy XI (FFXI). It allows users to explore the game's extensive catalog of player characters, monsters, equipment, animations, and visual effects outside of the game client.

## Features

* **Player Character Viewer:** View all playable races (Hume, Elvaan, Tarutaru, Mithra, and Galka).
* **Equipment Dressing:** Mix and match armor, weapons, and accessories across all visual equipment slots (Head, Body, Hands, Legs, Feet, Main, Sub).
* **NPC & Monster Bestiary:** Browse through the game's vast array of enemies and NPCs, categorized by ecosystem family (e.g., Aquans, Beastmen, Dragons) and expansion content.
* **Animation & Effects Playback:** View weapon skills, magic casting effects (White Magic, Black Magic, Ninjutsu, etc.), and standard character motions.
* **Asset Mapping:** Comprehensive CSV lists that map raw game DAT files to human-readable names.

## Directory Structure

The repository is organized to neatly categorize the massive amount of FFXI game data:

* `AltanaView.exe` - The main executable application.
* `List/` - The core database of the viewer, containing CSV files that map assets:
  * `Effect/` - Spell effects, job abilities, and weapon skill visuals.
  * `Image/` - UI elements, zone images, and miscellaneous 2D graphics.
  * `Music/` - Background music and audio track mappings.
  * `NPC/` - Non-playable characters and monsters, sorted by family and expansion.
  * `PC/` - Player character models, separated by race, gender, and equipment slots.
* `res/` - Resource text files containing deeper configurations for animations and sound effects.

## Usage

1. Ensure you have Final Fantasy XI installed on your system, as the viewer requires the game's local DAT files to render models.
2. Run `AltanaView.exe`.
3. Use the application's interface to navigate through the PC, NPC, or Effect lists to load and view the desired assets.

## Contributing

Because Final Fantasy XI continues to receive updates, the CSV lists require periodic maintenance to include newly added armor, weapons, and monster models. If you are updating the lists, please ensure you place the new item IDs and DAT mappings in their respective CSV files within the `List/` directory.

## History & Origins

The original Altana Viewer was created around 2006 by an anonymous Japanese developer (often associated with the copyright "Tiamat"). It was built upon the foundation of an older Japanese model viewer known as `FFXITool`. Both programs were unique at the time for being able to decipher and play back FFXI's complex effect animations.

Because the original author disappeared and the software was never made open-source, the community has never been able to update the core application engine. The viewer is kept alive for modern FFXI updates by Voliathon at this repository. I will accept Pull Requests. I manually update the extensive CSV dictionary lists to map new DAT files as Square Enix adds them to the game.

## 2026 Change Log
- Mithra Changes (Feb-25-2026)
  - Face.csv(Actual Faces of Mithra)
    - Added Skhoh Undhreh and corrected names/Nanaa Mihgo
  - Head.csv(Head Equipment)
    - Head equipment are now ordered by level
	- More Lv.1 lockstyles (Login Points, Events...)
	- Odyssey Head Gear and more corrections
  - Main.csv
	- Added a club called Feline Hagoita 

- Mithra Changes(Feb-20-2026)
  - Main.csv(Weapons):
    - Weapons are now ordered by level
	- Corrections to incorrect weapons
	- More Lv.1 lockstyles (Login Points, Ambuscade, Ethereal, More...) 
	- Master Trial Weapons
	- Odyssey Weapons
	- Primes included
  - Sub.csv(Sub/Shields/Weapons):
    - Weapons are now ordered by level
	- Identified and Correctly Changed Equipment names
	- More Lv.1 lockstyles (Login Points, Ambuscade, Ethereal, More...) 
	- Master Trial Weapons
	- Odyssey Weapons
	- Primes included 
  - Action.csv(Animations)
    - Animations are now alphabatized
  - Range.csv(Ammo/Throwing/Crossbow/Bow/Gun/Instruments/Bells)(Feb-20)
    - Ranged everything is now ordered by level
	- More lockstyles (Ambuscade/Ethereal)
	- Odyssey Items
	- Primes included
  - Body.csv(Body Pieces)
    - Level One gear is at the top now. Think Lockstyles.
	- Added Odyssey Body Gear