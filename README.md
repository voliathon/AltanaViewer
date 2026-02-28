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
<!-- START_LOG -->
- Mithra/Body.csv - Copyedited and moved position of level one lockstyles based on when implemented in FFXI (Feb-28-2026)
- Full Update & Copyediting - All Feet Files - No New Limbus Gear Added Yet (Feb-28-2026)
- Copyediting - All Mithra Files, All Head Files, HumeF Body, & HumeM Body. Some Ark Angel lockstyles (Feb-28-2026)
- Mithra/Hands.csv - Full Update to Hand Equipment - No 2025/2026 Limbus Gear, Clarity to Unobtainable gear (Feb-27-2026)
- Mithra/Body.csv - Identified Hebenus Top (Feb-27-2026)
- Mithra/Legs.csv - Identified Nanaa Mihgo's Pantsu (Feb-27-2026)
- Mithra/Legs.csv - Identified Hebenus Shorts (Feb-27-2026)
- Mithra/Body.csv - Copyediting (Feb-26-2026)
- Mithra/Head.csv - Copyediting (Feb-26-2026)
- Mithra/Legs.csv - Full Update to Legs Equipment - No 2025/2026 Limbus Gear (Feb-26-2026)
- README.md - Corrections to Change Log Notes prior to Automation (Feb-26-2026)
- HumeF/Face.csv - New Faces and Corrections (Feb-26-2026)
- HumeM/Face.csv - New Faces and Corrections (Feb-26-2026)
- ElvaanF/Face.csv - New Faces and Corrections (Feb-26-2026)
- ElvaanM/Face.csv - New Faces and Corrections (Feb-26-2026)
- Galka/Face.csv - New Faces and Corrections (Feb-26-2026) 
- Mithra/Face.csv - New Faces and Corrections (Feb-26-2026)
- Tarutaru/Face.csv - New Faces and Corrections (Feb-26-2026)
- Mithra/Head.csv - Full Update to Head Equipment - No 2025/2026 Limbus Gear (Feb-26-2026)
- Mithra/Main.csv - Full Update to Weapons including Prime Weapons (Feb-26-2026)
- Mithra/Sub.csv - Full Update to Sub Seapons and Shields including Prime Shield (Feb-20-2026) 
- Mithra/Action.csv - Animations are now alphabatized(Feb-20-2026)
- Mithra/Range.csv - Full Update to Range Everything. Primes Included. Un-Implemented .DAT files shown (Feb-20-2026)
- Mithra/Body.csv - Full Update to Body Equipment. No 2025/2026 Limbus Gear (Feb-20-2026)
- Creation of Repo (Feb-20-2026)
