# Beatspell Progression Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Turn the playable boss prototype into a readable 90-second slice with a quiet onboarding sequence, escalating boss phases, and distinct spell feedback.

**Architecture:** Add a pure `BattleDirector` rules object beside the existing matcher and battle model. The scene caches the phase selected at each bar boundary so the attack warning can never change after the player has already started a phrase. Presentation reads the director state but does not own progression rules.

**Tech Stack:** Godot 4.7, GDScript, custom `_draw()` presentation, lightweight script-based tests.

### Task 1: Define progression rules with tests

**Files:**
- Create: `scripts/beatspell/battle_director.gd`
- Create: `tests/test_battle_director.gd`
- Modify: `tests/run_tests.gd`

1. Write failing tests for tutorial skill windows, health-based phases, attack schedules, and phase damage.
2. Run the suite and confirm the missing director fails.
3. Implement the smallest pure rules object that satisfies the tests.
4. Run the full test suite.

### Task 2: Integrate progression into the battle scene

**Files:**
- Modify: `scripts/beatspell/beatspell_battle.gd`

1. Cache the active phase at the start of each bar.
2. Resolve attacks using the cached phase and phase damage.
3. Keep the first six bars safe and use them to highlight one spell card at a time.
4. Announce phase changes briefly without obscuring the playfield.

### Task 3: Improve spell and attack presentation

**Files:**
- Modify: `scripts/beatspell/beatspell_battle.gd`

1. Draw a travelling fire projectile during FLARE.
2. Draw rotating shield runes during AEGIS.
3. Draw rising particles during MEND.
4. Draw a directional slash during a boss strike.

### Task 4: Verify and document

**Files:**
- Modify: `tests/capture_beatspell_preview.gd`
- Modify: `README.md`

1. Capture tutorial, high-pressure warning, and result states.
2. Inspect the images at full size for overlaps and readability.
3. Run all tests and headless scene smoke checks.
4. Commit the progression pass.
