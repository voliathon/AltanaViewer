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

## 🎵 The Missing Music: Why Post-Promathia Audio Fails

**Notice:** You may notice that music from the Original game, *Rise of the Zilart*, and *Chains of Promathia* plays perfectly, but tracks from *Treasures of Aht Urhgan* (`sound4`) and beyond result in silence.

This is not a bug with the folder directories or the CSV lists—it is a **codec limitation** hardcoded into the original executable.

* **The Old Codec (ADPCM):** The `sound`, `sound2`, and `sound3` folders use `.bgw` files that contain audio compressed in a proprietary ADPCM format. Altana Viewer has a built-in decoder specifically written to play this exact format.
* **The New Codec (ATRAC3):** Starting with `sound4`, Square Enix shifted to Sony's ATRAC3 audio compression to save space. They kept the exact same `.bgw` file wrapper, meaning Altana Viewer recognizes the file but tries (and fails) to feed the new ATRAC3 data into its old ADPCM decoder.

**Future Plans:** The application logic is fully capable of reading from the newer sound folders. Options to fix this issue are currently being explored, including reverse-engineering the executable to hook into modern audio libraries (like vgmstream) or patching the file-loading routines to accept converted `.wav` files.

## Current Work and Road map
* [COMPLETED] Perform Copyedits (Checking consistency and accuracy then editing) against ALL files first
* [COMPLETED] Move all Level 1 equipment to the top of each list
* [COMPLETED] Level 1 equipment will be ordered based on its FFXI Release
* [COMPLETED] Implement known dat locations up until mid-2024 (This includes Odyssey gear)
* [ ] Identify anything and everything gear past mid-2024 and implement **At this point Altana Viewer will be done with Gear up until 2026**
* [ ] Identify missing mounts and implement
* [ ] Identify missing furniture and implement
* [ ] Identify further NPC stuff
* [COMPLETED] Figure out why the Music doesn't work post a certain expansion
* [ ] Figure out animations further... maybe... That's a lot of work.

## 2026 Change Log
<!-- START_LOG -->
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