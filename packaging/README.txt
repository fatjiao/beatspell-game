BEATSPELL INTERNAL PLAYTEST v0.7.0 - PRISM / MASTERY

Double-click "Launch Beatspell.cmd" to start.

At the title, use Left/Right to select RITUAL, DUEL, GAUNTLET or PRISM.
RITUAL: nine teaching bars, then phase-based attacks every 4/3/2 bars.
DUEL: no lessons; phase-based attacks every 4/3/2 bars from the start.
GAUNTLET: no lessons; attack every 2 bars for 2 damage, rotating
Standard / Syncopated / Rush warnings.
PRISM: second Boss, 72 HP, attacks every 2 bars for 2 damage.
Echo cues: 0/250/1000/1250ms; Offbeat: 250/750/1250/1750ms.
Both patterns hit at 2000ms after the attack bar begins.
Prism repeats 2 armored bars (FLARE -1) and 2 open bars (FLARE +1).
Apply that modifier after other bonuses, minimum calculated damage 1.
All modes: 120 BPM, 5 player HP, 90 seconds after count-in.
RITUAL/DUEL/GAUNTLET Boss HP: 60. PRISM Boss HP: 72.

V at title/results opens per-mode records; V or Esc closes.
Completed battles count once. Best rank/combo include losses;
fastest clears require victory. Practice and abandoned runs do not count.
Records save on this computer (user://run-records.json), without cloud sync.
The result panel shows new records or a save-failure notice.
Per-mode badges: Clear -> A-rank victory -> S-rank victory.
Losing with a high rhythm rank does not earn a victory badge.
Existing records remain; old wins migrate to Clear without guessing rank.

Losing window focus pauses active battles, count-in and practice.
Returning to the window never resumes automatically.
P starts a 3-beat / 1500ms resume count-in, preserving music phase.
P or Esc cancels the resume count-in and returns to pause.

Language: O -> LANGUAGE -> AUTO / 中文 / English.
Use Up/Down to select, Left/Right to change. Saved immediately.
AUTO follows Chinese system locales and otherwise uses English.
Esc closes options; P resumes a paused run.

中文：解压后双击 Launch Beatspell.cmd 启动，无需安装 Godot。
按 O 打开设置，上下选择“语言”，左右切换自动／中文／English。
设置立即保存；Esc 返回后按 P 继续。炎击 FLARE、护盾 AEGIS、回春 MEND。
标题左右选择仪式／决斗／试炼／棱镜。棱镜为72生命的第二Boss，护甲两小节、
开放两小节，炎击分别减1或加1伤害；回声与反拍预警交替，每两小节攻击一次。
标题或结算按 V 查看战绩，V/Esc 返回。五种预警均可在防御训练中单独练习。
胜负结算各只计一场，练习和中途放弃不计；战绩只保存在本机。
每模式独立获得通关／A级胜利／S级胜利徽章，失败的高评级不会授予胜利徽章。
切出窗口自动暂停，切回不自动继续；P启动三拍恢复倒计时，P/Esc可取消。

Controls:
D / F       Step
J / K       Finish spell / Start from title
P           Pause / 3-beat resume; P/Esc cancels the resume count-in
R           Restart battle
C           Audio calibration
T           Practice mode (from title)
T           Toggle five-pattern defense drill after completing lessons
Left/Right  Select title encounter / queue defense drill rhythm for next bar
V           Record book from title/results; V/Esc closes
Tab         Training report (pauses practice); Tab/Esc closes to pause
H           Spellbook (pauses battle)
O           Options (music, SFX, screen shake, fullscreen, language)
Arrows      Adjust options; Esc closes options
Esc         Return to title / Quit from title

This portable internal build includes the Godot runner and does not require Godot to be installed.
It is for playtesting only and is not the final Steam package.
Godot Engine is distributed under the MIT License; see GODOT_LICENSE.txt.
Fusion Pixel fonts and upstream notices: FONT_LICENSES/ (SIL OFL 1.1).
Public Chinese guide: https://github.com/fatjiao/beatspell-game/blob/main/docs/GAMEPLAY.md
Public English guide: https://github.com/fatjiao/beatspell-game/blob/main/docs/GAMEPLAY.en.md
