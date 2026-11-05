# One Person Band Demo Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Windows-first Godot prototype that judges four instrument inputs against a data-driven chart and demonstrates layered one-person-band play.

**Architecture:** Keep timing and judgement in pure, testable GDScript classes, while scenes coordinate audio, input, and presentation. Treat audio playback time as the source of truth; charts, music stems, and visuals remain independent so placeholder music can be replaced without rewriting gameplay systems.

**Tech Stack:** Godot 4.x, GDScript, JSON chart data, WAV/OGG stems, built-in headless test runner scripts.

---

### Task 1: Bootstrap the Godot project and automated test runner

**Files:**
- Create: `project.godot`
- Create: `icon.svg`
- Create: `tests/run_tests.gd`
- Create: `tests/test_smoke.gd`
- Create: `.gitignore`

**Step 1: Write the failing smoke test**

Create `tests/test_smoke.gd` with a function that asserts the project timing constant is available. It should fail before the timing class exists.

**Step 2: Run the test to verify it fails**

Run: `godot --headless --path . --script res://tests/run_tests.gd`

Expected: non-zero exit with a missing script/class error.

**Step 3: Add the minimum project configuration**

Configure a 320×180 viewport, integer scaling, 60 FPS target, and the four instrument actions `instrument_drums`, `instrument_bass`, `instrument_synth`, and `instrument_lead`.

**Step 4: Run the test to verify project startup**

Run: `godot --headless --path . --script res://tests/run_tests.gd`

Expected: `PASS: smoke` and exit code 0.

**Step 5: Commit**

```bash
git add project.godot icon.svg tests .gitignore
git commit -m "chore: bootstrap Godot rhythm game project"
```

### Task 2: Implement deterministic rhythm judgement

**Files:**
- Create: `scripts/rhythm/rhythm_judge.gd`
- Create: `scripts/rhythm/chart_event.gd`
- Create: `tests/test_rhythm_judge.gd`
- Modify: `tests/run_tests.gd`

**Step 1: Write failing judgement tests**

Cover these cases with millisecond inputs:

- 20 ms offset returns Perfect.
- 80 ms offset returns Good.
- 160 ms offset returns Miss.
- A calibration offset is subtracted before judgement.
- A consumed event cannot score twice.
- Pressing the wrong instrument does not consume the expected event.

**Step 2: Run tests and confirm failure**

Run: `godot --headless --path . --script res://tests/run_tests.gd`

Expected: failure because `RhythmJudge` does not exist.

**Step 3: Implement minimal pure logic**

Use default windows of 45 ms for Perfect and 110 ms for Good. Return a dictionary containing `grade`, `offset_ms`, and the matched event index. Keep the class independent of nodes and audio playback.

**Step 4: Run tests and confirm pass**

Expected: all judgement tests pass with exit code 0.

**Step 5: Commit**

```bash
git add scripts/rhythm tests
git commit -m "feat: add deterministic rhythm judgement"
```

### Task 3: Add chart loading and validation

**Files:**
- Create: `scripts/rhythm/chart_loader.gd`
- Create: `data/charts/prototype.json`
- Create: `tests/fixtures/invalid_chart.json`
- Create: `tests/test_chart_loader.gd`
- Modify: `tests/run_tests.gd`

**Step 1: Write failing chart tests**

Verify a valid chart loads BPM, duration, and sorted events. Verify an invalid instrument, negative timestamp, unknown input type, or unsorted event list produces an actionable error containing the offending event index.

**Step 2: Run tests and confirm failure**

Expected: missing `ChartLoader` failure.

**Step 3: Implement JSON parsing and validation**

Accept instruments `drums`, `bass`, `synth`, `lead` and types `tap`, `hold_start`, `hold_end`. Reject malformed charts before gameplay begins.

**Step 4: Run tests and confirm pass**

Expected: valid fixture passes and invalid fixture is rejected with the expected message.

**Step 5: Commit**

```bash
git add scripts/rhythm data/charts tests
git commit -m "feat: load and validate rhythm charts"
```

### Task 4: Build the audio conductor and synchronized track mixer

**Files:**
- Create: `scripts/audio/conductor.gd`
- Create: `scripts/audio/track_mixer.gd`
- Create: `scenes/audio/track_mixer.tscn`
- Create: `assets/music/README.md`
- Create: `tests/test_conductor_math.gd`
- Modify: `tests/run_tests.gd`

**Step 1: Write failing conductor math tests**

Test beat conversion at 120 BPM, calibration offsets, pause/resume compensation, and monotonic song time.

**Step 2: Run tests and confirm failure**

Expected: missing conductor functions.

**Step 3: Implement conductor and four synchronized players**

Derive song time from `AudioStreamPlayer.get_playback_position()` plus the audio server time since the last mix, minus output latency and player calibration. Start all stem players on the same frame and change volume rather than starting tracks late.

**Step 4: Run headless tests**

Expected: conductor math tests pass. Audio-device verification remains a manual integration test.

**Step 5: Commit**

```bash
git add scripts/audio scenes/audio assets/music tests
git commit -m "feat: add synchronized audio conductor"
```

### Task 5: Assemble the playable prototype stage

**Files:**
- Create: `scenes/prototype/prototype_stage.tscn`
- Create: `scripts/prototype/prototype_stage.gd`
- Create: `scripts/ui/prototype_hud.gd`
- Create: `assets/art/prototype/README.md`
- Modify: `project.godot`

**Step 1: Create a minimal stage with debug visuals**

Show four instrument pads, current song time, next expected input, judgement text, combo, heat, and active track indicators.

**Step 2: Connect input to the judge**

Map each action to its instrument, judge against the chart, consume matched events, and display the signed timing error.

**Step 3: Connect chart progress to track layers**

Use chart markers to reveal track activity. Until real stems exist, drive metronome clicks and colored pulses so timing can still be evaluated.

**Step 4: Run the project manually**

Run: `godot --path . --editor` or `godot --path .`

Expected: the prototype opens at 320×180, all four keys animate, judgements appear, and the sequence completes without blocking on a miss.

**Step 5: Commit**

```bash
git add scenes scripts/prototype scripts/ui assets/art project.godot
git commit -m "feat: add playable four-instrument prototype"
```

### Task 6: Add calibration, pause safety, and local settings

**Files:**
- Create: `scenes/settings/calibration.tscn`
- Create: `scripts/settings/calibration.gd`
- Create: `scripts/settings/settings_store.gd`
- Create: `tests/test_calibration.gd`
- Modify: `scenes/prototype/prototype_stage.tscn`
- Modify: `tests/run_tests.gd`

**Step 1: Write failing calibration tests**

Test median offset calculation, outlier rejection, clamping, and default settings recovery after malformed JSON.

**Step 2: Implement calibration and settings persistence**

Collect repeated taps against a metronome, calculate a stable median offset, preview it, and save only after confirmation. Pause automatically on focus loss.

**Step 3: Run all automated tests**

Expected: all test suites pass.

**Step 4: Perform manual device checks**

Test keyboard, Xbox-layout controller, wired audio, and Bluetooth audio. Confirm the calibration screen makes large-latency Bluetooth usable or displays a warning when the offset is outside the supported range.

**Step 5: Commit**

```bash
git add scenes/settings scripts/settings tests scenes/prototype
git commit -m "feat: add rhythm calibration and settings"
```

### Task 7: Replace debug presentation with Chapter 1 vertical slice

**Files:**
- Create: `scenes/chapters/subway/subway_stage.tscn`
- Create: `scripts/stage/stage_director.gd`
- Create: `data/chapters/chapter_01.json`
- Create: `data/charts/ch01_lesson_01.json`
- Create: `data/charts/ch01_lesson_02.json`
- Create: `data/charts/ch01_finale.json`
- Create: `assets/art/subway/*`
- Modify: `project.godot`

**Step 1: Import the selected Chapter 1 music stems**

Record source, author, license, BPM, download date, and local filenames in `assets/music/README.md`. Verify all stems share length, sample rate, and loop points.

**Step 2: Author the three Chapter 1 charts**

Keep lesson one to drums, lesson two to bass imitation, and the finale to alternating drums and bass.

**Step 3: Add pixel-art stage reactions**

Increase lighting, passing pedestrian attention, and environmental animation as layers are completed. Provide idle, perform, miss, and finish states for Loop.

**Step 4: Playtest the complete chapter**

Expected: a new player can finish in 8～12 minutes, understands the four-key model, and cannot soft-lock after repeated misses.

**Step 5: Commit**

```bash
git add scenes/chapters scripts/stage data assets
git commit -m "feat: complete subway chapter vertical slice"
```

### Task 8: Complete Chapter 2 and package the internal demo

**Files:**
- Create: `scenes/chapters/cafe/cafe_stage.tscn`
- Create: `data/chapters/chapter_02.json`
- Create: `data/charts/ch02_lesson_01.json`
- Create: `data/charts/ch02_lesson_02.json`
- Create: `data/charts/ch02_finale.json`
- Create: `assets/art/cafe/*`
- Create: `scenes/ui/demo_ending.tscn`
- Create: `export_presets.cfg`

**Step 1: Import and document Chapter 2 stems**

Verify licensing and synchronization exactly as in Chapter 1.

**Step 2: Implement hold/release and four-instrument rotation**

The final chart may use all four keys but ordinarily asks for one at a time and never more than two simultaneously.

**Step 3: Add the café stage and ending teaser**

Animate rain, coffee-machine steam, cups, and lighting on musical events. End with silhouettes of the park, bar, and festival poster.

**Step 4: Run full verification**

Run automated tests, then complete the six-level flow with keyboard and controller. Log judgement distributions and inspect audio drift at the end of each song.

**Step 5: Export Windows build**

Run: `godot --headless --path . --export-release "Windows Desktop" build/OnePersonBandDemo.exe`

Expected: a self-contained Windows build launches and completes the full 20～30 minute flow.

**Step 6: Commit**

```bash
git add scenes data assets export_presets.cfg
git commit -m "feat: package two-chapter internal demo"
```

