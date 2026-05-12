# Implementation Plan: Milestones, Breakthroughs, and Project Cleanup

## Objective
Fully integrate the Breakthrough system so it interacts with Anomalies and Mysteries, apply its effects globally, and display it in the Tech Tree. Expand the Milestones system using Surviving Mars references. Perform a massive cleanup of the project: fixing UIDs across all Godot resources, adding comprehensive comments to scripts, and moving documentation to a clean folder structure.

## Phase 1: Breakthrough Integration & Tech Tree
- **Logic (`MissionManager.gd` & `EconomyManager.gd`):**
  - Implement the actual application of Breakthrough effects (e.g., modifying production multipliers, reducing costs).
  - Add logic so completing certain future Mysteries also grants Breakthroughs.
- **UI (`TechnologyTree.gd`):**
  - Add a dedicated section (e.g., a bottom row) in the Tech Tree to display unlocked Breakthroughs.
  - Breakthrough nodes will not be clickable to "research" (as they cost 0 and are unlocked instantly), but will serve as a visual record.

## Phase 2: Milestones Expansion (`milestones.md` & `MissionManager.gd`)
- Add Surviving Mars-inspired milestones:
  - *Founder Stage:* Gather 1st Water, Oxygen, Power.
  - *Expansion:* Reach 100 Colonists (Later to be added), Build First Dome (Later to be added).
  - *Terraforming:* Reach specific % thresholds.
- Create `milestones.md` documentation detailing these.

## Phase 3: Project Cleanup & UID Stabilization (Action Turn Priority)
- Scan all `.tscn`, `.tres`, and `.gd` files for missing or conflicting UIDs.
- Generate valid Godot 4 UIDs (e.g., `uid://...`) for resources missing them to prevent engine crashes.
- Add descriptive Godot 4-style comments to core scripts (`EconomyManager.gd`, `BuildingManager.gd`, `SaveManager.gd`, etc.), explaining signals and data flow.
- Organize root `.md` files by moving them into the appropriate documentation/memory folders to keep the root clean.

## Verification
- Anomalies should grant a Breakthrough, which immediately appears in the Tech Tree and applies its buff.
- The project should open in the Godot Editor without any UID or parsing errors.
