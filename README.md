# Beatspell Boss Demo

一款原创的节奏施法 Boss 战 Demo。玩家不追逐下落音符，而是在持续运行的公共节拍上组合动作，并用施法键结束节奏指令。

旧版《一个人的乐队》场景仍保留在仓库历史与 `scenes/prototype/` 中，但当前启动入口已经切换为新的 Boss 战。

## 项目文档

- [中文玩法图文说明](https://github.com/fatjiao/beatspell-game/blob/main/docs/GAMEPLAY.md) · [English gameplay guide](https://github.com/fatjiao/beatspell-game/blob/main/docs/GAMEPLAY.en.md)：无需登录即可转发，包含 12 张截图与机制图解、完整规则、输入示例和数值
- [Pages 编辑版](https://chatgpt.com/space/page_3464b9beb91481919abe7d81d68d2251)：需要对应账号访问，与公开版同步维护
- [开发接力指南](docs/PROJECT_HANDOFF.md)：新电脑配置、当前状态、目录结构、验证方法与 AI 接力提示词
- [下一阶段开发计划](docs/plans/2026-11-05-beatspell-next-steps.md)：按优先级排列的 Demo 路线图和验收标准
- [架构决策](docs/adr/0001-deterministic-rhythm-battle-core.md)：为什么将节奏逻辑、战斗逻辑与表现层分离
- [历史设计与实施计划](docs/plans/)：包括已经完成或被后续方案取代的设计记录

## 运行

直接双击 `启动游戏.cmd`。

也可以在 PowerShell 中执行：

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64.exe' --path .
```

第一次在新电脑运行前，请按照[开发接力指南](docs/PROJECT_HANDOFF.md)安装 Git 与 Godot 4.7.2。`.tools/`、`.godot/` 和 `build/` 都是本地目录，不会上传到 GitHub。

游戏会先停在标题界面，左右键选择仪式 Ritual、决斗 Duel 或试炼 Gauntlet，按 `J/K`、Enter、Space 或手柄施法键开始。标题与结算按 `V` 查看战绩簿，`V/Esc` 关闭。标题界面按 Esc 退出；战斗中按 Esc 返回标题。

## 构建内部试玩包

```powershell
.\build-playtest.ps1
```

脚本会运行 24 组测试，以及 `test_playtest_flow.gd`、`test_encounter_flow.gd` 两套场景流程，再生成 `build/BeatspellPlaytest-v0.6.0.zip`。解压后双击 `Launch Beatspell.cmd` 即可在没有安装 Godot 的 Windows 电脑上试玩。这个包使用随附的 Godot 运行器，仅用于内部测试；正式 Steam 包仍需安装 Godot 官方导出模板后生成。

游戏支持中文和 English。按 `O` 打开设置，上下选“语言 / LANGUAGE”，左右选择自动／中文／English，即时生效并保存。自动跟随系统语言；战斗、练习、结算和校准均可切换。中英文术式对应：炎击 FLARE、护盾 AEGIS、回春 MEND。中文像素字体和授权随包内置。

The game supports Chinese and English. Press `O`, select LANGUAGE with Up/Down, then use Left/Right to choose AUTO, 中文 or English. Changes apply instantly and save locally. AUTO follows Chinese system locales and falls back to English. Close with Esc, then press P to resume a paused run.

## 战斗模式与战绩

三种模式使用同一个 Boss、三种术式、120 BPM、5 点玩家生命、60 点 Boss 生命及 90 秒时限；四拍倒计时不计入时限。术式配方和 Perfect／Good 窗口一致。

| 模式 | 教学与攻击 |
|---|---|
| 仪式 RITUAL | 保留前九小节教学，第九小节末教学攻击；之后随阶段每 4／3／2 小节攻击 |
| 决斗 DUEL | 跳过教学，直接按生命阶段每 4／3／2 小节攻击，伤害随阶段为 1／2／2 |
| 试炼 GAUNTLET | 跳过教学，每 2 小节攻击并造成 2 点伤害；标准、切分、Rush 按攻击顺序轮换 |

标题的模式选择自动保存在本机设置中，重开保留当前模式。每次正式战斗结束只记一场，胜负均可提升节奏评级和最高连击，最快通关只统计胜利。练习、主动返回标题或中途重开不记场次。结算会标出新评级、最快通关或最高连击，写入失败会显示提示。

战绩簿按模式分别保存场次、胜场、最高评级、最快通关与最高连击，存放于本地 `user://run-records.json`，不进行云同步。计数保存上限为 999999，界面大数显示为 `999+`；最快时间显示到 0.1 秒，内部保留毫秒进行比较。

At the title, use Left/Right to select RITUAL (guided), DUEL (no lessons) or GAUNTLET (two-bar attacks with rotating warnings). Press V at the title or results to view per-mode records; V/Esc closes the book. Completed battles count once, including losses. Practice and abandoned runs do not count. Best rank and combo include losses; fastest clear requires victory. Records save locally without cloud sync.

当前美术方向是 **16-bit 像素风**：月夜观星台、中性施法者与黄铜守卫均采用像素素材，配合 320×180 实际渲染分辨率、最近邻采样及整数倍缩放。后续美术继续遵循像素风。素材与生成提示词见 [像素美术来源](assets/art/beatspell/pixel/README.md)。

战斗已接入主角待机/蓄力/施法与守卫待机/蓄力/出击共六张独立 PNG。这些动作通过本地像素编辑原素材制作，不依赖在线生成服务；重建命令和帧规格见 [角色动作帧](assets/art/beatspell/pixel/poses/README.md)。

## 操作

- `D` / `F`：动作输入，两键作用相同
- `J` / `K`：结束当前组合并立即施法，两键作用相同
- `P`：暂停 / 继续
- `R`：重新开始
- `C`：打开音频延迟校准
- `T`：标题界面进入练习模式
- 左右方向键：标题选择战斗模式；防御训练中排队切换标准、切分和 Rush 节奏，下一小节生效
- `V`：标题或结算打开战绩簿；`V/Esc` 关闭
- `Tab`：练习中查看训练报告；`Tab/Esc` 返回暂停页，`P` 继续
- `O`：打开设置；方向键调整音乐、音效、屏幕震动、全屏与语言，Esc 返回
- `H`：打开术式手册，战斗会暂停
- `Esc`：返回标题；标题界面退出

玩家可以在任意整拍开始术式，不需要等待固定小节的起点。中央外圈始终按照音乐的全局四拍连续运行，不会因起手或施法而复位；内圈图标按真正按下时的实时角度落点，不会吸附到拍点。目标角点之前代表按快了，之后代表按慢了；图标到目标角点的细线表示偏差方向和距离。小圆点是动作，菱形是结束/施法；超出判定窗口或同拍重复的输入也会保留，并显示为红色。

术式尚未结束时会保留完整输入轨迹；结束后整条轨迹短暂停留并一起渐隐。普通按键不再弹出中央文字，时机反馈只通过内圈位置和颜色表达。

## 术式

标题按 `T` 可以进入无伤害、无时限的独立练习。按 FLARE → MEND → AEGIS 的顺序，每种成功施放两次，之后进入自由练习。音乐会循环，底栏显示当前练习与成功次数，`R` 重置练习，Esc 返回标题。仪式模式保留九小节开场教学；决斗和试炼直接战斗。

完成三个练习后再次按 `T`，可切换无伤害防御训练，每两小节攻击一次。左右键选择标准、切分或 Rush，切换在下一小节生效，保持当前预警完整；进入训练时也会等待完整的未来攻击小节。每种节奏连续精准格挡 3 次记为通过，`Tab` 报告分别记录尝试、格挡、精准格挡和最佳连续次数，切换模式保留本轮记录。再按 `T` 回自由练习，`R` 重开会重置课程与训练记录。

- `FLARE`：整拍按 `D/F`，下一整拍按 `J/K`。对 Boss 造成伤害。
- `AEGIS`：整拍按 `D/F`，空一拍后在第三拍按 `J/K`。抵挡下一次 Boss 攻击。
- `MEND`：连续两个整拍按 `D/F`，第三拍按 `J/K`。恢复生命。

防御和连击奖励：

- 攻击前最后一拍完成 Perfect AEGIS 可精准格挡。实际容差为攻击前 600ms，覆盖最后整拍的 Perfect 早晚误差。
- 普通格挡积累 1 格破防值，精准格挡积累 2 格；满 3 格令 Boss 暴露弱点，下一发火球额外造成 2 点伤害。
- 连续成功施法 4 次，积蓄共鸣；随后的一发火球额外造成 1 点伤害，可与破防增伤叠加。
- 错误组合、指令过期或未挡住攻击会中断连击和未使用的共鸣。护盾成功格挡保留连击。
- Boss 生命值为 60；仪式模式开场九小节固定第一阶段。

仪式模式开局前九小节依次练习三种术式：`FLARE`、`MEND`、`AEGIS`。第九小节末会发动一次教学攻击，用于验证护盾；中央节拍环仍不会告诉玩家下一键。随后 Boss 按生命值进入三个阶段：第一阶段每四小节攻击一次，第二阶段每三小节一次，第三阶段每两小节一次。攻击小节会显示蓄力环，Boss 下方的八分拍轨道会按当前攻击节奏点亮四个提示符并播放同步声音，整小节后出手。仪式与决斗第一阶段保持稳定四拍，第二阶段交替加入切分节奏，第三阶段交替使用切分和先慢后快的 Rush 节奏；攻击伤害从第一阶段的 1 点提高到 2 点。试炼改用上表中的固定频率和三种预警轮换。

按下 `J/K` 时系统会立即识别刚才的节奏；错误组合当场清空，下一整拍即可重新起手，不再等待统一的四拍窗口结束。玩家指令与 Boss 的攻击小节互相独立。Boss 阶段在新小节开始时锁定，因此本小节的攻击预警不会因玩家造成伤害而临时改变。

胜利或失败后，结算面板会显示表现等级、成功施法数、Perfect/Good/失败次数、平均输入偏差，以及整体偏快、偏慢或基本准时的倾向。

超时指令以及战斗结束前尚未完成的组合，均计一次失败尝试，不虚增物理输入次数。音频校准需在 8 个不同的最近拍上输入，同拍连按只计一次。

## 音频

Demo 暂时使用现有 120 BPM 分轨作为开发音乐。独立 WAV 音效与来源见 [音效库](assets/sfx/beatspell/README.md)。源码为 `scripts/beatspell/sound_bank.gd`，运行 `tools/generate_sfx.gd` 可重建全部文件和 `build/beatspell-sound-reel.wav` 试听串。首次使用蓝牙耳机或更换音频设备后，建议按 `C` 校准。

## 测试

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/run_tests.gd
```

施法命令解析器、节奏参数、战斗模型与 Boss 进程控制器均有独立测试。BPM、判定窗口、指令过期长度与输入校准偏移集中在 `scripts/beatspell/timing_profile.gd`。设计、架构决策与实施计划位于 `docs/`。

完整场景流程验证：

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_playtest_flow.gd
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_encounter_flow.gd
```

练习课程由 `practice_director.gd` 管理，专项防御统计由 `defense_drill.gd` 管理。`encounter_rules.gd` 管理三种正式战斗规则，`run_records.gd` 管理本地战绩；主场景使用同一模式规则驱动预警声音与画面。`sprite_pose.gd` 在六张独立姿态 PNG 之间切换，并叠加像素对齐的位移与恢复动画。
