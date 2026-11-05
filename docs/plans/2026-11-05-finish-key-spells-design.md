# Finish-Key Spell Design

The battle uses one continuous public beat clock. Player commands never start, stop, or rotate that clock.

`D/F` are interchangeable step inputs. `J/K` are interchangeable finish inputs. A finish input immediately closes the current command and asks the parser to identify its rhythm; the player never waits for a fixed phrase window to expire.

The first demo supports two deliberately different rhythms:

- FLARE: step on a whole beat, then finish on the next whole beat.
- MEND: step on a whole beat, a second step on the intervening half beat, then finish on the next whole beat.

Inputs are quantized on an eighth-note grid. A command may begin only on a whole beat, while the second MEND step may occupy a half beat. Every recorded event also stores its absolute eight-position ring phase so its icon appears where the public clock actually was.

An invalid finish clears the command immediately. The next valid whole beat can begin a new command. Completed events remain visible briefly as feedback, but the outer cursor never resets.
