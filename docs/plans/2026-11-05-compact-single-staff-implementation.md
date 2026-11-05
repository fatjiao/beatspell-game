# Compact Single Staff Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Compress the four instrument staves into one small flowing five-line staff.

**Architecture:** Keep the existing horizontal timing model and hit line. Map each instrument to a stable vertical note position within one staff, then use note color and silhouette as redundant identification. Reduce the lower overlay from 59 pixels to at most 34 pixels.

**Tech Stack:** Godot 4.7, GDScript, CanvasItem custom drawing.

---

### Task 1: Compact score geometry

**Files:**
- Modify: `scripts/presentation/flowing_staff.gd`
- Modify: `tests/test_flowing_staff.gd`

**Steps:**
1. Change the test to require a panel no taller than 34 pixels and four distinct note positions on one staff.
2. Run the test and confirm the old four-row layout fails.
3. Replace row centers with single-staff note positions.
4. Run the full suite and confirm it passes.

### Task 2: Single-staff renderer

**Files:**
- Modify: `scripts/prototype/prototype_stage.gd`
- Modify: `README.md`

**Steps:**
1. Draw one five-line staff and remove four row backgrounds and labels.
2. Add a tiny horizontal D/F/J/K legend at the left.
3. Place all chart events on the shared staff using instrument note positions.
4. Keep the common hit line, approach halo, and hit burst.

### Task 3: Verification

**Files:**
- Modify: `tests/capture_feedback_preview.gd`

**Steps:**
1. Rename captures for the compact staff.
2. Run automated tests and scene smoke test.
3. Capture early and ensemble states with desktop rendering.
4. Inspect layout and fix overlap or legibility problems before committing.

