# Encounters and Records Implementation Plan

**Goal:** Deliver selectable encounters, persistent per-mode records and a complete replay loop in v0.6.0.

**Architecture:** Keep encounter rules and saved records in independent RefCounted modules. The battle scene routes existing warning audio and graphics through the same selected pattern. Records receive one final language-independent snapshot; overlays translate only when drawing.

**Tech Stack:** Godot 4.7.2, GDScript, native 320×180 pixel UI, local JSON, headless suites and graphical captures.

## Design

Three always-unlocked modes share 5 player HP, 60 Boss HP, 90 seconds and unchanged 120 BPM / judgment / spell rules. RITUAL retains nine teaching bars. DUEL skips teaching and applies health phases and global 4/3/2-bar attack cadence from the start. GAUNTLET skips teaching, attacks every two bars for 2 damage, and cycles Standard → Syncopated → Rush. Practice remains independent.

Title Left/Right chooses a mode; V opens the records book. Selection persists locally. R restarts the same mode. Each completed non-practice run records one attempt, victory, best rhythm rank, fastest victorious clear and best combo. Abandoning, practice and reopening result overlays never record a run. First records and improvements appear on results; failed writes are visible.

## Tasks and validation

1. Add `encounter_rules.gd` and `test_encounter_rules.gd`: validate mode fallback, first attacks, global cadence, teaching, phase thresholds and pattern rotation.
2. Add `run_records.gd` and `test_run_records.gd`: validate rank ordering, win-only times, isolation, malformed saves and local persistence.
3. Integrate battle/title/records/result controls with both languages in `beatspell_battle.gd`, `battle_overlay.gd`, `settings_store.gd`, `localization.gd`. Add isolated scene-flow checks for selection, restarts, warning/audio agreement and save-once behavior.
4. Capture English/Chinese title, records, results and trial warning views; update illustrated guides, existing Page, handoff, changelog and build version.
5. Run `tests/run_tests.gd`, `tests/test_playtest_flow.gd`, `tests/test_encounter_flow.gd` and `build-playtest.ps1`. Visually inspect both layouts; export and smoke-test the Windows portable build, then commit and push this batch.

## Completed validation — 2026-11-12

24 suites and both scene flows pass. Both language captures were inspected; moving the capture's Records preload to file scope removed its exit resource leak. Review corrected warning colors to share the selected encounter pattern and cleared stale selection-save errors after a successful retry. v0.6.0 ZIP passes export, headless and graphical startup checks, archive integrity, packaged README and font-notice byte checks. The existing Page matches all 137 local content blocks with twelve native images; all twelve local figure digests match the upload map.
