# Finish-Key Spell Design

The battle uses one continuous public beat clock. Player commands never start, stop, or rotate that clock.

`D/F` are interchangeable step inputs. `J/K` are interchangeable finish inputs. A finish input immediately closes the current command and asks the parser to identify its rhythm; the player never waits for a fixed phrase window to expire.

The first demo supports two deliberately different rhythms:

- FLARE: step on a whole beat, then finish on the next whole beat.
- MEND: step on two consecutive whole beats, then finish on the third whole beat.

Inputs are quantized on a whole-beat grid. Every recorded event also stores its absolute four-position ring phase so its icon appears where the public clock actually was. An earlier half-beat MEND prototype was removed because it felt too fast at 120 BPM.

An invalid finish clears the command immediately. The next valid whole beat can begin a new command. Completed events remain visible briefly as feedback, but the outer cursor never resets.
