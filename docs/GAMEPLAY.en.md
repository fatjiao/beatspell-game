# Beatspell illustrated gameplay guide

Version: v0.5.0 internal. Updated: 12 November 2026. [中文版](GAMEPLAY.md).

Beatspell is a pixel art rhythm spellcasting Boss battle. Build spells on a continuous shared beat instead of following falling notes. This demo contains one battle lasting up to 90 seconds, an untimed practice mode and three defense drills. The screenshots and diagrams below accompany the same rules as the Chinese guide; annotations in the original diagrams are Chinese, while the game screenshots show the English interface.

## Start a run

Defeat the Resonant Warden before your health or the 90-second timer runs out. You have 5 HP; the Warden starts with 60 HP. A four-beat count-in lasts about two seconds and is excluded from the timer. The first nine musical bars, or 18 seconds, teach the spells and count toward the timer. Press R after a result to retry, or Esc to return to the title.

Spells have no mana cost or separate cooldown. Their beat patterns determine how long each action takes. Attack when safe, heal when hurt, and prepare a shield before incoming attacks.

## Controls and interface

![Annotated battle interface](media/gameplay/battle-overview.png)

The caster is on the left and the Warden on the right. Health bars sit at the top, spell recipes at the bottom. The central ring shows musical position and input timing; the track beneath the Warden shows attack cues.

| Input | Action |
|---|---|
| D or F | Step; both keys perform the same action |
| J or K | Finish the current command and recognize a spell |
| Enter or Space | Start a battle from the title |
| T | Enter practice from the title; after lessons, toggle free practice and defense drills |
| Left / Right | Queue a defense pattern for the next bar |
| Tab | Open a paused training report; Tab or Esc closes to pause; P resumes |
| P | Pause / resume |
| R | Restart the current mode, including practice lessons |
| H | Open the spellbook and pause |
| O | Open options and pause |
| C | Leave the current run and enter audio calibration |
| Esc | Return to title; quit from title |

Xbox-style controller face buttons X/Y perform steps, and A/B finish spells. Menus and options currently use the keyboard. Closing the spellbook or options during a run leaves the game paused; press P to resume.

## The continuous timing ring

![Early, on-time and late inputs](media/gameplay/timing-ring.png)

The music runs at 120 BPM: 500 ms per beat, four beats per bar and 2,000 ms per revolution. The ring moves clockwise through top, right, bottom and left. Start on any whole beat. Starting, finishing or failing a spell never resets the global ring.

Input marks show the actual angle when you pressed. A mark before the nearest beat is early; after it is late. Thin connecting lines show the error. Steps use circles, spell finishes use diamonds, and mistakes remain visible in red. Marks do not snap to beat positions. Active commands retain their trail; finished trails remain for 650 ms and fade together over another 350 ms.

Perfect timing is within ±55 ms; Good is within ±135 ms. An active command expires more than 3.25 beats, or 1,625 ms, after its first target beat. Off-window or duplicate inputs can break the command; expiration also breaks the combo.

## Three spell recipes

![Beat-by-beat spell patterns](media/gameplay/spell-patterns.png)

| Spell | Whole-beat pattern | Effect |
|---|---|---|
| FLARE / 炎击 | Step → finish | Perfect: 2 damage; Good: 1 |
| MEND / 回春 | Step → step → finish | Perfect: heal 2; Good: heal 1, capped at 5 HP |
| AEGIS / 护盾 | Step → rest → finish | One shield blocks the next attack |

For FLARE, press D on one beat and J on the next. For MEND, use D, D, J on three successive beats. For AEGIS, use D, leave the next beat empty, and press J on the third. F can replace D and K can replace J. The whole command receives a spell grade; an incorrect combination fails. Refreshing AEGIS replaces the existing shield rather than stacking shields.

## Guard, fracture and resonance

![Guard and damage bonuses](media/gameplay/guard-and-bonuses.png)

A shield blocks one attack. A Perfect AEGIS completed within the last 600 ms before impact produces a **Perfect Guard**. Earlier Perfect shields and Good shields still block, but do not count as Perfect Guards. Play before impact: when an input coincides exactly with a bar boundary, the scene resolves the attack before processing the new input.

An ordinary block adds 1 fracture point; a Perfect Guard adds 2. At 3 points the Warden becomes exposed. The next FLARE gains +2 damage and consumes exposure. Four successful consecutive spells prime resonance for +1 damage on the next FLARE; later multiples of four can prime it again. Exposure and resonance stack. Errors, expired commands and taking damage clear the current combo and resonance.

## Boss phases and warnings

![Attack cue timing](media/gameplay/boss-cues.png)

The first nine bars stay in phase I. Bars 1–8 have no attacks; bar 9 ends with a teaching attack. Afterward the phase follows the Warden's remaining health, using the thresholds in the table.

| Phase | Health | Attack bars | Damage |
|---|---|---|---|
| I / AWAKENING | Above two-thirds (41–60 HP) | Every fourth global bar | 1 |
| II / FRACTURE | Above one-third, up to two-thirds (21–40 HP) | Every third global bar | 2 |
| III / OVERDRIVE | Up to one-third (1–20 HP) | Every second global bar | 2 |

Global bar numbering continues through phase changes; the first attack in a new phase may arrive sooner than a full four, three or two bars. During an attack bar, four visual and audible cues lead to impact at the end of the bar, 2,000 ms after its start.

| Pattern | Cue offsets from bar start | Feel |
|---|---|---|
| STANDARD | 0, 500, 1,000, 1,500 ms | Even beats |
| SYNCOPATED | 0, 750, 1,000, 1,750 ms | Alternating long and short gaps |
| RUSH | 0, 1,000, 1,500, 1,750 ms | Waiting first, then accelerating |

Phase I uses Standard; phase II alternates Standard and Syncopated; phase III alternates Syncopated and Rush. The final cue is not the impact. The Warden winds up during the final 600 ms and strikes at impact.

## Lessons and practice

![Independent practice](media/gameplay/practice.png)

In the normal battle, bars 1–3 introduce FLARE, bars 4–6 MEND, and bars 7–9 AEGIS. These lessons advance with time; they do not wait for successful casts, and any valid spell remains available.

Press T at the title for untimed, damage-free practice. Successfully cast FLARE twice, then MEND twice, then AEGIS twice in their respective lessons. Casting another lesson's spell early does not complete that future lesson. Successful spells restore both sides to full health, so the target cannot be defeated. The footer shows lesson progress. R restarts all lessons and Esc returns to the title.

### Defense drills and report

![Defense drills and report](media/gameplay/defense-report.png)

After completing all lessons, press T to toggle defense drills. An attack happens every two bars without damaging the player. Entry waits for a complete future warning bar. Left and Right select Standard, Syncopated or Rush; the selection takes effect at the next bar, allowing any current warning to finish unchanged. A new pattern removes the old shield while preserving the global ring.

Each pattern separately tracks attempts, blocks, Perfect Guards, current streak and best streak. Three consecutive Perfect Guards clear a pattern. A later ordinary block or miss resets its current streak, while the cleared status remains. These three consecutive guards are a separate goal from the three-point fracture meter.

Tab opens the paused report. TRY means attempts, BLK blocks, PRF Perfect Guards and RUN the best consecutive Perfect Guard streak. A cleared row displays OK. The last outcome explains the shield: PERFECT GUARD succeeded; EARLY SHIELD was a Perfect spell completed too early; GOOD SHIELD had a Good spell grade; NO SHIELD means none was active. The displayed milliseconds measure shield completion to impact.

Tab or Esc closes the report to pause. P resumes directly, including from the report; R restarts the lessons and records. T returns to free practice. Switching patterns or toggling drills preserves this round's records; restarting or leaving practice begins a new round. Records are not permanent saves. Drills reproduce warnings without the normal battle's damage or phase pressure.

## Language, options and calibration

![Chinese and English language options](media/gameplay/languages.png)

Press O, move Up/Down to LANGUAGE, then use Left/Right, Enter or Space to cycle **AUTO / 中文 / English**. AUTO uses Simplified Chinese on Chinese system locales and English otherwise. The preference takes effect immediately and saves locally. Switching preserves the active command, training records and battle position. Esc returns to pause; P resumes.

Both languages cover the title, combat feedback, phases, spellbook, practice, reports, results and calibration. FLARE is 炎击, AEGIS 护盾 and MEND 回春. Chinese glyphs are bundled; no installed Chinese font is required.

Options also adjust music, sound effects, screen shake and fullscreen. Volumes range from 0% to 100% in 10% steps, both defaulting to 80%. Shake defaults on; fullscreen defaults off. Changes save immediately on the current computer.

Calibration uses a separate 100 BPM metronome, or 600 ms per beat. Press D with the clicks to collect eight samples on distinct nearest beats. Pre-roll taps, repeated taps on the same beat and backwards beats are ignored; skipping a beat is allowed. Enter saves the completed result, R retries and Esc returns without saving. Entering calibration leaves the current run.

The calculation rejects samples more than 120 ms from the initial median, then uses the remaining median and clamps the result to ±300 ms. Battle judgment uses music time minus the saved offset. A positive offset compensates for consistently late inputs. Recalibrate after changing headphones or audio outputs.

## Results and rank

![Result screen](media/gameplay/results.png)

CAST displays successful spells / attempts; P, G and X show Perfect, Good and failed spells. AVG is the mean absolute timing error across recorded step and finish inputs, rounded to milliseconds. The screen also reports the highest combo, effective damage and healing, blocks, Perfect Guards, breaks, elapsed time and remaining Boss HP.

| Rank | Conditions |
|---|---|
| S | At least 90% spell success, no Miss inputs, mean absolute error ≤45 ms |
| A | Does not meet S; at least 75% success and error ≤80 ms |
| B | Does not meet a higher rank; at least 50% success and error ≤120 ms |
| C | All other runs, including no spell attempts |

Success rate is successful spells divided by attempts. Mean signed error below −8 ms gives EARLY, above +8 ms gives LATE, and otherwise ON TIME. Rhythm rank and victory are separate, so a lost run can still receive a high rank.

An expired active command counts as one failed attempt. A command still active at the end of a battle also counts once. Clearing prevents duplicate failures. Neither case invents a physical input; actual off-window inputs still contribute to input error and Miss statistics.

## Art, audio and interaction

![Character poses](media/gameplay/character-poses.png)

The game renders at a real 320×180 viewport with nearest-neighbor sampling and integer scaling. The moonlit observatory, neutral caster and brass Warden use a 16-bit pixel direction. Each character has three actual pose PNGs: caster idle, charge and cast; Warden idle, windup and strike. Pose changes communicate state; music time still determines judgment.

Audio includes 120 BPM music stems and 14 original WAV effects for inputs, spells, cues, guards, impacts, errors, breaks and results. English uses the original handmade glyphs; Chinese uses unmodified Fusion Pixel 8px and 10px fonts. Font notices and upstream licenses are in `assets/fonts/fusion-pixel/` and the portable build's `FONT_LICENSES/`.

Keep interactions restrained: start on any whole beat, preserve the continuous ring, show true input timing and retain visible errors. Additional effects should make casts and attacks easier to read without obscuring the ring.

## Numeric reference

| Parameter | Value |
|---|---|
| Battle tempo | 120 BPM |
| Beat / bar | 500 ms / four beats / 2,000 ms |
| Count-in | Four beats, about two seconds |
| Battle limit / tutorial | 90 seconds excluding count-in / nine bars, 18 seconds |
| Player / Boss HP | 5 / 60 |
| Perfect / Good window | ±55 ms / ±135 ms |
| Command expiry | More than 1,625 ms after first target beat |
| FLARE damage / MEND healing | Perfect 2; Good 1 |
| Perfect Guard | Perfect AEGIS completed 0–600 ms before impact; play before the boundary |
| Fracture threshold | 3; ordinary block +1, Perfect Guard +2 |
| Exposure / resonance bonus | Next FLARE +2 / next FLARE +1; stackable |
| Resonance threshold | Each multiple of four successful consecutive casts |
| Finished trace hold / fade | 650 ms / 350 ms |
| Defense drill attack / clear | Every two bars / three consecutive Perfect Guards per pattern |
| Calibration | 100 BPM, eight distinct beats, offset ±300 ms |
| Languages | AUTO / 中文 / English; AUTO by default |

## Future development

These are planned or unverified directions, rather than implemented features: collect device and beginner playtest data; refine pixel animations, attack readability and audio balance; improve onboarding; test wired, Bluetooth and speaker latency. More levels and Steam release preparation follow once the single battle is stable. The earlier two-chapter band prototype is separate from the current Boss demo.

## Maintenance and sources

Update this guide, the [Chinese guide](GAMEPLAY.md), relevant figures, CHANGELOG and `PROJECT_HANDOFF.md` whenever controls, timing, spells, Boss rules, settings or scoring change. The existing online Page is the editable Chinese companion with links to both public language versions; preserve user edits when synchronizing it.

Rules are implemented in `scripts/beatspell/timing_profile.gd`, `spell_command_buffer.gd`, `battle_model.gd`, `battle_director.gd`, `practice_director.gd`, `defense_drill.gd` and `performance_tracker.gd`. Language strings and fallback rules are in `localization.gd`; settings and calibration are in `scripts/settings/`. [Current code and tests](https://github.com/fatjiao/beatspell-game/tree/main) ship with the guide.
