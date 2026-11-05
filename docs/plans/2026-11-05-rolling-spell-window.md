# Rolling Spell Window Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Let the player begin a four-beat spell on any musical beat instead of waiting for the global bar downbeat.

**Architecture:** A pure `RollingPhrase` object owns the first-input anchor beat, relative input slots, and expiry. The battle scene advances player phrases and Boss bars on separate clocks; phrase completion is processed before a simultaneous Boss strike so a just-completed shield remains useful.

**Tech Stack:** Godot 4.7, GDScript, script-based unit tests, custom `_draw()` UI.

---

### Task 1: Add the rolling phrase model

**Files:**
- Create: `scripts/beatspell/rolling_phrase.gd`
- Create: `tests/test_rolling_phrase.gd`
- Modify: `tests/run_tests.gd`

1. Write tests proving the first valid input anchors slot zero at an arbitrary global beat.
2. Test later inputs as relative slots and expiry exactly four beats later.
3. Test duplicate and off-pulse input handling.
4. Run the test suite and confirm the new test initially fails.
5. Implement the minimal pure model and rerun all tests.

### Task 2: Decouple player and Boss timelines

**Files:**
- Modify: `scripts/beatspell/beatspell_battle.gd`

1. Replace bar-owned phrase arrays with `RollingPhrase` state.
2. Resolve an expired phrase independently from `_update_bar()`.
3. Keep Boss attacks tied to global bars.
4. Resolve a phrase before a Boss strike when both occur on the same frame.
5. Allow an input on the completion beat to resolve the old phrase and immediately anchor a new one.

### Task 3: Redraw the beat ring

**Files:**
- Modify: `scripts/beatspell/beatspell_battle.gd`
- Modify: `tests/capture_beatspell_preview.gd`

1. Keep the outer four-position ring locked to the global song clock.
2. Store each input's absolute ring position separately from its relative spell slot.
3. Never restart the outer cursor when a phrase begins or resolves.
4. Capture active rolling and Boss-warning states for visual review.

### Task 4: Document and verify

**Files:**
- Modify: `README.md`

1. Document the rolling start rule.
2. Run every unit test.
3. Smoke-test the main and calibration scenes.
4. Inspect the generated preview and commit the change.
