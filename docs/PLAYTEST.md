# Beatspell v0.7.0 试玩说明 / Playtest notes

更新日期：2026-11-12。当前有两位 Boss、四种正式战斗模式和五种防御训练。完整规则见[中文指南](GAMEPLAY.md)或 [English guide](GAMEPLAY.en.md)；第一次试玩先不阅读术式配方，保留对游戏内教学的真实第一反应。

## 开始前 / Before playing

解压并启动 `Launch Beatspell.cmd`。按 O 检查语言，上下选择“语言 / LANGUAGE”，左右切换自动／中文／English。记录电脑、输入设备、音频输出和校准偏移。建议先用有线耳机或扬声器；声音与操作明显错位时可按 C 校准，并记录调整前后差异。校准会离开当前单局，应在开始统计的尝试前完成。

Launch the portable build, select your language with O, and note your input device, audio output and calibration offset. Try the in-game teaching before reading spell recipes. If calibration is needed, do it before a recorded attempt: C leaves the current run.

## 建议顺序 / Suggested sequence

1. 标题左右选择仪式 Ritual，完整玩到第一次胜利、失败或超时。先观察游戏内教学，不要提前背配方；结束后记录胜负、Rank 和平均偏差。
2. 此时再查看操作表或 H 手册。可按 T 练习三种术式；课程完成后再按 T 进入防御训练，体验标准、切分、Rush、回声 Echo 和反拍 Offbeat。左右切换节奏，Tab 查看报告。
3. 再完整玩一次仪式，记录同样的数据，比较自己对起手、早晚和格挡的理解是否变化。
4. 标题选择棱镜 Prism，完成至少一次尝试，愿意继续时再玩第二次。观察护甲／开放状态和新的预警，记录第一次理解它们的时刻。决斗 Duel、试炼 Gauntlet 可作为后续对照，不必一次完成全部模式。
5. 在无需保留成绩的战斗或练习中，切出窗口再切回，观察是否保持暂停。按 P 开始三拍恢复，中途试一次 P 或 Esc 取消，再按 P 等倒计时结束，记录是否容易重新跟上节拍。
6. 标题或结算按 V 查看战绩簿，核对对应模式的场次、胜场和徽章。主动返回标题、重开或练习不计正式场次；高评级失败不应授予胜利徽章。

Play Ritual once without a recipe guide, optionally practice, then play Ritual again. Next try Prism and note when its armor/open states and new warnings become understandable. Test focus loss and the cancellable three-beat resume in a disposable run. Use V to compare records and victory badges. Duel and Gauntlet are optional comparisons.

## 操作表 / Controls

| 输入 / Input | 功能 / Action |
|---|---|
| `D/F` | 动作 / Step |
| `J/K` | 结束术式；标题开始 / Finish spell; start from title |
| Enter/Space | 标题开始 / Start from title |
| `P` | 暂停／三拍恢复；恢复中再次按 P 取消 / Pause; three-beat resume; cancel while resuming |
| `R` | 重开本局；练习重置课程 / Restart; reset practice lessons |
| `C` | 离开本局进入校准 / Leave the run for calibration |
| `T` | 标题进入练习；课程完成后切换自由练习与防御训练 / Practice; toggle drills after lessons |
| 左右键 / Left–Right | 标题选四种模式；训练中排队切换五种节奏 / Select encounter; queue a drill pattern |
| `Tab` | 训练报告；Tab/Esc 关闭到暂停页，P 恢复 / Training report; close to pause, then P to resume |
| `V` | 标题／结算打开战绩簿；V/Esc 关闭 / Record book from title/results; V/Esc closes |
| `H` | 术式手册 / Spellbook |
| `O` | 音乐、音效、震动、全屏和语言设置 / Audio, shake, fullscreen and language options |
| `Esc` | 回标题；标题退出；恢复倒计时中取消恢复 / Return to title; quit from title; cancel resume count-in |

切出窗口会暂停进行中的战斗、开局倒计时和练习；切回不会自动继续。P 恢复倒计时为三拍、1500ms，不消耗战斗时间，结束后继续原音乐相位。

Focus loss pauses active play, including the opening count-in and practice. Returning never resumes automatically. P starts a three-beat, 1.5-second resume count-in without advancing the battle timer or music position.

## 试玩反馈 / Feedback

先记录实际发生的情况，再说明希望如何改进。能提供模式、大致时间、按键和截图时更有帮助。

Record what happened before suggesting a fix. Include the encounter, approximate time, key pressed and a screenshot when useful.

1. 首次是否知道何时可以起手？圆环能否表达按早或按晚？ / When could you begin a spell, and could you read early/late timing?
2. 第几次尝试学会三个术式？教学有没有在没看懂时就进入下一段？ / How long did learning take, and did lessons advance before you understood them?
3. 五种预警中，哪些能只靠声音辨认？回声或反拍哪里最容易误判命中时间？ / Which warnings could you identify by sound, and where were Echo or Offbeat unclear?
4. 棱镜护甲／开放是否可辨？何时注意到伤害变化，是否因此改变施法选择？ / Could you distinguish armor/open states, and did damage changes affect your choices?
5. 攻击前是否来得及准备护盾？精准格挡、破防、共鸣中哪一项最难理解？ / Could you shield in time, and which guard/break/resonance rule was hardest to understand?
6. 五种训练及报告能否解释失误？“护盾过早／良好护盾／未有护盾”是否符合实际？ / Did drills and their last-outcome explanations help identify mistakes?
7. 切出／切回是否漏暂停或突然继续？三拍恢复能否接上拍感，取消是否清楚？ / Did focus changes pause safely, and was resuming or cancelling clear?
8. 战绩和徽章是否正确？是否理解最佳评级可来自失败，A／S 胜利徽章必须获胜？ / Did records match your runs, and was best rhythm rank distinct from victory badges?
9. 两种语言有没有缺字、溢出或容易误解的词？ / Did either language have missing glyphs, clipping or unclear wording?
10. 哪次失败最像没有解释清楚？哪个画面或声音最影响注意力？如果只改一处，你选什么？ / Which failure felt unexplained, what distracted you, and what single change would help?

## 记录模板 / Notes template

```text
版本 / Build: v0.7.0
电脑、输入设备 / Computer and input device:
音频设备、有线/蓝牙 / Audio output, wired/Bluetooth:
语言 / Language:
校准偏移及是否调整 / Calibration offset and changes:
仪式第一次 / Ritual 1: 胜/负/超时，Rank，平均偏差，完成/中断
仪式第二次 / Ritual 2: 胜/负/超时，Rank，平均偏差，完成/中断
棱镜第一次 / Prism 1: 胜/负/超时，Rank，平均偏差，完成/中断
棱镜第二次（可选）/ Prism 2 (optional):
练过的防御节奏 / Defense patterns tried:
护甲/开放首次理解时刻 / When armor/open became clear:
切出暂停和三拍恢复情况 / Focus pause and resume observations:
战绩/徽章是否正确 / Records and badges:
语言或画面问题 / Language or layout issue:
最困惑 / Most confusing:
最喜欢 / Favorite part:
最想改 / Most wanted change:
```
