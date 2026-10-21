extends StaticBody3D

@export var title := "Supply Crate"
@export var item_id := "food"
@export var quantity := 1
@export var kind := "loot"
var searched := false
var door_open := false
var door_pivot: Node3D

func get_prompt() -> String:
	if kind == "trader": return "E — Trade with Trader"
	if kind == "door": return "E — " + ("Close " if door_open else "Open ") + title
	if searched: return title + " — Empty"
	return "E — Search " + title

func interact(player: CharacterBody3D) -> void:
	var game = get_tree().current_scene
	if kind == "trader":
		game.call("open_trader")
		return
	if kind == "door":
		door_open = not door_open
		if door_pivot:
			door_pivot.rotation.y = -1.25 if door_open else 0.0
		return
	if searched:
		game.call("notify", "Nothing left here.")
		return
	searched = true
	if item_id == "money":
		player.money += quantity
		game.call("notify", "Found £" + str(quantity))
	else:
		player.inventory[item_id] = int(player.inventory.get(item_id, 0)) + quantity
		game.call("notify", "Found " + str(quantity) + " × " + item_id.replace("_", " "))
	game.call("update_hud", player)
