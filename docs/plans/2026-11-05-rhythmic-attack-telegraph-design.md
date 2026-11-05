# Rhythmic Boss Telegraph Design

Boss attacks should be readable as part of the music rather than as a text warning. During an attack bar, the existing red outer arc continues to show the full-bar buildup. Four small sigils beneath the boss represent the four whole beats; each sigil lights when its beat begins. A short synthesized warning pulse plays on each beat, with a slightly higher final pulse before the strike resolves at the bar boundary.

The `STRIKE INCOMING` label is removed. The player reads danger from the red buildup, the four-beat visual count, and the synchronized sound. This preserves the game's low-prompt presentation and leaves the center focused on the public beat ring and the player's live input trail.

`BattleDirector` exposes a pure `attack_cue_index` function that returns `0–3` only when the supplied song time is inside an attack bar, otherwise `-1`. The battle scene tracks the last global cue key so each warning sound plays exactly once, including across frame-rate variation. Pausing does not advance song time and therefore cannot skip or duplicate cues. Tests cover attack-bar boundaries and all four cue positions.
