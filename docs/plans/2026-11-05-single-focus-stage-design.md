# Single-Focus Stage Design

> Superseded by `2026-11-05-fixed-key-stage-design.md`. A changing single target worked for one-button references but created unnecessary recognition load in this four-key game.

## Intent

The previous presentation behaved like a technical note highway placed over a background. This redesign keeps the four instruments but adopts the strongest interaction principle from *Rhythm Doctor*: one immediately readable rule and one visual anchor, with the scene carrying most of the feedback.

Reference material:

- Official Steam page: <https://store.steampowered.com/app/774181/Rhythm_Doctor/>
- 7th Beat Games: <https://launchpad.7thbe.at/>
- Official gameplay overview: <https://www.youtube.com/watch?v=dTFOO13CKSY>

The implementation borrows interaction principles, not proprietary characters, art, medical themes, level layouts, or exact effects.

## Interaction

- Loop stands on the left, a single pulse travels through the center, and one large key target anchors the right side.
- D, F, J, and K remain separate instruments, but only the next required input is visible in normal play.
- The level teaches one instrument per section: find the pulse, add the weight, light the tunnel, call the crowd, then combine all four.
- The last section changes the target letter and color for each upcoming note instead of restoring four permanent lanes.
- Score and combo remain hidden during performance. Timing feedback appears briefly near the target and full statistics appear only after the song.

## Stage feedback

- Drums create floor ripples.
- Bass adds low green weight to the left side of the tunnel.
- Synth opens overhead light beams.
- Lead brings passerby silhouettes into the performance.
- Correct inputs create a radial burst at the target; misses briefly split the scene into cyan and magenta offsets.

## Accessibility and scope

Color is never the only instruction: every target includes a large keyboard letter and instrument name. The original four-lane view remains available with `Tab` for timing analysis. The redesign uses the current background, character, chart, and music, so it improves interaction without adding asset or licensing cost.
