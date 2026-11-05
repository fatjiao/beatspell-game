# Single-Focus Stage Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the persistent four-pad HUD with a cinematic, single-focus rhythm interaction inspired by Rhythm Doctor while preserving the game's four-instrument identity.

**Architecture:** Keep chart loading, audio playback, timing judgement, scoring, calibration, and debug tracks unchanged. Add a pure `StageDirector` that maps song time to presentation sections; the prototype scene consumes that state to draw one pulse rail, one active key target, section transitions, and instrument-specific environmental feedback.

**Tech Stack:** Godot 4.7, GDScript, CanvasItem procedural drawing, existing PNG/OGG assets, headless GDScript tests.

---

### Task 1: Add deterministic stage direction

**Files:**
- Create: `scripts/presentation/stage_director.gd`
- Create: `tests/test_stage_director.gd`
- Modify: `tests/run_tests.gd`

**Steps:**
1. Write tests for the drums, bass, synth, lead, and ensemble boundaries.
2. Run the test suite and verify the new suite fails because the director is missing.
3. Implement `section_at(time_ms)` with explicit section metadata.
4. Run the suite and verify all tests pass.

### Task 2: Replace the persistent pad HUD

**Files:**
- Modify: `scripts/prototype/prototype_stage.gd`

**Steps:**
1. Preload and instantiate `StageDirector`.
2. Track section changes and a short transition-card window.
3. Replace the normal HUD with a full-stage layout containing a minimal progress header, a single pulse rail, beat counts, and one large active-key target.
4. Keep the existing four-lane interface available only through `Tab` debug mode.
5. Run the main scene headlessly and verify there are no parser or runtime errors.

### Task 3: Integrate input feedback into the scene

**Files:**
- Modify: `scripts/prototype/prototype_stage.gd`

**Steps:**
1. Move Loop to the left side of the pulse rail and convert instrument overlays to relative coordinates.
2. Add environment reactions: drum floor ripples, bass low glow, synth light beams, lead audience response.
3. Add successful-hit bursts and brief chromatic displacement for misses.
4. Preserve pause, retry, calibration, result card, and audio-layer behavior.

### Task 4: Verify visual states and documentation

**Files:**
- Modify: `tests/capture_feedback_preview.gd`
- Modify: `README.md`

**Steps:**
1. Capture the active-instrument and final-ensemble states at 1280×720.
2. Inspect focus hierarchy, text legibility, target visibility, and overlap.
3. Run all headless tests plus a main-scene smoke run.
4. Update controls and interaction description.
5. Commit the verified implementation.
