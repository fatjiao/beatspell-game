# Fixed-Key Stage Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the four-instrument interaction readable through permanent spatial mapping and subtle stage-integrated light cues.

**Architecture:** Keep the existing timing, chart, stage-section, audio, result, and debug systems. Replace the single moving pulse rail with four small fixed floor lights and derive a deterministic brightness value from the next event's remaining time.

**Tech Stack:** Godot 4.7, GDScript, CanvasItem drawing, existing chart and audio assets.

---

### Task 1: Test the cue timing model

**Files:**
- Modify: `tests/test_stage_director.gd`
- Modify: `scripts/presentation/stage_director.gd`

**Steps:**
1. Add failing expectations for cue progress at 1000, 500, and 0 milliseconds.
2. Run tests and confirm the new method is missing.
3. Implement a clamped zero-to-one cue progress function.
4. Run tests and confirm the stage-director suite passes.

### Task 2: Replace the moving rail with subtle fixed floor lights

**Files:**
- Modify: `scripts/prototype/prototype_stage.gd`

**Steps:**
1. Center Loop and retain instrument-specific performance props.
2. Draw D/F/J/K at permanent left-to-right positions.
3. Dim inactive lights and brighten only the floor area for the next required key.
4. Move hit feedback to a short floor glow at the corresponding fixed position.
5. Remove the moving pulse, numbered rail, large key circles, instrument labels, and changing right-side target.

### Task 3: Verify all states

**Files:**
- Modify: `tests/capture_feedback_preview.gd`
- Modify: `README.md`

**Steps:**
1. Capture a single-instrument section and final ensemble section.
2. Confirm all four anchors remain in identical positions between captures.
3. Confirm letter labels remain readable without relying on color.
4. Run all tests and a main-scene smoke launch.
5. Commit the verified correction.
