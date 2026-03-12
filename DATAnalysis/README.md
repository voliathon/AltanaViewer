# FFXI DAT Explorer & Rosetta Stone

A suite of PowerShell tools designed to clean community-driven AltanaViewer data, cross-reference it with a local Final Fantasy XI installation, and reverse-engineer unmapped `.dat` files using hex header inspection.

## 🚀 Overview

Final Fantasy XI has over 100,000 `.dat` files organized in various `ROM` folders. Community tools like AltanaViewer map these files to 3D models and equipment using CSV lists. However, these lists are often incomplete, inconsistently formatted, or contain errors. 

This project solves that by:
1. **Sanitizing** messy community CSV data into a clean, uniform format.
2. **Cross-Referencing** the clean data against a local FFXI installation using high-speed Hash Tables.
3. **Isolating** files that exist on the hard drive but are missing from AltanaViewer.
4. **Reverse-Engineering** the unknown files by inspecting their 4-byte Hexadecimal "Magic Numbers" to categorize them.

## 🛠️ The Pipeline

### Phase 1: Data Sanitization & Local Cross-Checking (`Find-UnmappedDATs.ps1`)
Community CSV files contain heavy shorthand and formatting quirks. This script parses the `AltanaViewer` folder, applies strict formatting rules (expanding semicolons, standardizing `ROM#/Folder/File` paths), and quarantines broken entries. It then locates the local FFXI install directory via the Windows Registry and performs an instantaneous `O(1)` Hash Table lookup against the local hard drive.

**Outputs:**
* `AltanaViewer_CleanedData.txt` - The pure, verified master list.
* `AltanaViewer_UncertainData.txt` - The quarantine list of unparsed/messy data.
* `FFXI_Unmapped_Local_DATs.txt` - A complete list of local `.dat` files missing from AltanaViewer.

### Phase 2: Hex Signature Profiling (`SignatureReport-UnmappedDATs.ps1`)
To identify the unmapped files without a 3D viewer, this script quietly opens every *unknown* file and extracts the first 4 bytes (the Hex Signature) using `-Encoding Byte` (Windows PowerShell 5.1 compatible). It then groups thousands of unknown files by their signature to establish foundational profiles.

**Output:**
* `FFXI_Unknown_Signatures.txt` - A breakdown of unmapped files grouped strictly by their magic numbers.

### Phase 3: The Rosetta Stone (`RosettaStone-UnmappedDATs.ps1`)
The final script builds the translation matrix. It reads the 4-byte headers of *known* files mapped in Phase 1 to link signatures to AltanaViewer categories (e.g., `Head.csv`, `Main.csv`). It then cross-references the unknown signatures from Phase 2 against this dictionary, applying developer guesses and translating readable ASCII tags (like `mot_` for Motion files).

**Output:**
* `FFXI_Rosetta_Signatures.txt` - A comprehensive report grouping unknown `.dat` files by their magic numbers, complete with file lists, developer guesses, and AltanaViewer category matches.

## 📋 Requirements
* **Windows PowerShell 5.1** (Required for `-Encoding Byte` file reading).
* A local installation of **FINAL FANTASY XI**.
* An **AltanaViewer** folder containing the community `.csv` lists.

## ⚙️ Usage

**The Automated Way (Recommended):**
1. Place all scripts in the same folder.
2. Run `Run-FFXIDatPipeline.ps1`.
3. Select your `AltanaViewer` folder when prompted. The master script will sequentially execute all three phases automatically.

**The Manual Way:**
If you prefer to run the tools individually, execute them in this strict order:
1. Run `Find-UnmappedDATs.ps1`
2. Run `SignatureReport-UnmappedDATs.ps1`
3. Run `RosettaStone-UnmappedDATs.ps1`

*(Note: If your FFXI installation cannot be found automatically via the Windows Registry, you will be prompted to select your installation folder manually during execution).*