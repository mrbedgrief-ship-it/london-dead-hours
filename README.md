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
- First-person movement, collision, camera look, basic weapon view.
- Three hitscan weapon modes with separate magazines and reserve ammunition.
- Basic zombies that pursue and attack the player.
- Searchable loot containers, food/water/medical supplies, survival meters.
- Trader UI for purchasing and selling.
- Inventory, pause, game-over and save/load interface.

## Limitations
This is an early playable foundation. The environment and props are procedurally built rather than high-resolution authored models. Interiors are compact modular spaces. Zombie navigation is direct pursuit rather than full navigation-mesh pathfinding. Audio, full animation, comprehensive world-state persistence and Windows export presets may not be present yet. Source files have not been launched in a local Godot editor in the repository-writing environment; run the first local test below before treating the project as verified.

## Save data
The game stores its save in Godot's user data directory for this project (when save/load is available from the UI).

## Export a Windows build
1. Open the project in Godot.
2. From the top menu, choose **Editor → Manage Export Templates**.
3. If templates are missing, install the matching 4.7.2 templates in that dialog.
4. Choose **Project → Export** and add a **Windows Desktop** preset.
5. Choose an output location and click **Export Project**.

## First local test
Run the project with F5. Confirm that the main menu appears, start a new game, and test WASD + mouse movement. Walk to a marked supply container, press E, then press Tab to check inventory. This first pass verifies startup, input and interaction before testing combat and trading.
