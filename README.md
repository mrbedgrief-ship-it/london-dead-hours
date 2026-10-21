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
- Procedural London-inspired street environment and buildings.
- First-person movement and clamped mouse-look; mouse capture is restored on resume and recaptured with a gameplay click if needed.
- Distinct visible pistol, shotgun and rifle models, aim-down-sights FOV, centered crosshair, hitscan shooting, per-weapon magazines/reserves, and reload timers.
- Three weapons with separate damage, range, fire rate, magazine capacity, reserve ammunition, reload time, and shotgun pellet spread.
- Zombies with health and one-shot-at-a-time hitscan damage; they stop pursuing and attacking while paused and stop permanently on death.
- Searchable loot containers, food/water/medical supplies, survival meters.
- Trader UI for purchasing and selling.
- Inventory, pause, game-over and save/load interface.

## Limitations
This is an early playable foundation. The environment and props are procedurally built rather than high-resolution authored models. Interiors are compact modular spaces. Zombie navigation is direct pursuit rather than full navigation-mesh pathfinding. Audio, full animation, comprehensive world-state persistence and Windows export presets may not be present yet. Source files have not been launched in a local Godot editor in the repository-writing environment; run the first local test below before treating the project as verified.

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
