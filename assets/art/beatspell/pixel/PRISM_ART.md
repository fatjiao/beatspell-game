# Prism Warden / 棱镜守卫素材来源

项目素材：`assets/art/beatspell/pixel/prism_warden.png`。这是 Beatspell 第二 Boss 的原创透明背景图，由内置 `image_gen` 图像工具于 **2026-11-12** 生成，`transparent_background` 为 `true`，使用生成结果原有的透明 alpha。未使用 CLI/API 回退路径。

原始输出：`C:\Users\ZhuanZ\.codex\generated_images\01a1a9d1-5034-7fa3-8071-f6f44e6c36b6\exec-3425afe0-6199-441a-9317-4692976d98df.png`。该输出未经图像修改复制到上述项目路径，运行时不依赖用户目录中的原始副本。此记录不改变 `poses/` 下原六张本地派生姿态帧的来源。

项目 PNG 实际为 **1199×1312，RGBA**，SHA-256 为 `97ba6030264346d3be67106dabb9d309b73b6d511e164ed61e691cc72b228025`；已逐字节确认与原始输出相同。提示词中的 64×80 是缩小后的可读性目标，不能称为实际 64×80 原生精灵。游戏在 320×180 viewport 中以最近邻方式绘制约 92×105 的角色区域，并用程序绘制周围晶体轨道与护甲状态标签；这些程序效果不属于生成 PNG，也不代表存在多张生成的动作帧。

## Final prompt / 实际最终提示词

```text
Create a production-ready sprite asset for an original 16-bit pixel art rhythm game called Beatspell. Transparent background. One single full-body front-facing PRISM WARDEN, an ancient floating geometric armored guardian, dark indigo metal with lavender crystal plates, cyan glowing diamond core, four detached crystalline shoulder shards, segmented golden outline accents, hovering tapered lower body. Symmetric readable silhouette. Sharp chunky pixels, limited 16-color palette, no antialiasing, no smooth gradients, no text, no floor, no shadows outside creature. The design must remain readable when reduced to 64 by 80 logical pixels in a 320x180 game. Center creature with generous transparent margin, no cropping. Calm idle stance with open arms. Original creature, no references to existing franchises.
```

后续替换或编辑该素材时，保留本记录并补充新文件名、使用的工具、输入来源、实际提示词及图像变更；不要将再次生成描述为确定性重建。
