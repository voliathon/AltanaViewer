<p align="center">
  <img src="./AltanaViewerOrig.png" alt="Altana Viewer" width="800">
</p>

AltanaViewer is a dedicated 3D model and asset viewer for Final Fantasy XI (FFXI). It allows users to explore the game's extensive catalog of player characters, monsters, equipment, animations, and visual effects outside of the game client.

## Features

* **Player Character Viewer:** View all playable races (Hume, Elvaan, Tarutaru, Mithra, and Galka).
* **Equipment Dressing:** Mix and match armor, weapons, and accessories across all visual equipment slots (Head, Body, Hands, Legs, Feet, Main, Sub).
* **NPC & Monster Bestiary:** Browse through the game's vast array of enemies and NPCs, categorized by ecosystem family (e.g., Aquans, Beastmen, Dragons) and expansion content.
* **Animation & Effects Playback:** View weapon skills, magic casting effects (White Magic, Black Magic, Ninjutsu, etc.), and standard character motions.
* **Asset Mapping:** Comprehensive CSV lists that map raw game DAT files to human-readable names.

## History & Origins

The original Altana Viewer was created around 2006 by an anonymous Japanese developer (often associated with the copyright "Tiamat"). It was built upon the foundation of an older Japanese model viewer known as `FFXITool`. Both programs were unique at the time for being able to decipher and play back FFXI's complex effect animations.

Because the original author disappeared and the software was never made open-source, the community has never been able to update the core application engine. The viewer is kept alive for modern FFXI updates by Voliathon at this repository. I will accept Pull Requests. I manually update the extensive CSV dictionary lists to map new DAT files as Square Enix adds them to the game.

## Directory Structure

The repository is organized to neatly categorize the massive amount of FFXI game data:

* `AltanaView.exe` - The main executable application.
* `DATAnalysis/` - PowerShell tools for sanitizing CSV data and reverse-engineering unmapped FFXI `.dat` files via hex headers.
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

### 🎵 A Note on Music Playback

You may have noticed that the built-in audio player in AltanaViewer can be buggy or unstable. Because AltanaViewer was built primarily as a 3D model viewer, optimizing the audio engine was difficult. 

**If you are looking to listen to the FFXI soundtrack, I highly recommend downloading my new, dedicated tool: [AltanaListener](https://github.com/voliathon/AltanaListener).** AltanaListener is a completely open-source, highly stable audio player built from the ground up specifically for FFXI `.bgw` files, featuring custom playlists, favorites, and WAV file exporting!


### 🧠 Understanding the Animation Engine: Action.csv vs. Motion.csv

When dealing with playable characters and monsters, AltanaViewer handles animations using two completely different files that talk to each other.

**1. `Action.csv` (The User Interface)**
This file defines what the user sees in the AltanaViewer dropdown menus. It is a strict 1-to-1 mapping. 
* *Format:* `[Folder/File],[UI Name]` (e.g., `206/106,Ascetic's Fury`)
* When you click "Ascetic's Fury" in the UI, the engine looks at this file and triggers the starting animation `.dat`. 

**2. `Motion.csv` (The Skeleton Engine)**
This file is invisible to the user. It teaches the 3D engine how to *chain* animations together so the character does not freeze after a movement. 
* *Format:* `[Start Block], [Next Block]` (e.g., `56/14-22, 56/23-40`)
* Final Fantasy XI rarely uses one file for a continuous movement. Drawing a weapon involves a transition animation, followed by an infinite idle loop. `Motion.csv` tells the engine: *"As soon as the animation block 56/14-22 finishes, seamlessly transition into the loop block 56/23-40."*

**The "Test" Override:** If you want to view a hidden engine animation from `Motion.csv` in the actual UI, you can append a name to it (e.g., `209/39,test #244`). This forces AltanaViewer to bypass the chaining logic and expose the raw file directly in the Action dropdown.

## 🎵 The Missing Music: Why Post-Promathia Audio Fails

**Notice:** You may notice that music from the Original game, *Rise of the Zilart*, and *Chains of Promathia* plays perfectly, but tracks from *Treasures of Aht Urhgan* (`sound4`) and beyond result in silence.

This is not a bug with the folder directories or the CSV lists—it is a **codec limitation** hardcoded into the original executable.

* **The Old Codec (ADPCM):** The `sound`, `sound2`, and `sound3` folders use `.bgw` files that contain audio compressed in a proprietary ADPCM format. Altana Viewer has a built-in decoder specifically written to play this exact format.
* **The New Codec (ATRAC3):** Starting with `sound4`, Square Enix shifted to Sony's ATRAC3 audio compression to save space. They kept the exact same `.bgw` file wrapper, meaning Altana Viewer recognizes the file but tries (and fails) to feed the new ATRAC3 data into its old ADPCM decoder.

[AltanaListener](https://github.com/voliathon/AltanaListener) was created to address this problem and do a better job.

## Current Work and Road map
* [WIP] Add missing Ranged Weapons and Instruments
* [WIP] Identify further NPC related stuff. This includes monsters, npcs, mounts, zone items, and more.
* [WIP] Identify missings Effects. This includes spells and prime weaponskills
* [COMPLETED] All Head, Body, Hands, Legs, Feet added up to Mar-10-2026. (New Limbus Gear included)
* [COMPLETED] Figured out why the Music doesn't work post a certain expansion and release Altana Listener to solve issue.
* [COMPLETED] All Main Weapons added up to March-10-2026
* [COMPLETED] All Sub Weapons and Shields added up to March-10-2026

## 2026 Change Log
<!-- START_LOG -->
- Overhaul to NPC Section & Added Effects - Easier to find stuff (Mar-17-2026)
- Removed deprecated WS.csv & added NPC & Effects (Mar-16-2026)
- Effect/Explosion.csv - Created (Mar-16-2026)
- Effect.csv - Loads Added. Chocobo Clubs Sorted. Blue Magic Spells added. Backed up PC. (Mar-16-2026)
- Added Chocobo Racing Section (Mar-15-2026)
- NPC Additions - Sortie, Misc TVR, and Chaos (Mar-15-2026)
- All Sub.csv - Fully Updated (Mar-15-2026)
- Main.csv & Sub.csv - Added Kyukoto (Mar-14-2026)
- All NPC.csv - Large Additions and Copyedits ordering .dats based on implementation (Mar-14-2026)
- Action.csv - Added More Animations for HumeM, HumeF, Mithra, and Galka (Mar-14-2026)
- Sub.csv - Mithra order was corrected based on .dat # / Release (Mar-12-2026)
- Sub.csv - HumeM Sub Done Entirely with a Jushimatsu fixes to Mains. (Mar-12-2026)
- res/ - Section Added Back (Mar-12-2026)
- DATAnalysis Section - Added Powershell Scripts (Mar-12-2026)
- All Main.csv & Sub.csv - Badrod has been updated to Budrod (Mar-11-2026)
- Revise roadmap and change log details (Mar-10-2026)
- All Main Weapons Done. This includes Badrod that released March 2026 (Mar-10-2026)
- All Main.csv - Updated all Odyssey Weapons and organized all weapons based on release(Mar-10-2026)
- All Main.csv - Updated all Pre-Odyssey Weapons (Mar-09-2026)
- Music/ & Main.csv files- Corrections to Music and Pre-aligning updates to main weapons (Mar-08-2026)
- Music/ - All Music Updated (Mar-08-2026)
- NPC/ - Spelling corrections (Mar-06-2026)
- Image/Maps/System UI Overhaul - Entire Copyedit and Alphabatize (Mar-05-2026)
- AltanaView.ini - Added Back... (Mar-05-2026)
- NPC/automaton.csv - Fixed this and added it to the NPC/ (Mar-05-2026)
- NPC/limbus.csv - Created with Forerunner Mobs (Mar-05-2026)
- NPC/mounts.csv - Crakclaw, Alicorn, Bubble Crab Companions added (Mar-05-2026)
- All Equipment and Races - All Limbus and current Login Campaign Equipment Implemented. (Mar-05-2026)
- Added Seperators to Lv1/Lockstyle Gear - All Files. Finished Sin Gear (Mar-04-2026)
- Added Original HQ Image & left Gemini Pro Watermark on purpose (Mar-04-2026)
- Sin Gear - All races got Arrogance, Cowardice, and Envy equip (Mar-04-2026)
- Updates to README - Credit & Special Thanks. Music Notice (Mar-03-2026)
- Massive Copyedits - Hand Gear done up until Sin Sets (Mar-03-2026)
- Massive Copyedits - Leg Gear done up until Sin Sets (Mar-02-2026)
- Massive Copyedits - Head Gear done up until Sin Sets (Mar-01-2026)
- Full Update & Copyediting - All Body files up until Mid-2024 (Mar-01-2026)
- Mithra/Body.csv - Copyedited and moved position of level one lockstyles based on when implemented in FFXI (Feb-28-2026)
- Full Update & Copyediting - All Feet files up until Mid-2024 (Feb-28-2026)
- Copyediting - All Mithra files up until Mid-2024 (Feb-28-2026)
- Mithra/Hands.csv - Full Update to Hand Equipment files up until Mid-2024, Clarity to Unobtainable gear (Feb-27-2026)
- Mithra/Body.csv - Identified Hebenus Top (Feb-27-2026)
- Mithra/Legs.csv - Identified Nanaa Mihgo's Pantsu (Feb-27-2026)
- Mithra/Legs.csv - Identified Hebenus Shorts (Feb-27-2026)
- Mithra/Body.csv - Copyediting (Feb-26-2026)
- Mithra/Head.csv - Copyediting (Feb-26-2026)
- Mithra/Legs.csv - Full Update to Legs Equipment files up until Mid-2024 (Feb-26-2026)
- README.md - Corrections to Change Log Notes prior to Automation (Feb-26-2026)
- HumeF/Face.csv - New Faces and Corrections (Feb-26-2026)
- HumeM/Face.csv - New Faces and Corrections (Feb-26-2026)
- ElvaanF/Face.csv - New Faces and Corrections (Feb-26-2026)
- ElvaanM/Face.csv - New Faces and Corrections (Feb-26-2026)
- Galka/Face.csv - New Faces and Corrections (Feb-26-2026)
- Mithra/Face.csv - New Faces and Corrections (Feb-26-2026)
- Tarutaru/Face.csv - New Faces and Corrections (Feb-26-2026)
- Mithra/Head.csv - Full Update to Head Equipment files up until Mid-2024 (Feb-26-2026)
- Mithra/Main.csv - Full Update to Weapons including Prime Weapons (Feb-26-2026)
- Mithra/Sub.csv - Full Update to Off-Handed Weapons and Shields including Prime Shield (Feb-20-2026)
- Mithra/Action.csv - Animations are now alphabatized(Feb-20-2026)
- Mithra/Range.csv - Full Update to Range Everything. Primes Included. Un-Implemented .DAT files shown (Feb-20-2026)
- Mithra/Body.csv - Full Update to Body Equipment files up until Mid-2024 (Feb-20-2026)
- Creation of Repo (Feb-20-2026)

---


## Contributing

Because Final Fantasy XI continues to receive updates, the CSV lists require periodic maintenance to include newly added armor, weapons, and monster models. If you are updating the lists, please ensure you place the new item IDs and DAT mappings in their respective CSV files within the `List/` directory.

## Credits & Special Thanks

While the original author's identity remains a mystery, the following individuals and groups have been instrumental in the maintenance and evolution of Altana Viewer:

* **Tiamat (Anonymous Japanese Developer):** The original creator who developed the application around 2006.
* **Original FFXITool Author:** An anonymous programmer whose legacy software served as the initial foundation.
* **Krizz:** Maintained and shared vital model and item list updates for many years.
* **mynameisgonz (Batcher of Asura):** Provided significant updates in 2020, recategorizing NPCs and gear lists.
* **CAProjects & SpicyRyan:** Maintained public repositories and updated lists through late 2022, including Odyssey data.
* **vekien (Josh Freeman):** Contributed to the development of FFXI model viewing repositories.
* **Fenrir.Nightfyre & PeterNorth:** Shared updated mappings on community forums throughout the early 2010s.
* **The FFXI Player Community:** Countless anonymous contributors who manually scraped DAT IDs to provide CSV mappings after game updates.
* **Current Maintainer:** Voliathon — responsible for modern repository hosting and manual CSV updates through 2026.
* **Final Fantasy XI:** All assets and designs are property of Square Enix.

> "To any developer, DAT-miner, or community member who contributed to this project over the last 20 years whose name may not appear on this list: please accept our sincerest apologies. Your hard work in documenting the world of Vana'diel has not gone unnoticed, and we are deeply grateful for your dedication to the community."


---
### 🛠️ Other Projects by Voliathon

If you enjoy AltanaViewer, check out my other Final Fantasy XI utilities:

* **[AltanaListener](https://github.com/voliathon/AltanaListener):** The ultimate, open-source FFXI audio player. It automatically finds your local installation and lets you build custom playlists, loop tracks, and export FFXI music directly to `.wav` files with a modern, stable UI.

