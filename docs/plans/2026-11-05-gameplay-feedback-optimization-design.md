# Gameplay Feedback Optimization

## Goal

Make the existing four-key prototype easier to read and more satisfying without adding another mechanic or increasing the demo's learning burden.

## Options considered

1. **Gameplay feedback first — selected.** Improve count-in, upcoming-input emphasis, judgement feedback, pausing and results. This has the largest effect on first-play clarity while preserving the validated core loop.
2. Add more character and environment art. This improves presentation but does not solve timing readability.
3. Build chapter navigation immediately. This expands the demo but would wrap an interaction that still needs polish.

## Design

- Begin each run with a four-beat, two-second visual count-in at 120 BPM.
- Keep the compact one-line note ribbon and highlight the pad for the next note during its final 1.4 seconds.
- Show short `PERFECT`, `GOOD`, `MISS`, and `OFF BEAT` feedback near the performer, with a subtle matching stage border.
- Celebrate every five-note streak without introducing combo-dependent failure.
- Support `P` pause/resume and `R` restart from the keyboard.
- Stop after the rehearsal and show a persistent result card with score, weighted accuracy, counts, and rank. Restart only when the player presses `R`.

## Verification

- Load and run the main scene without parser or runtime errors.
- Run the complete Godot test suite.
- Capture and visually inspect the normal gameplay and result states at the native 320×180 layout scaled to 1280×720.
