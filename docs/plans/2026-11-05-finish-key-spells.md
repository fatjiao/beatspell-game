# Finish-Key Spells Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace fixed four-beat phrase expiry with immediately resolved, variable-length spell rhythms while preserving the continuous global ring.

**Architecture:** A pure `SpellCommandBuffer` quantizes step and finish inputs to a whole-beat grid and recognizes a command only when the finish key is pressed. The battle scene owns presentation and effects, while the command buffer returns completed events with absolute ring positions for drawing.

**Tech Stack:** Godot 4.7, GDScript, script-based unit tests, custom `_draw()` UI.

---

### Task 1: Build the command parser

**Files:**
- Create: `scripts/beatspell/spell_command_buffer.gd`
- Create: `tests/test_spell_command_buffer.gd`
- Modify: `tests/run_tests.gd`

1. Write failing tests for two-beat FLARE, three-beat MEND, invalid starts, failed finishes, absolute ring phase, and timing grades.
2. Run the full suite and confirm the new parser is missing.
3. Implement whole-beat quantization and finish-key matching.
4. Rerun the full suite and confirm all tests pass.

### Task 2: Replace the fixed phrase lifecycle

**Files:**
- Modify: `scripts/beatspell/beatspell_battle.gd`

1. Replace `RollingPhrase` scene state with `SpellCommandBuffer`.
2. Route `D/F` to step registration.
3. Route `J/K` to immediate command completion.
4. Preserve completed command events briefly for visual feedback.
5. Remove automatic four-beat phrase resolution from the scene loop.

### Task 3: Update progression and presentation

**Files:**
- Modify: `scripts/beatspell/battle_director.gd`
- Modify: `tests/test_battle_director.gd`
- Modify: `scripts/beatspell/beatspell_battle.gd`
- Modify: `tests/capture_beatspell_preview.gd`

1. Teach FLARE first and MEND second; stop teaching the unused shield spell.
2. Draw command positions on the four whole-beat corners of the continuous ring.
3. Replace three fixed-width cards with two readable rhythm cards.
4. Capture active three-beat MEND and Boss warning states for visual review.

### Task 4: Verify and document

**Files:**
- Modify: `README.md`

1. Document finish-key resolution and whole-beat input.
2. Run all unit tests.
3. Smoke-test the main scene and calibration scene.
4. Inspect generated screenshots and commit the change.
