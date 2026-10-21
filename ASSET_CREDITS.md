# LONDON: DEAD HOURS — Asset Credits and License Notes

## Assets included in the repository

### Original project textures (created for LONDON: DEAD HOURS)
- `assets/textures/soho_brick.svg` — hand-authored, tileable weathered brick pattern.
- `assets/textures/soho_asphalt.svg` — hand-authored, tileable damp asphalt pattern.
- `assets/textures/soho_paving.svg` — hand-authored, tileable worn paving slabs.

These SVGs were created for this repository and do not contain third-party images or runtime links. They are original project assets, not a downloaded third-party pack. They are included locally and referenced by `scripts/game.gd`.

## External asset source researched, not integrated

### Poly Haven
- Source: https://polyhaven.com/
- License information: https://polyhaven.com/license
- Relevant catalog: https://polyhaven.com/textures
- License: Poly Haven states that its downloaded textures, HDRIs and 3D models are released under CC0, permitting commercial use and redistribution without a mandatory attribution requirement.
- Status in this project: **researched, not integrated**. No Poly Haven files are included or referenced by the game. The current changes use local project-created textures instead, because this environment cannot run Godot 4.7.2 to verify a downloaded asset pack's import settings and visual results. No claim is made that a Poly Haven asset is present in the game.

## Additional free packs reviewed, not integrated

### Quaternius — Zombie Apocalypse Kit
- Source: https://quaternius.com/packs/zombieapocalypsekit.html
- Creator: Quaternius (the creator's name is shown on the source site).
- License: CC0 badge on the official pack page; the page says it is free for personal and commercial projects.
- Published contents: 60 models, including animated characters, enemies, environment and vehicle models; FBX, OBJ, Blend and glTF formats.
- Integration status: **not included**. The pack's stylized low-poly art direction would clash with the intended grounded urban look unless the rest of the character/environment art was adapted around it. I also could not download, inspect the archive contents or validate its import in Godot from this environment.

### Quaternius — Animated Zombie Pack
- Source: https://quaternius.com/packs/animatedzombie.html
- Creator: Quaternius.
- License: CC0 badge on the official pack page; the page says it is free for personal and commercial projects.
- Published contents: two textured animated zombie models; FBX, OBJ and Blend formats.
- Integration status: **not included**. No archive was imported or referenced, and compatibility of the specific rig/animations with the existing enemy script was not tested.

### Kenney — City Kit (Suburban)
- Source: https://kenney.nl/assets/city-kit-suburban
- Creator: Kenney.
- License: Creative Commons CC0, as stated on the official page.
- Published contents: 40 3D city assets.
- Integration status: **not included**. Its clean, stylized suburban architecture does not match the weathered Soho brick target closely enough to justify mixing it into this pass.

### Poly Haven
- Source: https://polyhaven.com/
- License information: https://polyhaven.com/license
- Relevant catalog: https://polyhaven.com/textures
- License: Poly Haven states that its downloaded textures, HDRIs and 3D models are released under CC0, permitting commercial use and redistribution without mandatory attribution.
- Integration status: **researched, not integrated**. The new local SVG textures are original project artwork; no Poly Haven file is present or referenced.

No third-party character, animation, weapon, vehicle, furniture or environment pack was added in this pass. No external URL is accessed at runtime, and no plugin or runtime dependency was added.

## Attribution and license maintenance
If an external asset pack is added in a future pass, record the exact asset/page, creator, license version, attribution text (if any), included file paths and any redistribution restrictions here before merging it into the game.
