# Beatspell 开发接力指南

这份文档是换电脑或开启新 AI 开发任务时的总入口。当前有效方向是 **Beatspell 节奏施法 Boss 战**；`scenes/prototype/` 下的《一个人的乐队》属于早期原型，不是当前主线。

当前版本为 `v0.3.2-internal`。美术方向必须保持 **16-bit 像素风**；上一轮手绘方向已撤回。背景和标题素材位于 `assets/art/beatspell/pixel/`，战斗使用 `pixel/poses/` 下六张独立姿态帧。采用实际 320×180 viewport、最近邻采样和整数倍缩放，后续不要改回线性过滤或手绘立绘。重新构建生成 `build/BeatspellPlaytest-v0.3.2.zip`。

最新美术/声音批次：`pixel_effects.gd` 包含手工像素特效，`assets/sfx/beatspell/` 包含 14 个原创 WAV，`sound_bank.gd` 与 `tools/generate_sfx.gd` 可重建。角色动作在图像工具连接失败期间改用 `tools/build_pose_frames.gd` 本地编辑原素材，产出六张实际 PNG；运行方法见 `assets/art/beatspell/pixel/poses/README.md`。随后在线图像连接已恢复并通过真实生成验证，但这六张已接入素材仍为本地派生图，不能改写它们的来源记录。

玩法详细文档：[在线 Page](https://chatgpt.com/space/page_3464b9beb91481919abe7d81d68d2251)，仓库副本为 `docs/GAMEPLAY.md`。用户明确要求后续开发同步整理详细玩法；相关规则已写入根目录 `AGENTS.md`。每批涉及玩法和数值的变更都要更新两处，在线编辑前先读取并保留用户修改；同步失败时明确记录待同步部分。此要求适用于开发交付，不是后台定时任务。

本批加入精准格挡、三格破防、四连击共鸣、H 术式手册和练习中的 T 无伤害防御训练。规则与有效伤害/治疗账本均在 `battle_model.gd`；精准格挡要求场景提供输入与攻击的音乐时间，不使用墙钟。Boss 生命值现为 60，教学九小节固定第一阶段。

本批加入标题 `T` 独立练习、`O` 设置页、音乐/音效音量、全屏与震动设置的本地保存；动作使用现有素材的像素对齐位移与压缩恢复。设置字段在 `scripts/settings/settings_store.gd`，旧版本设置文件会自动补齐默认值。流程测试使用独立测试设置文件，不改玩家设置。

## 1. 项目目标与约束

- 做出一款原创、可独立发布的轻量节奏游戏，最终目标平台为 Windows / Steam。
- 当前阶段只验证一场约 90 秒 Boss 战，不急于扩充关卡数量。
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
- 前九小节教学流程，以及 AEGIS 教学攻击。
- Boss 攻击小节的四拍视觉与声音预警。
- 第二阶段标准/切分预警交替，第三阶段交替使用切分与 Rush 预警。
- 结算显示施法成功率、判定分布、平均偏差和 EARLY/LATE 倾向。
- 标题、倒计时、阶段切换、暂停与结算使用独立覆盖层。
- 第三阶段交替使用切分与 Rush 预警；火球和 Boss 攻击带世界层震动。
- `build-playtest.ps1` 可生成无需安装 Godot 的便携内部试玩压缩包。
- 暂停、重开和音频延迟校准。
- 节奏参数与音效混音配置已经集中管理，Boss 预警音不会在同一拍重复触发。
- 纯逻辑、音效采样、动作帧和场景冒烟测试；当前 20 个测试组，以及 `tests/test_playtest_flow.gd` 场景流程测试。
- 无伤害、无时限的练习模式，三种术式每种两次成功后自由练习。
- 音乐、音效、震动与全屏设置；暂停后保留动画剩余时间。

当前操作：

| 输入 | 功能 |
|---|---|
| `D` / `F` | 动作输入，两键等价 |
| `J` / `K` | 结束当前组合并施法，两键等价 |
| `P` | 暂停 / 继续 |
| `R` | 重新开始 |
| `C` | 打开音频延迟校准 |

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

启动主场景：

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64.exe' --path .
```

手动确认：音乐正常、倒计时后节拍环开始运动、三种术式可施放、`P/R/C` 可用。

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
| `scripts/beatspell/attack_cue_audio.gd` | Boss 预警拍的去重与音高序列 |
| `scripts/beatspell/sfx_profile.gd` | 输入、技能、预警和命中音效的时长与混音层级 |
| `scripts/beatspell/performance_tracker.gd` | 输入偏差、施法成功率和结算统计 |
| `scripts/beatspell/battle_overlay.gd` | 标题、倒计时、阶段提示、暂停和结算覆盖层 |
| `scripts/beatspell/input_trace_fade.gd` | 完成输入轨迹的淡出规则 |
| `scripts/beatspell/sprite_pose.gd` | 动作帧选择、像素位移与恢复时间 |
| `tools/build_pose_frames.gd` | 本地重建主角/守卫的六张姿态 PNG 与预览 |
| `scripts/settings/` | 音频校准与本地设置 |
| `tests/run_tests.gd` | 无第三方框架的测试入口 |
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
git switch -c feature/short-name
# 修改并测试
git add <明确的文件>
git commit -m "feat: describe the change"
git push -u origin feature/short-name
```

如果只是本人在两台电脑之间直接接力，也可以继续使用 `main`，但必须先 `git pull --ff-only`，完成后立即测试、提交并推送。不要提交 `.tools/`、`.godot/` 或 `build/`。

## 7. 开新 AI 任务时的提示词

可直接复制下面这段：

```text
这是 Beatspell Godot 项目。请先完整阅读 AGENTS.md、README.md、docs/PROJECT_HANDOFF.md、docs/GAMEPLAY.md、docs/plans/2026-11-05-beatspell-next-steps.md 和 docs/adr/0001-deterministic-rhythm-battle-core.md，再检查 git status 与最近提交。当前主线是节奏施法 Boss 战，不是旧的“一个人的乐队”原型。保持公共节拍环持续运行、玩家可在任意整拍起手、输入显示实时早晚位置、界面不直接提示下一键。修改前先确认当前行为，修改纯逻辑时补测试，完成后运行 tests/run_tests.gd。每批玩法开发同步更新 docs/GAMEPLAY.md 和接力指南链接的同一份在线玩法 Page，保留用户编辑，最后提交和推送到 GitHub。
```

## 8. 发布前仍需处理

- 正式美术、角色动画、Boss 动画和统一视觉风格。
- 音效混音、不同设备的节奏延迟实测和更多校准体验验证。
- 正式内容量、难度曲线、设置菜单、手柄提示与可访问性。
- Windows 导出模板、版本号、崩溃检查、Steamworks 接入和商店素材。
- 所有音乐、美术、字体、音效和第三方工具的最终授权清单。

当前 `build-playtest.ps1` 生成的是内部便携包：它将本地 Godot 编辑器运行器与导出的 PCK 一起打包。正式公开发布前应从 [Godot 4.7.2 官方归档](https://godotengine.org/download/archive/4.7.2-stable/)安装 Export templates，并使用 `export_presets.cfg` 生成真正的 release EXE。

详细顺序见下一阶段开发计划。
