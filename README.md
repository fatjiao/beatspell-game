# One Person Band Demo

《一个人的乐队》轻音游 Demo。当前版本包含地下通道舞台、四键乐器切换、电子流行分轨、节拍判定、音频校准和宽松失败机制。

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
- `Tab`：切换舞台视图 / 四轨调试视图
- `P`：暂停 / 继续
- `R`：立即重新开始；结算后再演奏一次
- `C`：打开音频延迟校准

观察脉冲沿中央节拍线移动，在它抵达右侧大按键时按下对应按键。舞台一次只突出当前乐器，最后合奏段才会在 D/F/J/K 之间轮换。鼓点驱动地面波纹，贝斯、合成器和主旋律会继续点亮灯光并吸引路人；曲目结束后显示成绩、准确率和评级。

首次使用蓝牙耳机或更换音频设备后，建议按 `C` 进入校准，跟随节拍按八次 `D`，再按 Enter 保存。

## 测试

```powershell
& '.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/run_tests.gd
```

设计与实施计划位于 `docs/plans/`。
