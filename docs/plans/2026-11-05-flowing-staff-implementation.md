# Flowing Instrument Staff Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the four fixed floor-key lamps with a compact, flowing score in which drums, bass, synth, and lead each occupy one miniature staff.

**Architecture:** Keep chart timing and judgement unchanged. Add a small pure presentation helper that maps event time and instrument to score coordinates, then render the score from the existing chart events inside `prototype_stage.gd`. The stage remains visible behind a translucent lower-third score panel.

**Tech Stack:** Godot 4.7, GDScript, CanvasItem custom drawing, existing JSON chart events.

---

### Task 1: Score position model

**Files:**
- Create: `scripts/presentation/flowing_staff.gd`
- Create: `tests/test_flowing_staff.gd`
- Modify: `tests/run_tests.gd`

**Step 1: Write the failing test**

Test that the hit time maps to the fixed hit line, one second ahead maps 60 pixels to the right, visibility is bounded, and every instrument has a stable row.

**Step 2: Run test to verify it fails**

Run: `.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . -s tests/run_tests.gd`

Expected: the new presentation helper cannot be preloaded.

**Step 3: Write minimal implementation**

Create a `RefCounted` helper with constants for the panel, hit line, speed, look-ahead window, and row centers.

**Step 4: Run test to verify it passes**

Run the full test suite and expect all suites to pass.

### Task 2: Flowing score renderer

**Files:**
- Modify: `scripts/prototype/prototype_stage.gd`

**Step 1: Replace fixed floor anchors**

Remove the four lamp anchors and their large floor cue beams. Draw a translucent score panel from y=108 to y=167.

**Step 2: Draw four miniature staves**

For each instrument, draw five subtle staff lines, a small key/instrument label, and one common vertical hit line.

**Step 3: Draw upcoming notes**

Use the helper to map unconsumed chart events into the visible score window. Give each instrument a distinct note-head silhouette and color, with a tiny key letter near the note.

**Step 4: Preserve hit feedback**

When a note is played, flash only the matching staff and hit point. Keep `PERFECT`, `GOOD`, and `MISS` feedback unchanged.

### Task 3: Visual verification

**Files:**
- Modify: `tests/capture_feedback_preview.gd`
- Modify: `README.md`

**Step 1: Update capture names**

Capture the early single-instrument score, ensemble score, and result card.

**Step 2: Run automated verification**

Run the test suite and headless scene smoke test.

**Step 3: Render and inspect screenshots**

Generate previews, inspect both gameplay states, and fix any overlap or readability issues before delivery.

