# Live Input Phase Design

The outer cursor and four large markers show the ideal public beat. Player input icons on the inner ring must show the exact phase at which the key was pressed, not the beat position selected by the timing judge.

Every accepted event therefore stores two separate values:

- `ring_tick`: the nearest whole beat, used for spell recognition.
- `ring_phase`: the unquantized song-time position within the four-beat cycle, used for drawing.

An icon before its target corner means the input was early. An icon after the corner means it was late. The timing window and spell result still use the quantized tick and offset, so this visual feedback cannot change gameplay outcomes.
