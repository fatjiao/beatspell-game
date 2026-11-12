# Beatspell 开发接力指南

这份文档是换电脑或开启新 AI 开发任务时的总入口。当前有效方向是 **Beatspell 节奏施法 Boss 战**；`scenes/prototype/` 下的《一个人的乐队》属于早期原型，不是当前主线。

当前开发版本为 `v0.6.0-internal`。美术方向必须保持 **16-bit 像素风**；上一轮手绘方向已撤回。背景和标题素材位于 `assets/art/beatspell/pixel/`，战斗使用 `pixel/poses/` 下六张独立姿态帧。采用实际 320×180 viewport、最近邻采样和整数倍缩放，后续不要改回线性过滤或手绘立绘。重新构建目标为 `build/BeatspellPlaytest-v0.6.0.zip`。

v0.6.0 增加同一 Boss 的三种规则：标题左右选择仪式 Ritual、决斗 Duel、试炼 Gauntlet。仪式保留原九小节教学；决斗跳过教学，直接按当前生命阶段每 4／3／2 小节攻击；试炼跳过教学，每 2 小节发动伤害为 2 的攻击，标准、切分、Rush 按攻击顺序轮换。三种模式都保留 5 点玩家生命、60 点 Boss 生命、120 BPM、90 秒时限、四拍倒计时和原判定窗口。模式 ID 为 `ritual/duel/gauntlet`，选择保存于设置的 `encounter` 字段。

规则集中在 `encounter_rules.gd`，主场景通过同一组规则包装方法计算阶段、攻击、伤害和预警 pattern override，预警声音与两处绘制路径必须使用同一个模式结果。切换模式只发生在标题，不在战斗中改变规则；重开保留当前模式。独立练习与三种防御训练沿用原规则，不能随正式模式变更。

标题和结算按 V 查看战绩簿，V/Esc 关闭。`run_records.gd` 按模式分别记录完成场次、胜场、最佳评级、最快胜利毫秒数和最佳连击；胜负都可更新评级及连击，通关时间仅取胜利。`_finish_battle` 保证每次正式结算只写入一次，练习、提前返回标题、中途重开不计入。保存采用临时文件写入后替换，失败会在结算显示；本地文件为 `user://run-records.json`，不进行云同步。计数上限 999999，界面大数显示 `999+`，通关时间显示到 0.1 秒而内部按毫秒比较。

v0.5.0 完成中英文界面：设置第五项为自动／中文／English，默认跟随系统，中文系统使用简体中文，其余回退英文，偏好立即保存。`localization.gd` 管理文案模板、参数与语言解析；`Art.pixel_text` 绘制时翻译静态文案，动态文本先使用 `Lang.text(template, args)`。战斗反馈保存模板和原始参数，不保存已翻译字符串，保证暂停切换后文字更新。模型、报告原始字段和术式标识保持语言无关；不得在核心逻辑中翻译标识。

中文使用内置 Fusion Pixel 8px／10px 简体 OTF，版本 2026.11.10；英文保留手写字模。字体导入禁用抗锯齿、系统回退，使用整数尺寸。完整源授权位于 `assets/fonts/fusion-pixel/`，构建复制到 `FONT_LICENSES/`；更改字体时保留上游授权。中文所有词条已验证两套字体的 glyph 覆盖，中英文关键页面已截图检查。

v0.4.0 完成专项防御训练：左右键排队切换 Standard / Syncopated / Rush，下一小节生效；进入时等待完整未来预警。每种模式独立计数，连续 3 次精准格挡记为通过。Tab 打开暂停式报告，Tab/Esc 关闭到暂停页，P 可直接继续，R 可直接重开。核心统计在 `defense_drill.gd`；音频和绘制共同使用 director 的 pattern override，不能只改其中一路。模式切换保留本轮统计，重开重置课程和统计。

v0.4.0 同时修复超时/局末未完成指令漏计失败，并对音频校准做最近拍去重。超时不虚增物理输入；已清空指令不重复计失败。校准 `sample_for_tap` 拒绝倒计时、同拍和倒退拍输入，仍采样 8 个不同拍，保留原滤波与偏移限制。

v0.6.0 最终验证：24 组测试、`test_playtest_flow.gd` 与 `test_encounter_flow.gd` 两套场景流程全部通过；便携包完成导出、无界面和图形启动检查，退出码均为 0。中英文标题、战绩、新纪录结算截图已检查，十二图字节摘要、ZIP 完整性、包内说明及字体授权逐文件核对通过。在线 Page 与本地 137 个正文块、12 张原生图片引用和几何尺寸一致。测试与截图使用 build/ 下独立设置和战绩路径，不覆盖玩家数据。沙箱内 Godot 读取系统证书会产生宿主启动错误，最终构建在授权环境执行，无该错误；这不是游戏逻辑错误。自动化验证不能替代真实设备和新手的听感测试。

最新美术/声音批次：`pixel_effects.gd` 包含手工像素特效，`assets/sfx/beatspell/` 包含 14 个原创 WAV，`sound_bank.gd` 与 `tools/generate_sfx.gd` 可重建。角色动作在图像工具连接失败期间改用 `tools/build_pose_frames.gd` 本地编辑原素材，产出六张实际 PNG；运行方法见 `assets/art/beatspell/pixel/poses/README.md`。随后在线图像连接已恢复并通过真实生成验证，但这六张已接入素材仍为本地派生图，不能改写它们的来源记录。

玩法图文文档：[在线 Page](https://chatgpt.com/space/page_3464b9beb91481919abe7d81d68d2251)，仓库中文副本为 `docs/GAMEPLAY.md`，英文版为 `docs/GAMEPLAY.en.md`。用户明确要求图文结合，v0.6.0 文档配图扩展为 12 张，新增模式与战绩图、更新结算图，保存在 `docs/media/gameplay/`，重建方法见该目录 README；上传映射见 `page-images.json`。每批涉及玩法、数值或界面的变更都要同步更新两种语言及 Page 的相关文字与配图，在线编辑前先读取并保留用户修改；同步失败时明确记录待同步部分。相关规则已写入根目录 `AGENTS.md`，适用于开发交付，不是后台定时任务。

对外转发使用[公开图文阅读版](https://github.com/fatjiao/beatspell-game/blob/main/docs/GAMEPLAY.md)。仓库已公开，文档与图片已通过无凭据访问验证，不需要 ChatGPT 账号；更新该文件和全部配图并推送到 main 后，公开版随之更新。Pages 编辑版保留原访问权限。

战斗系统包括精准格挡、三格破防、四连击共鸣与 H 术式手册。规则与有效伤害/治疗账本均在 `battle_model.gd`；精准格挡要求场景提供输入与攻击的音乐时间，不使用墙钟。Boss 生命值现为 60，仅仪式模式的教学九小节固定第一阶段。

标题 `T` 可进入独立练习，`O` 打开设置；音乐/音效音量、全屏、震动与语言设置本地保存。设置字段在 `scripts/settings/settings_store.gd`，旧版本设置文件会自动补齐默认值。流程测试使用独立测试设置文件，不改玩家设置。

## 1. 项目目标与约束

- 做出一款原创、可独立发布的轻量节奏游戏，最终目标平台为 Windows / Steam。
- 当前阶段验证同一场约 90 秒 Boss 战的三种规则模式，不急于扩充 Boss 或关卡数量。
- 总预算控制在人民币 1 万元以内，尽量由 AI 辅助完成代码、美术、文案与制作流程。
- 核心不是追逐下落音符，而是在持续公共节拍上输入节奏指令并施放技能。
- 交互要克制：节拍环用于表达实时位置、早晚和失误，不直接提示下一键。
- 当前音乐为 120 BPM 的 CC0 分轨，来源与许可见 `assets/music/README.md`；发布前仍需做一次完整素材权利审计。

## 2. 当前可玩状态

主场景：`scenes/beatspell/beatspell_battle.tscn`

已经完成：

- 120 BPM、四拍循环的持续全局节拍环。
- 任意整拍起手，不需要等小节回到顶部。
- 实时输入位置显示：目标点前是按快，目标点后是按慢。
- 错误时机、同拍重复与错误组合都会在圆环中保留短暂视觉痕迹。
- `FLARE`、`AEGIS`、`MEND` 三种节奏术式。
- 三阶段 Boss、生命值、护盾、治疗、胜负与 90 秒时限。
- 仪式模式的前九小节教学流程，以及 AEGIS 教学攻击。
- 决斗跳过教学直接按阶段战斗；试炼以固定两小节频率轮换三种预警。
- 标题选模式、结算新纪录标识与按模式分开的本地战绩簿。
- Boss 攻击小节的四拍视觉与声音预警。
- 第二阶段标准/切分预警交替，第三阶段交替使用切分与 Rush 预警。
- 结算显示施法成功率、判定分布、平均偏差和 EARLY/LATE 倾向。
- 标题、倒计时、阶段切换、暂停与结算使用独立覆盖层。
- 第三阶段交替使用切分与 Rush 预警；火球和 Boss 攻击带世界层震动。
- `build-playtest.ps1` 可生成无需安装 Godot 的便携内部试玩压缩包。
- 暂停、重开和音频延迟校准。
- 节奏参数与音效混音配置已经集中管理，Boss 预警音不会在同一拍重复触发。
- 纯逻辑、音效采样、动作帧、训练统计、本地化、模式与战绩测试；当前 24 个测试组，以及 `tests/test_playtest_flow.gd`、`tests/test_encounter_flow.gd` 两套场景流程。
- 无伤害、无时限的练习模式，三种术式每种两次成功后自由练习。
- 音乐、音效、震动、全屏与中英文语言设置；暂停后保留动画剩余时间。
- 三种专项防御节奏、每模式独立记录和暂停式训练报告。
- 指令超时及局末未完成计入失败尝试，校准同拍输入去重。

当前操作：

| 输入 | 功能 |
|---|---|
| `D` / `F` | 动作输入，两键等价 |
| `J` / `K` | 结束当前组合并施法，两键等价 |
| `P` | 暂停 / 继续 |
| `R` | 重新开始 |
| `C` | 打开音频延迟校准 |
| 左右方向键 | 标题选择正式模式；防御训练中排队选择预警节奏 |
| `V` | 标题／结算打开战绩簿；`V/Esc` 关闭 |

术式：

| 术式 | 节奏 | 作用 |
|---|---|---|
| `FLARE` | 动作 → 下一整拍结束 | 造成伤害 |
| `AEGIS` | 动作 → 空一拍 → 结束 | 抵挡下一次 Boss 攻击 |
| `MEND` | 连续两拍动作 → 第三拍结束 | 恢复生命 |

判定窗口位于 `scripts/beatspell/spell_command_buffer.gd`：Perfect 为 ±55ms，Good 为 ±135ms。

## 3. 新电脑首次配置

### 3.1 获取代码

安装 Git 后，在 PowerShell 执行：

```powershell
git clone https://github.com/fatjiao/beatspell-game.git
Set-Location beatspell-game
git status
```

预期看到 `On branch main`，并且工作区没有未提交修改。

### 3.2 安装 Godot

项目当前锁定 **Godot 4.7.2 stable，Windows 64-bit**。可以采用以下任一方式：

1. 推荐：下载普通版和 Console 版，将两个可执行文件放到：

   ```text
   .tools/godot/Godot_v4.7.2-stable_win64.exe
   .tools/godot/Godot_v4.7.2-stable_win64_console.exe
   ```

   然后双击 `启动游戏.cmd`。

2. 或者用已安装的 Godot 4.7.2 导入仓库根目录的 `project.godot`，在编辑器中按 F6/F5 运行。

`.tools/` 不在 Git 中，这是有意设计，避免把数百 MB 的引擎文件提交到仓库。

### 3.3 验证环境

运行自动测试：

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/run_tests.gd
```

成功标准：最后一行显示 `All tests passed.`。

再运行两套场景流程，检查模式预警一致性、伤害、单次记账、练习排除、重新加载和失败提示：

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_playtest_flow.gd
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_encounter_flow.gd
```

启动主场景：

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64.exe' --path .
```

手动确认：音乐正常、倒计时后节拍环开始运动、三种术式可施放、`P/R/C` 可用，标题三种模式和 V 战绩簿可操作。检查中文和英文的标题、结算、战绩及语言切换，确认字体无缺字、长文本不溢出。

## 4. 代码地图

| 路径 | 责任 |
|---|---|
| `project.godot` | Godot 项目入口、窗口和输入映射 |
| `scenes/beatspell/beatspell_battle.tscn` | 当前主场景 |
| `scripts/beatspell/beatspell_battle.gd` | 音乐时钟、输入、场景状态、音效与全部战斗绘制 |
| `scripts/beatspell/spell_command_buffer.gd` | 输入量化、实时环位置、术式识别和判定等级 |
| `scripts/beatspell/timing_profile.gd` | BPM、判定窗口、指令过期和校准偏移 |
| `scripts/beatspell/battle_model.gd` | 玩家/Boss 生命、伤害、治疗、护盾和胜负 |
| `scripts/beatspell/battle_director.gd` | 教学、Boss 阶段、攻击频率和四拍预警 |
| `scripts/beatspell/encounter_rules.gd` | 仪式／决斗／试炼的教学、阶段、攻击与预警模式差异 |
| `scripts/beatspell/run_records.gd` | 按模式的本地战绩、纪录比较、存档清理与临时文件替换 |
| `scripts/beatspell/attack_cue_audio.gd` | Boss 预警拍的去重与音高序列 |
| `scripts/beatspell/sfx_profile.gd` | 输入、技能、预警和命中音效的时长与混音层级 |
| `scripts/beatspell/performance_tracker.gd` | 输入偏差、施法成功率和结算统计 |
| `scripts/beatspell/battle_overlay.gd` | 标题、倒计时、阶段提示、暂停和结算覆盖层 |
| `scripts/beatspell/localization.gd` | 中英文模板、动态参数翻译与系统语言解析 |
| `scripts/beatspell/input_trace_fade.gd` | 完成输入轨迹的淡出规则 |
| `scripts/beatspell/defense_drill.gd` | 排队切换防御节奏、训练通过条件与每模式报告 |
| `scripts/beatspell/sprite_pose.gd` | 动作帧选择、像素位移与恢复时间 |
| `tools/build_pose_frames.gd` | 本地重建主角/守卫的六张姿态 PNG 与预览 |
| `scripts/settings/` | 音频校准与本地设置 |
| `tests/run_tests.gd` | 无第三方框架的测试入口 |
| `tests/test_encounter_flow.gd` | 模式选择、两路预警一致、伤害、结算记账、重启与保存失败流程 |
| `assets/music/README.md` | 音乐来源与授权记录 |
| `docs/adr/` | 仍然有效的架构决策 |
| `docs/plans/` | 设计和实施记录，部分是历史方案 |
| `build-playtest.ps1` | 测试、打包、便携运行器复制与 ZIP 生成 |
| `docs/PLAYTEST.md` | 外部试玩步骤与反馈问题 |

架构原则：节奏识别、战斗数值和 Boss 进程尽量保持为无场景依赖的纯逻辑；`beatspell_battle.gd` 负责表现与音频。修改纯逻辑时先写测试，再接入场景。

## 5. 文档有效性

优先阅读：

1. `README.md`
2. 本文档
3. `docs/GAMEPLAY.md` 与其中对应的在线玩法文档
4. `docs/plans/2026-11-05-beatspell-next-steps.md`
5. `docs/adr/0001-deterministic-rhythm-battle-core.md`

以下文档记录了演进过程，但部分规则已被后续方案替代：

- `one-person-band-*`、`fixed-key-*`、`flowing-staff-*`、`single-focus-*`：旧《一个人的乐队》原型。
- `beatspell-boss-design.md`：最初采用固定四拍指令，现已被随时起手和结束键方案替代。
- `rolling-spell-window.md`：后来又被 `finish-key-spells.md` 取代。

不要只根据旧设计稿修改玩法，应以当前代码、README 和测试为准。

## 6. Git 接力流程

开始工作前：

```powershell
git switch main
git pull --ff-only origin main
git status
```

建议每个可验证改动单独提交：

```powershell
git switch -c codex/short-name
# 修改并测试
git add <明确的文件>
git commit -m "feat: describe the change"
git push -u origin codex/short-name
```

如果只是本人在两台电脑之间直接接力，也可以继续使用 `main`，但必须先 `git pull --ff-only`，完成后立即测试、提交并推送。不要提交 `.tools/`、`.godot/` 或 `build/`。

## 7. 开新 AI 任务时的提示词

可直接复制下面这段：

```text
这是 Beatspell Godot 项目。请先完整阅读 AGENTS.md、README.md、docs/PROJECT_HANDOFF.md、docs/GAMEPLAY.md、docs/GAMEPLAY.en.md、docs/plans/2026-11-05-beatspell-next-steps.md 和 docs/adr/0001-deterministic-rhythm-battle-core.md，再检查 git status 与最近提交。当前主线是节奏施法 Boss 战及仪式／决斗／试炼三种模式，不是旧的“一个人的乐队”原型。保持公共节拍环持续运行、玩家可在任意整拍起手、输入显示实时早晚位置、界面不直接提示下一键。使用同一模式规则驱动声音与画面，战绩只计完整正式结算。新增界面文案同时提供中英文，模型标识保持语言无关。修改纯逻辑时补测试，完成后运行 tests/run_tests.gd、tests/test_playtest_flow.gd 和 tests/test_encounter_flow.gd。每批玩法开发同步更新中英文指南、相关配图及接力指南链接的同一份在线玩法 Page，保留用户编辑，最后提交和推送到 GitHub。
```

## 8. 发布前仍需处理

- 正式美术、角色动画、Boss 动画和统一视觉风格。
- 音效混音、不同设备的节奏延迟实测和更多校准体验验证。
- 正式内容量、难度曲线、设置菜单、手柄提示与可访问性。
- Windows 导出模板、版本号、崩溃检查、Steamworks 接入和商店素材。
- 所有音乐、美术、字体、音效和第三方工具的最终授权清单。

当前 `build-playtest.ps1` 生成的是内部便携包：它将本地 Godot 编辑器运行器与导出的 PCK 一起打包。正式公开发布前应从 [Godot 4.7.2 官方归档](https://godotengine.org/download/archive/4.7.2-stable/)安装 Export templates，并使用 `export_presets.cfg` 生成真正的 release EXE。

详细顺序见下一阶段开发计划。
