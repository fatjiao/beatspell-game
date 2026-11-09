# Battle character poses

Six transparent PNGs, authored locally on 2026-11-09 as derivatives of the original `../caster.png` and `../warden.png`. The online image generation service was unavailable; these files were created with local pixel editing in Godot, not a successful new imagegen request. Original sources and prompts are recorded in the parent README.

| Character | Canvas | Frames |
|---|---|---|
| Caster | 48×64 | idle, charge, cast |
| Warden | 72×72 | idle, windup, strike |

The caster's leading sleeve, forearm, hand and orb are redrawn as pixel shapes. Charge bends the arm toward the chest; cast extends it and shifts the cape tip backwards. Warden poses reposition the front claw with inverse nearest-neighbor mapping; four pixels of padding preserve room for the strike. Head and feet remain on the same canvas to avoid jumps between frames. No smoothing is applied.

`sprite_pose.gd` holds caster actions for 320ms and strike for 340ms, then returns to idle. Warden windup appears during the final 600ms of its warning bar. Strike takes priority over windup. Existing movement/recovery and pause handling remain in the battle scene.

Rebuild from the repository root:

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tools/build_pose_frames.gd
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --editor --path . --import
```

The script also writes `build/beatspell-pose-sheet.png`: caster idle/charge/cast on the top row; Warden idle/windup/strike below. The source files are unchanged. Edit the generator when revising these derived frames, since rebuilding overwrites the PNGs.

Run `tests/run_tests.gd` for texture dimensions, transparent margins, distinct frame data and timing/priority boundaries. Run `tests/capture_beatspell_preview.gd` with a graphical Godot instance for battle, charge, windup and strike previews. Generated previews and engine binaries stay in ignored local directories; PNG assets and reconstruction source belong in Git.
