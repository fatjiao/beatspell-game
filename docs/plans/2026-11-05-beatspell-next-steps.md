# Beatspell Next Steps Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Turn the current playable Beatspell boss prototype into a polished, externally testable vertical slice before adding more content or beginning Steam release work.

**Architecture:** Preserve the tested separation between `SpellCommandBuffer`, `BattleModel`, `BattleDirector`, and the presentation scene. First make timing and feedback tunable and measurable, then add one meaningful boss variation, complete the visual/audio pass, and only then package a Windows playtest build.

**Tech Stack:** Godot 4.7.2, GDScript, custom `Control._draw()` presentation, OGG music stems, generated `AudioStreamWAV` feedback, script-based headless tests, Git/GitHub.

---

## 当前基线

- 可玩主场景已切换到 Beatspell Boss 战。
- 三种术式、实时早晚落点、错误输入标记、轨迹淡出、三阶段 Boss 和四拍攻击预警已经完成。
- 当前版本为 `v0.4.0-internal`，21 个测试组与扩展场景流程测试通过，便携试玩包已构建。
- Task 1 至 Task 5 在 2026-11-09 形成最初的 v0.1.0；其后已完成像素素材、六张姿态帧、WAV 音效、独立练习、设置、破防与共鸣，以及三种专项防御训练和训练报告。
- 2026-11-10 完成的专项训练批次见 `2026-11-09-defense-training-feedback.md`。公开图文玩法文档已扩展到九张图，并与 Pages 编辑版同步。
- 当前最大风险不是功能缺失，而是节奏手感、声音层次和攻击可读性尚未经过外部玩家验证。

开发顺序遵循：**先手感，后内容；先可测量，后凭感觉调参；先做一场完整体验，后扩关。**

### 接下来的开发重点

1. 用 `docs/PLAYTEST.md` 收集真实新手、不同耳机与输入设备的记录。自动化测试已验证时机规则和状态流转，实际听感与学习难度仍需要真实试玩。
2. 根据具体记录调整音乐与预警层次、教学文案和校准体验，保持当前任意整拍起手及真实输入位置显示。不要凭猜测放宽判定窗口。
3. 继续完善像素角色和 Boss 的恢复、命中与攻击动作；新素材必须保持现有轮廓和像素方向，并更新来源记录与图文说明。
4. 核心体验稳定后再确定新增关卡与发行内容量，沿用内部包验证流程。

后续每批开发继续同步 `docs/GAMEPLAY.md`、相关配图、Pages 编辑版、CHANGELOG 和接力指南；公开 GitHub 阅读版随同一提交更新。

### Task 1: 建立可重复的手感测试基线（已完成）

**Files:**
- Create: `scripts/beatspell/timing_profile.gd`
- Create: `tests/test_timing_profile.gd`
- Modify: `tests/run_tests.gd`
- Modify: `scripts/beatspell/spell_command_buffer.gd`
- Modify: `scripts/beatspell/beatspell_battle.gd`
- Modify: `README.md`

**Step 1: 写失败测试**

为默认 120 BPM 配置、Perfect/Good 窗口、输入偏移应用和边界值写测试。成功标准是现有硬编码常量尚未被配置对象替代时测试失败。

**Step 2: 运行测试确认失败**

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/run_tests.gd
```

Expected: 新增 `timing_profile` 测试失败，现有测试仍通过。

**Step 3: 提取最小配置对象**

把 BPM、Perfect/Good 窗口、指令过期长度和音频偏移应用集中到 `timing_profile.gd`。不要添加谱面编辑器或复杂资源系统。

**Step 4: 接入现有逻辑**

让 `SpellCommandBuffer` 接受配置值；场景继续保持 120 BPM 默认行为。现有三种术式和实时落点不能改变。

**Step 5: 回归测试与手测**

运行完整测试，然后分别以键盘、有线耳机和当前常用音频设备完成一局。记录是否出现持续偏快或偏慢，而不是立刻扩大判定窗口。

**Step 6: 提交**

```powershell
git add scripts/beatspell/timing_profile.gd scripts/beatspell/spell_command_buffer.gd scripts/beatspell/beatspell_battle.gd tests/test_timing_profile.gd tests/run_tests.gd README.md
git commit -m "refactor: centralize rhythm timing profile"
```

### Task 2: 调整按键、技能与 Boss 预警的声音层次（已完成）

**Files:**
- Modify: `scripts/beatspell/beatspell_battle.gd`
- Create: `scripts/beatspell/attack_cue_audio.gd`
- Create: `scripts/beatspell/sfx_profile.gd`
- Create: `tests/test_attack_cue_audio.gd`
- Modify: `tests/run_tests.gd`
- Modify: `docs/PROJECT_HANDOFF.md`

**Step 1: 为预警调度写测试**

覆盖同一拍只触发一次、暂停后不重复、第四拍音高与前三拍不同、非攻击小节无提示音。

**Step 2: 分离声音生成与播放调度**

保持实时合成方案，但把音色参数和播放条件拆成小函数。避免继续扩大 `_update_attack_cue()` 和 `_make_sfx()` 的职责。

**Step 3: 完成一次混音通关**

以鼓轨为基准，确保动作键最短最轻、结束键清晰、技能命中比普通输入更突出、Boss 四拍预警在音乐中可听见但不盖过节拍。

**Step 4: 验证**

运行全套测试并用普通扬声器与耳机各打一局。成功标准：闭眼时能分辨普通输入、成功施法、攻击倒数和受击四类声音。

**Step 5: 提交**

```powershell
git add scripts/beatspell/beatspell_battle.gd tests/test_attack_cue_audio.gd tests/run_tests.gd docs/PROJECT_HANDOFF.md
git commit -m "tune: rebalance rhythm battle feedback audio"
```

### Task 3: 增加 Boss 节奏变化与战局统计（已完成）

**Files:**
- Modify: `scripts/beatspell/battle_director.gd`
- Modify: `tests/test_battle_director.gd`
- Modify: `scripts/beatspell/beatspell_battle.gd`
- Create: `docs/plans/2026-11-09-syncopated-boss-and-results-design.md`
- Create: `scripts/beatspell/performance_tracker.gd`
- Create: `tests/test_performance_tracker.gd`
- Modify: `tests/test_attack_cue_audio.gd`
- Modify: `tests/capture_beatspell_preview.gd`

**Step 1: 先写一页设计**

在不改变 `D/F`、`J/K` 的前提下，从以下方向只选一个：假动作后延迟出手、两次轻击、或要求护盾在指定拍生效。设计必须说明预警声音、视觉节奏、伤害和失败反馈。

**Step 2: 写 Director 失败测试**

用纯数据表达攻击模式和拍点，测试阶段边界、警告拍和伤害结算。不要把攻击规则直接写进绘制函数。

**Step 3: 实现最小规则与表现**

先完成一套可读模式，不做随机模式池。Boss 变化必须在不开文字提示的情况下通过节奏、颜色和动作读懂。

**Step 4: 验证**

至少完成三次完整通关：第一次观察、第二次学习、第三次确认能稳定应对。若仍必须看说明文字才能理解，则回到预警设计而不是增加提示标签。

**Step 5: 提交**

```powershell
git add scripts/beatspell/battle_director.gd scripts/beatspell/beatspell_battle.gd tests/test_battle_director.gd docs/plans
git commit -m "feat: add a readable boss rhythm variation"
```

### Task 4: 完成垂直切片视觉整理（已完成）

**Files:**
- Modify: `scripts/beatspell/beatspell_battle.gd`
- Modify: `scenes/beatspell/beatspell_battle.tscn`
- Modify: `assets/art/README.md`
- Modify: `tests/capture_beatspell_preview.gd`

**Step 1: 冻结 320×180 信息层级**

确定只保留生命、Boss 状态、公共节拍环、三张术式卡和必要反馈。禁止重新放大 `D/F/J/K` 或加入持续闪烁的下一键提示。

**Step 2: 拆分过大的绘制职责**

若 `beatspell_battle.gd` 继续膨胀，将角色、Boss 或 HUD 绘制拆为独立 `Control`，但不改动节奏核心。

**Step 3: 统一视觉资源**

替换临时几何图形时，保持中性主角方向和原创 Boss 设计。每个新增素材都在 `assets/art/README.md` 记录生成方式、日期和许可来源。

**Step 4: 截图验收**

捕获教学、普通战斗、Boss 攻击预警、护盾格挡、胜利和失败六个状态。全尺寸检查文字重叠、对比度、节拍环遮挡和 16:9 拉伸。

**Step 5: 提交**

```powershell
git add scripts/beatspell/beatspell_battle.gd scenes/beatspell/beatspell_battle.tscn assets/art/README.md tests/capture_beatspell_preview.gd
git commit -m "polish: complete boss demo visual pass"
```

### Task 5: 制作外部试玩包（已完成内部便携版）

**Files:**
- Create: `export_presets.cfg`
- Create: `docs/PLAYTEST.md`
- Create: `CHANGELOG.md`
- Modify: `README.md`

**Step 1: 配置 Windows 导出**

使用 Godot 4.7.2 对应导出模板，输出到被 `.gitignore` 排除的 `build/`。不要把导出二进制提交进 Git。

**Step 2: 写最小试玩说明**

`docs/PLAYTEST.md` 只询问：是否理解起手、是否看懂早晚、是否能学会三种术式、是否听懂 Boss 四拍预警、哪一处最挫败。不要提前解释玩家应该得到什么答案。

**Step 3: 完整发布前验证**

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/run_tests.gd
```

再在一台没有 Godot 的 Windows 电脑上解压并启动导出包，完成一局、暂停、重开、校准和退出。

**Step 4: 标记内部版本**

测试通过后更新 `CHANGELOG.md`，提交源代码，并创建类似 `demo-v0.1.0` 的标签。只有用户明确要求发布时才上传 Release 或公开试玩包。

## Demo 完成标准

- 新玩家在两次尝试内能独立施放三种术式。
- 不依赖大号键位提示，也能理解实时落点的早晚方向。
- Boss 攻击预警在视觉与听觉上都能独立成立。
- 一局从启动到胜负不崩溃，暂停、重开、校准正常。
- 全部自动测试通过，Windows 独立包在无 Godot 环境运行。
- 所有进入包内的素材都有来源和授权记录。

## 暂不做

- Steamworks、成就、云存档和商店页面。
- 多章节剧情、大量 Boss 或完整关卡编辑器。
- 在线功能、账号、排行榜和多人模式。
- 为解决手感问题而盲目增加键位或扩大 UI 提示。

等外部试玩确认核心循环成立后，再另写 Steam 发布计划和预算表。
