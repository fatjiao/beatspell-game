# Beatspell original sound effects

14 mono, 22,050 Hz, signed 16-bit WAV effects authored procedurally for this project on 2026-11-09. No third-party samples or external audio-generation service is used.

Rebuild with:

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tools/generate_sfx.gd
```

The deterministic source is `scripts/beatspell/sound_bank.gd`. Runtime loads the exported WAVs directly. `sfx_profile.gd` controls runtime mix levels, while the settings menu applies the user's SFX gain.

Ordered listening reel: `build/beatspell-sound-reel.wav`.

| Order | File | Design |
|---|---|---|
| 1 | charge.wav | Short low pulse with a filtered-noise transient |
| 2 | cast.wav | Brighter downward chirp marking phrase completion |
| 3 | fireball.wav | Noisy sweep with a low-frequency impact layer |
| 4 | shield.wav | Bell-like inharmonic partials |
| 5 | shield_block.wav | Lower metallic hit with noise attack |
| 6 | parry.wav | High crystalline metallic hit |
| 7 | heal.wav | Rising four-note motif |
| 8 | boss.wav | Low body impact plus filtered-noise transient |
| 9 | warning.wav | Compact pulse whose pitch rises across four cues |
| 10 | error.wav | Low detuned falling buzz |
| 11 | count.wav | Short high count-in click |
| 12 | break.wav | Low fracture hit with a high metallic crack |
| 13 | victory.wav | Rising cadence |
| 14 | defeat.wav | Falling cadence |

All effects use attack/release ramps and DC filtering. Automated tests validate audibility, peak limits, mean offset, sample edges and exported durations. These checks do not replace subjective listening and mixed-play balance testing.
