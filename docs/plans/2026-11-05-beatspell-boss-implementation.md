# Beatspell Boss Demo Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a playable 90-second rhythm-spell Boss battle and make it the project's main scene.

**Architecture:** A pure spell matcher quantizes four-beat input phrases. A pure battle model applies spells and enemy attacks. A custom-drawn Godot scene owns audio timing, input, animation, synthesized feedback sounds, and presentation.

**Tech Stack:** Godot 4.7, GDScript, existing 120 BPM OGG stems, custom CanvasItem drawing.

---

### Task 1: Spell matcher

**Files:**
- Create: `scripts/beatspell/spell_matcher.gd`
- Create: `tests/test_spell_matcher.gd`
- Modify: `tests/run_tests.gd`

1. Write tests for slot quantization, timing windows, all three recipes, and invalid phrases.
2. Run tests and confirm the missing matcher fails.
3. Implement the minimum deterministic matcher.
4. Run tests and confirm the suite passes.

### Task 2: Battle model

**Files:**
- Create: `scripts/beatspell/battle_model.gd`
- Create: `tests/test_battle_model.gd`
- Modify: `tests/run_tests.gd`

1. Test fireball damage, shield consumption, healing cap, defeat, and victory.
2. Implement the model without Node or audio dependencies.
3. Run the full suite.

### Task 3: Playable battle scene

**Files:**
- Create: `scripts/beatspell/beatspell_battle.gd`
- Create: `scenes/beatspell/beatspell_battle.tscn`
- Modify: `project.godot`

1. Add count-in, playback clock, four-beat phrase collection, and bar resolution.
2. Schedule telegraphed Boss attacks every four bars.
3. Draw the arena, characters, beat ring, compact spell cards, health, and feedback.
4. Add short synthesized action/skill sounds and balanced music layers.
5. Add pause, restart, victory, and defeat states.

### Task 4: Documentation and verification

**Files:**
- Create: `tests/capture_beatspell_preview.gd`
- Modify: `README.md`

1. Document the new controls and rules.
2. Run all tests and a main-scene smoke test.
3. Capture and inspect gameplay, attack-warning, and result states.
4. Fix visual or timing problems, then commit.

