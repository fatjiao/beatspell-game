# Observatory visual direction

Replace geometric placeholders with three original painted assets: moonlit observatory, androgynous caster, and brass Resonant Warden. Keep the existing four-beat public ring and input timing behavior.

Palette: ink `#091317`, old brass `#b9a474`, ivory `#e9e1ca`, muted sage `#8b9f9c`, teal `#75c7bb`, ember `#e79c73`.

HUD: thin metallic frames, small corner pins, compact spell sigils, segmented health bars and a smaller footer. Spell cards occupy y=141–168, leaving more room for character artwork. Attack cue rail sits at y=130 below the Warden. Central ring has a brass minute scale and a dark translucent face so timing feedback stays legible.

Title: layered environment and characters, serif wordmark, three ritual sigils and a single framed start action. Results reuse the same panel ornaments. System fonts are cached to avoid first-frame glyph artifacts.

Verification: existing 16 test groups, imported art, rendered title/battle/warning/rush/pause/result/defeat screenshots, packaged PCK startup. Static painted sprites use breathing/hover translation and cast/hit tint, not skeletal animation.
