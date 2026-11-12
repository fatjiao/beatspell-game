# Gameplay guide figures

Fourteen 1200×940 PNG figures accompany the online Page, `docs/GAMEPLAY.md` and `docs/GAMEPLAY.en.md`. They combine the game's existing preview captures with code-native labels and diagrams. Original game textures and captures are not overwritten. These are documentation assets; `docs/.gdignore` keeps them out of Godot's runtime asset imports.

| File | Subject |
|---|---|
| battle-overview.png | Numbered annotations on the battle interface |
| timing-ring.png | Early, on-time and late input positions |
| spell-patterns.png | Three spell recipes on a 500ms beat timeline |
| guard-and-bonuses.png | Guard, fracture, exposure and resonance relationships |
| boss-cues.png | Standard, syncopated and rush warning times |
| practice.png | Practice mode and lesson progress |
| results.png | Result panel, per-run statistics and new-record badges |
| character-poses.png | Actual caster and Warden pose textures |
| defense-report.png | Five defense practice patterns and the paused training report |
| languages.png | Chinese and English settings, preference and spell-name correspondence |
| encounters.png | Ritual / Duel / Gauntlet / Prism title selection and rule differences |
| records.png | Per-mode completed runs, wins, rank, fastest clear, combo and victory medals |
| prism-boss.png | Armor/open states, damage modifiers and Echo/Offbeat warning timelines |
| session-safety.png | Chinese/English three-count resume UI and focus-loss rules |

Rebuild from the repository root with a graphical Godot runtime:

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_beatspell_preview.gd
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_beatspell_preview.gd -- zh_CN
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tools/build_gameplay_figures.gd
```

The first two commands capture reproducible English and Chinese UI states, including sample result statistics; Chinese captures use a `-zh-preview.png` suffix. Captures use an isolated settings path and do not change player preferences. The final command uses a separate 1200×940 viewport, nearest-neighbor screenshot rendering, and local system fonts for diagram labels. Diagram system fonts are not redistributed; the game's separately bundled Fusion Pixel font notices live in `assets/fonts/fusion-pixel/`. Do not run the figure renderer headlessly; it needs graphical rendering to produce the images.

To rebuild only affected figures, append their names after `--`, for example `-- encounters records results defense-report guard-and-bonuses prism-boss session-safety`. This preserves unchanged figure bytes and their existing uploads. The v0.7.0 batch adds `prism-boss.png` and `session-safety.png` and refreshes encounters, records, results, defense-report and guard-and-bonuses; reuse the existing upload references for unchanged figures.

When gameplay, timing or layout changes, revise the diagram labels and coordinates in the generator as needed, rebuild and visually inspect the affected PNGs. The existing screenshots are under ignored `build/`; another computer must run the capture command first.

`page-images.json` maps local files to confirmed uploaded native Page image references and SHA-256 digests. The online guide embeds these as native image blocks at width 960 with preserved aspect ratio. Unchanged files can reuse those references. Changed files need a new upload and a guarded update to their existing Page image blocks. Never replace online image references with GitHub raw URLs; those do not create native Page images.

Figures are inspected locally for labels, glyphs, cropping and content. Online readback checks native image blocks and image geometry. Whole-page browser preview was blocked by a separate browser sign-in requirement; it was not treated as a document access failure. The public GitHub guide and its figures remain accessible without sign-in.
