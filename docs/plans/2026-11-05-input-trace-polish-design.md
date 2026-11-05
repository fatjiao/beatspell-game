# Input Trace Polish Design

The beat ring should explain timing through motion and position, without interrupting play with large per-input text. While a spell phrase is active, its entire visual trail remains fully opaque so the first step of a three-beat spell cannot disappear before the finish input. Once the phrase ends, the whole trail stays solid for 650 milliseconds and then fades together over 350 milliseconds. A standalone missed input follows the same timing.

Each command event stores its adjusted song time as `input_time_ms`. A small pure helper calculates one alpha value for the full trail from the newest event, the current adjusted song time, and whether a phrase is still active. The battle renderer applies that alpha to input icons, target lines, and missed-input outlines. Gameplay judgment continues to use only quantized ticks and timing windows.

Normal step, off-pulse, and duplicate presses no longer replace the central battle message. Their position and color provide the timing feedback. The input sound still plays immediately in the keyboard event path, before spell recognition or visual feedback, so it remains tied to the physical press. Spell results, phase changes, and boss attacks keep their central messages because they communicate battle state rather than individual timing.
