# One Person Band Demo

《一个人的乐队》轻音游技术原型。当前版本用于验证四键乐器切换、节拍判定、连续演奏和宽松失败机制。

## 运行

双击 `run-prototype.ps1`，或在 PowerShell 中执行：

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64.exe' --path .
```

## 操作

- `D`：电子鼓
- `F`：贝斯
- `J`：合成器
- `K`：主旋律

让移动音符到达白色判定线时按下对应按键。当前原型使用程序生成的提示音，找到合适的电子流行分轨音乐后再接入正式音轨。

## 测试

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/run_tests.gd
```

设计与实施计划位于 `docs/plans/`。

