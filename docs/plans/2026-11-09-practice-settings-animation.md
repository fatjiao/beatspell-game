# Pixel playtest v0.2.0

Keep the 16-bit art, 320×180 integer viewport, two-action spell control and unprompted public ring.

Implement one continuous batch:
1. Add a pure practice director: FLARE → MEND → AEGIS, two successes each, then free practice. No damage or timer. Real cast counts drive progression. Normal battle keeps its nine-bar onboarding, with successful practice counts visible in the footer.
2. Extend settings with music/SFX volume, screen shake and fullscreen, normalizing old or corrupt files. Add an O-key modal at title or pause. Arrow keys adjust values; Esc closes to the previous state. Preserve calibration and assist fields.
3. Add pixel-aligned squash, recoil and recovery poses plus spell/impact particles using existing sprites. Suspend effects with pause. Capture input from a fresh audio clock sample rather than the previous frame.
4. Add meaningful settings and practice tests, a scene-flow integration script, screenshot states, version docs and portable v0.2.0 package. Push source and documentation to GitHub.

No new raster assets are needed: sprite movement is a procedural animation pass, not frame-by-frame or skeletal animation.
