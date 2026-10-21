# LONDON: DEAD HOURS

A compact, atmospheric first-person survival-horror game set in a fictionalized abandoned Soho, London. The project uses procedural Godot geometry and built-in materials, so no external asset packs are required.

## Requirements
- Godot Engine 4.7.2 (standard Windows editor).
- No terminal, Python, plugins, or downloaded asset packs required.

## Open and run on Windows
1. Open **Godot Engine 4.7.2**.
2. In the Project Manager, click **Import**.
3. Browse to the folder containing this repository and select **project.godot**.
4. Click **Import & Edit**.
5. Wait for the project to finish importing, then press **F6** only if you have selected a scene; otherwise press **F5** (Run Project).
6. If Godot asks to confirm the main scene, choose `scenes/main.tscn`.

## Controls
- **W / A / S / D** — move
- **Mouse** — look around
- **Shift** — sprint
- **Space** — jump
- **E** — interact/search/trade
- **Left mouse** — fire
- **Right mouse** — aim
- **R** — reload
- **1 / 2 / 3** — pistol / shotgun / rifle
- **Tab** — inventory
- **Esc** — pause/resume

## Current implementation
- Preserved the original compact playable street layout, upgraded with dark brick facades, framed/recessed and selectively boarded windows, blocked entrances, cornices, parapets, drainpipes and masonry plinths.
- Original tileable SVG textures for weathered brick, damp asphalt and worn pavement; restrained roughness and UV tiling, plus cold overcast lighting, fog, wet-road sheen, kerbs, faded yellow lines, drains, leaves, detailed abandoned vehicles and static street lamps.
- The existing mini-market and gun shop now have open doorways, collision-safe shop floors, glazing, shelves, display racks and counters. One residential building has a traversable furnished room with a bed, wardrobe, kitchen counter and dining table.
- Reusable multi-part loot visuals (wooden crates, metal cases, cabinets and shop shelves) while retaining each original searchable interaction body.
- A recognizable segmented human trader in practical survival clothing, backpack and boots; original trader interaction/collision body retained.
- Clear health, hunger and thirst bars; cash and weapon/ammunition readout; dark inventory panel with item categories, descriptions and USE actions.
- Brief timed first-start control hints and a Controls page accessible from the pause menu.
- First-person movement and clamped mouse-look; mouse capture is restored on resume and recaptured with a gameplay click if needed.
- Distinct visible pistol, shotgun and rifle models, aim-down-sights FOV, centered crosshair, hitscan shooting, per-weapon magazines/reserves, and reload timers.
- Three weapons with separate damage, range, fire rate, magazine capacity, reserve ammunition, reload time, and shotgun pellet spread.
- Rounded low-cost humanoid zombie meshes with separate anatomy, ragged clothing details, procedural gait and a more distinct runner variant. Visual meshes do not have collision, so weapon rays still hit the gameplay body.
- Controlled zombie respawning: maintains a target of 6 living zombies with a hard safety cap of 8. Respawn candidates are selected from fixed street-side points, filtered by distance, safe-zone distance, nearby zombies and line-of-sight checks. Respawns are delayed by 16–24 seconds and retried more slowly when no valid point is available.
- Dead zombies stop moving and attacking, lose their gameplay collision and are removed after 24 seconds. Looted container titles are saved and restored; old version-1 saves remain loadable.
- Searchable loot containers, food/water/medical supplies, survival meters.
- Trader UI for purchasing and selling.
- Inventory, pause, game-over and save/load interface. Food, water and medical kits apply real hunger/thirst/health effects and consume one item; trading refreshes stock, cash and prices after successful transactions.

## Limitations
This remains a small procedural survival-game project, not a AAA asset-based production. No third-party asset pack was imported in this pass; the new textures are original in-repository SVG artwork, and researched asset sources/licensing are recorded in ASSET_CREDITS.md. The three interiors are simple procedural shells and furnishings rather than detailed, fully textured rooms. Zombies use direct pursuit and procedural limb motion rather than navigation-mesh pathfinding or imported skeletal animation. Audio, advanced animation and complete world-state persistence (including live zombie positions and trader stock) remain incomplete. Godot was not available in the repository-writing environment, so runtime compilation and play testing still need to be done locally.

## Save data
The game stores `user://dead_hours_save.json` in Godot's user-data directory. Save data includes version, money, health, hunger, thirst, inventory quantities (`food`, `water`, `medkit`, `scrap`), selected weapon, each weapon's magazine and reserve ammunition, and player position. Invalid/missing values are validated or defaulted on load; a missing save does not start a false load.

## Export a Windows build
1. Open the project in Godot.
2. From the top menu, choose **Editor → Manage Export Templates**.
3. If templates are missing, install the matching 4.7.2 templates in that dialog.
4. Choose **Project → Export** and add a **Windows Desktop** preset.
5. Choose an output location and click **Export Project**.

## First local test
Run the project with F5. Confirm that the main menu appears, start a new game, and test WASD + mouse movement. Walk to a marked supply container, press E, then press Tab to check inventory. This first pass verifies startup, input and interaction before testing combat and trading.
