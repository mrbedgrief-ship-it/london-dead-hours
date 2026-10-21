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

## Candidate packs checked for this milestone — not integrated

The official pack pages were checked for the published asset counts/formats and license statements. The actual ZIP archives could not be downloaded or inspected in the current environment (outbound downloads fail with DNS/network errors), so no model, animation, or sound from these packs is present in the repository. They must not be treated as integrated assets.

### Character and animation candidates
- **Zombie Apocalypse Kit — Quaternius** — https://quaternius.com/packs/zombieapocalypsekit.html — official page advertises 60 models, including animated characters/enemies and vehicles; FBX, OBJ, Blend and glTF; page displays CC0/free personal and commercial use. Not downloaded or integrated.
- **Animated Zombie Pack — Quaternius** — https://quaternius.com/packs/animatedzombie.html — official page advertises two textured animated zombie models; FBX, OBJ and Blend; page displays CC0/free personal and commercial use. Not downloaded or integrated.
- **Universal Animation Library 2 — Quaternius** — https://quaternius.com/packs/universalanimationlibrary2.html — official page advertises 130+ humanoid animations, with FBX, GLB and Blend and an engine-compatible export option; page states CC0/free personal, educational and commercial use. Actual animation names/skeleton compatibility were not inspected because the archive was unavailable. Not downloaded or integrated.

### Environment candidates
- **Downtown City MegaKit — Quaternius** — https://quaternius.com/packs/downtowncitymegakit.html — official page advertises 315 modular city pieces, FBX, Blend and glTF, plus a Godot source project option; page states CC0/free personal, educational and commercial use. Not downloaded or integrated.
- **Modular Buildings — Kenney** — https://kenney.nl/assets/modular-buildings — official page lists 100+ files and Creative Commons CC0. The archive contents and model style were not inspected. Not downloaded or integrated.
- **Ultimate Buildings Pack — Quaternius** — https://quaternius.com/packs/ultimatetexturedbuildings.html — official page advertises 76 modular building models in FBX, OBJ and Blend and states CC0/free personal and commercial use. Not downloaded or integrated.

### Audio candidates
- **RPG Audio — Kenney** — https://kenney.nl/assets/rpg-audio — official page lists 50 files and Creative Commons CC0. Not downloaded or integrated.
- **Impact Sounds — Kenney** — https://kenney.nl/assets/impact-sounds — official page lists 130 files and Creative Commons CC0. Not downloaded or integrated.
- **Interface Sounds — Kenney** — https://kenney.nl/assets/interface-sounds — official page lists 100 files and Creative Commons CC0. Not downloaded or integrated.

No sound files have been added, and the current project does not yet play weapon, zombie, player, ambience or UI sound effects. The muzzle flash and hit particles described in the README are procedural visual effects, not imported audio/asset-pack content.
