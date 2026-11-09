# Beatspell — Observatory art pass

Created 2026-11-09 with the built-in imagegen tool. Three original generated assets are used by the battle and title screens. Caster and Warden retain their generated alpha transparency. Images were copied into this folder without raster editing.

- `observatory.png`: moonlit ruined observatory background.
- `caster.png`: androgynous teal-robed spellcaster facing right.
- `warden.png`: bronze bell construct facing left.

The title uses a system serif font with Georgia / Noto Serif fallback. No Windows font files are redistributed. The HUD uses Godot's bundled fallback font. Procedural UI ornaments, spell sigils, shadows and animation are in `scripts/beatspell/art_direction.gd`, `beatspell_battle.gd` and `battle_overlay.gd`.

## Final generation prompts

### Observatory

Use case: stylized-concept. Asset type: 16:9 game background plate for an original 2D rhythm magic boss fight. Paint a beautiful abandoned astral observatory, enormous broken circular brass astrolabe behind a distant arch, moonlit deep indigo architecture, misty turquoise stone floor and restrained warm gold lantern light. Hand painted premium indie game environment, textured brushwork, elegant dark fantasy, NOT pixel art, NOT neon sci fi. Side view combat staging: clear stone platforms at left and right, center open and subdued for a circular rhythm HUD. Architecture detailed near edges and soft behind gameplay. No characters, no monsters, no text, no UI, no logos. Wide landscape 1536x864 composition.

### Caster

Use case: stylized-concept. Asset type: transparent isolated full-body 2D game character sprite. Original androgynous young spellcaster, three-quarter side view facing RIGHT, confident low combat stance, short ash-white hair, charcoal teal hooded traveling coat with layered fabric, fine antique brass fastenings, wrapped boots, one hand conjuring a small teal orb, other hand holding an ornate short tuning-fork wand. Hand-painted premium indie dark-fantasy art with readable strong silhouette, warm ivory highlights and restrained teal magic, textured illustrative brushwork, no pixel art. Full figure including boots and wand with small transparent margins, no ground, no cast shadow, no surrounding scenery, no text, no logos. Genuine alpha transparent background.

### Warden

Use case: stylized-concept. Asset type: transparent isolated 2D game boss sprite. Original creature called the Resonant Warden: a hovering ancient bronze and obsidian bell-shaped armored construct with a single glowing amber core eye, two long curved broken crescent horns, layered hanging metal plates and floating stone fragments, faint red-orange energy between its cracks. Facing LEFT in a three-quarter combat pose, wide imposing silhouette, floating lower body, no legs needed. Hand-painted premium indie dark-fantasy art, textured worn brass, sharp readable shapes, dramatic warm ivory highlights and black teal shadows. Full creature entirely in frame with small transparent margins. No background, no floor, no cast shadow, no text, no UI, no logos. Genuine alpha transparent background.
