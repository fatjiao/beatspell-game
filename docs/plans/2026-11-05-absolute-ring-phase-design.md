# Absolute Ring Phase Design

The spell ring represents one public four-beat clock shared by the music, the player, and the enemy. Its outer cursor never restarts when a player begins or finishes a spell.

Each accepted input stores two positions:

- `slot`: its position relative to the beginning of the current spell, used only for spell recognition.
- `ring_slot`: the global beat modulo four, used only for presentation.

This separation lets a spell begin on any beat without visually pretending that the first input happened at the top of the ring. If the first input occurs on global beat two, it is still relative spell slot zero, but it is drawn at the corresponding absolute corner. Following inputs continue clockwise from that corner.

The outer cursor and bright beat segment are always derived from song time. Starting, completing, or failing a spell must never change their phase.
