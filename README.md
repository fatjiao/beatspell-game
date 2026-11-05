# Beatspell Boss Demo

一款原创的节奏施法 Boss 战 Demo。玩家不追逐下落音符，而是在四拍小节中组合“蓄力”和“施法”动作，完成攻击、护盾或治疗术式。

旧版《一个人的乐队》场景仍保留在仓库历史与 `scenes/prototype/` 中，但当前启动入口已经切换为新的 Boss 战。

## 运行

直接双击 `启动游戏.cmd`。

也可以在 PowerShell 中执行：

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64.exe' --path .
```

## 操作

- `D` / `F`：蓄力动作，两键作用相同
- `J` / `K`：施法动作，两键作用相同
- `P`：暂停 / 继续
- `R`：重新开始
- `C`：打开音频延迟校准

每拍只能输入一个动作。中央节拍环显示当前拍与本小节已完成的动作，但不会提示下一键。

## 术式

- `FLARE`：蓄力、施法、蓄力、施法。对 Boss 造成伤害。
- `AEGIS`：蓄力、蓄力、休止、施法。抵挡下一次 Boss 攻击。
- `MEND`：施法、休止、施法、施法。恢复生命。

Boss 每四小节发动一次攻击，红色蓄力环与音效会提前预警。错误节奏只会打断当前术式，不会立即结束战斗。

## 音频

Demo 暂时使用现有 120 BPM 分轨作为开发音乐。按键反馈、火球、护盾、治疗与 Boss 攻击音效由游戏实时合成。首次使用蓝牙耳机或更换音频设备后，建议按 `C` 校准。

## 测试

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/run_tests.gd
```

节奏匹配器与战斗模型均有独立测试。设计、架构决策与实施计划位于 `docs/`。
