# 🔬 FFXI DAT Explorer Laboratory

Welcome to the **DatAnalysis** suite. 

Final Fantasy XI contains over 100,000 `.dat` files on your local hard drive. These files have no file extensions (like `.png` or `.mp3`) and no human-readable names. Community tools like AltanaViewer rely on `.csv` lists to map these raw numerical folders (e.g., `ROM/68/76.DAT`) to visual 3D models (e.g., `Hume Male - Basic Attack`).

This directory contains a suite of automated Windows PowerShell scripts designed to extract, reverse-engineer, cross-reference, and map the thousands of expansion files that the community missed.

---

## ⚠️ Prerequisites
* **Windows PowerShell 5.1:** This suite relies heavily on reading raw Hexadecimal bytes. Do **NOT** run these scripts in modern PowerShell Core (PS6+), as the way the `-Encoding Byte` command is handled was fundamentally changed and will break the hex parsers.
* **Local FFXI Installation:** You must have the game installed on your PC. The scripts will automatically search your Windows Registry to find your installation path.

---

## 📂 The Laboratory Layout (Phases 1-4)

The scripts are broken down into four distinct phases. For a complete mapping run, you should progress through the folders sequentially.

### 📁 1_Core_Pipeline (Extraction & Verification)
These scripts form the foundation of the laboratory. They analyze what AltanaViewer *already* knows, and scan your hard drive to find out what is missing.

* **`Find-UnmappedDATs.ps1`**
  * **What it does:** Scans every `Action.csv` and `Motion.csv` in AltanaViewer's `List` folder to build a Master Hash Table of known files. It then scans your entire FFXI installation directory and subtracts the known files.
  * **Output:** Generates `FFXI_Unmapped_Local_DATs.txt` — a massive target list of every FFXI file (~18,000+) that currently has no visual mapping.
* **`Run-FFXIDatPipeline.ps1`**
  * **What it does:** The master automation script. Simply run this script, and it will automatically execute `Find-UnmappedDATs.ps1` and seamlessly pass the results into the Phase 2 Hex Exploration scripts. 

### 📁 2_Hex_Exploration (The Detective Work)
Because `.dat` files lack standard extensions, we must read the internal code of the files to figure out what they are.

* **`SignatureReport-UnmappedDATs.ps1`**
  * **What it does:** Opens all 18,000+ unknown files and extracts their first 4 bytes (the "Magic Number"). It groups files by their signatures (e.g., `mot_` for animations, `sqle` for sound effects).
* **`RosettaStone-UnmappedDATs.ps1`**
  * **What it does:** Cross-references the Magic Numbers of our *unknown* files against the Magic Numbers of our *known* files to make intelligent developer guesses about what category unmapped files belong to.
* **`Analyze-MotionHeaders.ps1`**
  * **What it does:** Performs deep 32-byte hex inspection on known animation files to locate Byte 19. Byte 19 is the FFXI engine's "Skeleton ID" (e.g., `A0` means Humanoid, `18` means Chocobo).
* **`Sort-MotionsBySkeleton.ps1`**
  * **What it does:** Reads Byte 19 of every unknown animation file and groups them by their physical skeleton. This prevents the viewer from crashing or models from "exploding" when the wrong animation is applied to a model.
* **`Profile-A0-Motions.ps1`**
  * **What it does:** Because `A0` is a shared humanoid skeleton (used by Humes, Elvaan, Tarutaru, etc.), this script uses "Guilt by Association" folder-profiling logic to figure out exactly which race a generic `A0` animation actually belongs to.

### 📁 3_Altana_Test_Blocks (The Sandbox)
Once we have grouped unknown files together, we need to view them. These scripts generate copy-pasteable UI code for AltanaViewer.

* **`Generate-TestCSV.ps1`**
  * **What it does:** Prompts you for a 4-byte Hex Signature (e.g., `6D 6F 74 5F`). It scoops up all unknown files matching that signature and formats them into an AltanaViewer-ready CSV block.
* **`Generate-SkeletonTestCSV.ps1`**
  * **What it does:** Prompts you for a 2-byte Skeleton ID (e.g., `A0`). It formats all unknown files matching that skeleton into an AltanaViewer-ready CSV block.
  * **How to use:** Open the generated `AltanaViewer_AutoTest_Block.csv`, copy the contents, paste them to the bottom of any character's `Action.csv`, and launch AltanaViewer to instantly play the unknown animations.

### 📁 4_XIData_Tools (The Precision Pivot)
Rather than guessing what a file is via hex inspection, this final phase cross-references our missing files against precise JSON database dumps from the FFXI Client (provided by the `vekien/xidata` project).

* **`Parse-XIDataJSON.ps1`**
  * **What it does:** Prompts the user to select a single JSON developer database (e.g., `anims_hume_male.json`). It cross-references our master list of missing DATs against this JSON to extract the exact developer names for the missing animations.
* **`Parse-BulkXIData.ps1`**
  * **What it does:** The nuclear option. Prompts the user to select the entire `xidata-v2-py/data/` folder. It aggressively scans all 18,000 missing files against the entire game database in one go.
  * **Output:** Generates `XIData_Bulk_Mapped_Results.csv`, instantly recovering and perfectly categorizing hundreds of missing armor pieces, zones, monsters, and animations into ready-to-paste UI blocks.

---

## 🚀 How to Run the Laboratory (Recommended Workflow)

If you are starting from scratch or wish to update the viewer with new game files:

1. **Extract Base Data:** Navigate to `1_Core_Pipeline` and right-click -> **Run with PowerShell** on `Run-FFXIDatPipeline.ps1`. Allow the script a few minutes to sanitize your lists and generate the hex signature reports.
2. **Execute Bulk Recovery:** Navigate to `4_XIData_Tools` and run `Parse-BulkXIData.ps1`. Point the prompt to your local `xidata` JSON folder.
3. **Upgrade AltanaViewer:** Open the resulting `XIData_Bulk_Mapped_Results.csv`. Copy the newly recovered, perfectly named asset blocks and paste them into their respective `.csv` files inside the root `List/` directory.
4. **Sandbox Exploration:** If you want to manually look at files that the JSON databases couldn't identify, navigate to `3_Altana_Test_Blocks`, run the generator scripts, and paste the output into AltanaViewer to view the raw 3D geometry yourself!