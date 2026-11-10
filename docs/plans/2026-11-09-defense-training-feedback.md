# Defense Training and Feedback Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Deliver v0.4.0 with three selectable defense rhythms, a per-pattern training report, complete failed-attempt accounting, and reliable calibration taps, with synchronized illustrated documentation.

**Architecture:** Keep battle timing and global input ring unchanged. A pure `DefenseDrill` model owns requested/active patterns and round statistics; the existing director supplies cue positions to both audio and drawing. Pattern changes take effect at a bar boundary after resolving the previous bar. The battle scene owns input and menu state; the overlay draws reports. Calibration filters duplicate beat taps before collecting samples.

**Tech Stack:** Godot 4.7.2, GDScript, script-based headless tests, pixel UI, local PNG diagram renderer, Pages and public GitHub Markdown.

---

## Scope and decisions

- Preserve D/F and J/K, any-beat starting, real-time ring positions, current spell recipes and battle balance.
- After spell lessons, T enables defense training. Left/right queues Standard, Syncopated or Rush for the next bar; the active warning is never changed mid-bar. Entering training waits for a complete future warning bar.
- Count attempts, blocks, perfect guards and current/best perfect-guard streak per pattern. Three consecutive perfect guards mark a pattern clear; switching patterns preserves round statistics. R resets the round.
- Tab opens a paused training report; Tab/Esc closes to pause, then P resumes. Show last shield outcome and age without persistent next-key prompts.
- Count expired active commands and unfinished commands at battle end once as failed attempts. Do not invent a physical input when recording a timeout.
- Calibration accepts at most one tap per nearest beat, ignores pre-roll and backward/repeated beats, and keeps the existing 8-sample median and ±300ms limit.

### Task 1: Data models and tests

**Files:** `scripts/beatspell/defense_drill.gd`, `tests/test_defense_drill.gd`, `scripts/beatspell/battle_director.gd`, `tests/test_battle_director.gd`, `scripts/settings/calibration.gd`, `tests/test_calibration.gd`, `tests/run_tests.gd`.

1. Write failing tests for queued selection, wraparound, per-pattern accounting, three-guard streak and streak reset.
2. Test cue overrides at exact subdivision boundaries and defensive copies of cue arrays.
3. Test duplicate, early, backward and distinct calibration beat taps.
4. Implement the pure models and run the test runner, expecting all suites to pass.

### Task 2: Scene and report integration

**Files:** `scripts/beatspell/beatspell_battle.gd`, `battle_model.gd`, `battle_overlay.gd`, `scripts/settings/calibration_screen.gd`, `tests/test_playtest_flow.gd`.

1. Integrate shared drill cue selection into audio, warning colors and warning positions.
2. Add training controls and compact HUD; apply requested selection only after previous-bar impact resolution.
3. Add report display and safe menu open/close/reset behavior; report data must be a snapshot.
4. Add shield timing/reason data without changing block or damage rules.
5. Correct expiry/end-of-run failed-attempt accounting and deduplicate calibration input.
6. Verify immunity, queued changes, retained statistics, pause behavior, resets and timeout accounting in the scene integration test.

### Task 3: Visual verification and illustrated guide

**Files:** `tests/capture_beatspell_preview.gd`, `tools/build_gameplay_figures.gd`, `docs/GAMEPLAY.md`, `docs/media/gameplay/`, `README.md`, `docs/PROJECT_HANDOFF.md`, `docs/PLAYTEST.md`, `CHANGELOG.md`.

1. Capture Standard/Syncopated/Rush practice, a queued change, the report and result panel; inspect screenshots for overlap at 320×180.
2. Rebuild only affected documentation figures and inspect them. Update commands, controls, timing and score explanations.
3. Read and preserve the existing online Page, upload changed figures, make guarded edits, read back and compare its content with the public repository copy.
4. Record concrete next priorities and verification results in handoff and plan status.

### Task 4: Package and handoff

**Files:** `project.godot`, `export_presets.cfg`, `build-playtest.ps1`, `packaging/README.txt`.

1. Set v0.4.0, run the full unit and scene flow tests, export and smoke-test the portable PCK, and build the ZIP.
2. Review the diff, commit and push code, documentation and figures together. Keep binaries under ignored `build/`.
3. Verify GitHub main matches the delivered commit. Link the local playable ZIP and public guide in the handoff response.

## Deferred

No new chapter, random Boss pool, economy, Steamworks, cloud storage or extra always-visible input hints. External human playtesting is still needed to assess perceived synchronization and learning difficulty.

## Delivery verification on 2026-11-10

- Tasks 1–4 implemented. All 21 test suites and the extended playtest flow pass, covering mode queueing, old-pattern impact attribution, report pause/resume/restart, safe entry, command expiry/end accounting and calibration beat deduplication.
- Source screenshots captured for all three drill patterns and the training report. The report, warning and result figures were visually checked; unchanged illustration files and uploads were preserved.
- Nine local PNGs match their uploaded byte digests. Online Page readback matches the repository gameplay copy after mapping the native image references, and all nine images retain readable geometry.
- `build-playtest.ps1` built `build/BeatspellPlaytest-v0.4.0.zip`, ran the unit/integration checks, exported the PCK and passed the packaged startup smoke check without warnings or errors in the build log.
- Actual player learning, earphone latency and testing on a separate computer remain the next playtest priorities, not claims established by these automated checks.
