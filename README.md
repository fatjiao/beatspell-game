# One Person Band Demo

《一个人的乐队》轻音游技术原型。当前版本用于验证四键乐器切换、节拍判定、连续演奏和宽松失败机制。

## 运行

直接双击 `启动游戏.cmd`。这个启动器不依赖 PowerShell 执行策略；如果启动失败，窗口会保留并显示错误。

也可以在 PowerShell 中执行：

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64.exe' --path .
```

## 操作

- `D`：电子鼓
- `F`：贝斯
- `J`：合成器
- `K`：主旋律
- `C`：打开音频延迟校准

让移动音符到达白色判定线时按下对应按键。当前原型使用程序生成的提示音，找到合适的电子流行分轨音乐后再接入正式音轨。

首次使用蓝牙耳机或更换音频设备后，建议按 `C` 进入校准，跟随节拍按八次 `D`，再按 Enter 保存。

## 测试

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/run_tests.gd
```

设计与实施计划位于 `docs/plans/`。
