extends CharacterBody3D

const WALK_SPEED := 4.2
const SPRINT_SPEED := 6.5
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.0018

var health := 100.0
var hunger := 100.0
var thirst := 100.0
var money := 35
var inventory: Dictionary = {"food": 2, "water": 2, "medkit": 1, "scrap": 0}
var weapon := "Pistol"
var ammo := {"Pistol": 12, "Shotgun": 6, "Rifle": 30}
var reserve := {"Pistol": 36, "Shotgun": 8, "Rifle": 30}
var magazine := {"Pistol": 12, "Shotgun": 6, "Rifle": 30}
var fire_delay := 0.0
var reload_delay := 0.0
var inv_open := false
var dead := false
var camera: Camera3D
var ray: RayCast3D
var gun: MeshInstance3D
var game: Node3D

func _ready() -> void:
	game = get_parent()
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.36
	shape.height = 1.75
	col.shape = shape
	col.position.y = 0.88
	add_child(col)
	camera = Camera3D.new()
	camera.position.y = 1.58
	camera.fov = 78.0
	add_child(camera)
	ray = RayCast3D.new()
	ray.target_position = Vector3(0, 0, -3.2)
	ray.collide_with_areas = true
	camera.add_child(ray)
	var gun_mesh := BoxMesh.new()
	gun_mesh.size = Vector3(0.18, 0.15, 0.48)
	gun = MeshInstance3D.new()
	gun.mesh = gun_mesh
	gun.position = Vector3(0.32, -0.28, -0.55)
	gun.material_override = game.mat_gun
	camera.add_child(gun)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not inv_open:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -1.45, 1.45)
	if event.is_action_pressed("pause"):
		game.toggle_pause()
	if event.is_action_pressed("inventory"):
		game.toggle_inventory()
	if event.is_action_pressed("interact") and not inv_open and not game.paused:
		_interact()
	if event.is_action_pressed("reload"):
		_reload()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_fire()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		camera.fov = 62.0
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		camera.fov = 78.0
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1: _equip("Pistol")
		elif event.keycode == KEY_2: _equip("Shotgun")
		elif event.keycode == KEY_3: _equip("Rifle")

func _physics_process(delta: float) -> void:
	if dead or game.paused or inv_open:
		velocity = Vector3.ZERO
		return
	fire_delay = maxf(0.0, fire_delay - delta)
	reload_delay = maxf(0.0, reload_delay - delta)
	hunger = maxf(0.0, hunger - delta * 0.12)
	thirst = maxf(0.0, thirst - delta * 0.18)
	if hunger <= 0.0 or thirst <= 0.0:
		health -= delta * 0.8
	if health <= 0.0:
		dead = true
		game.show_game_over()
	var direction_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(direction_input.x, 0, direction_input.y)).normalized()
	var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, 14.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 14.0 * delta)
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	move_and_slide()
	if ray.is_colliding():
		var target = ray.get_collider()
		if target != null and target.has_method("get_prompt"):
			game.set_prompt(target.get_prompt())
		else:
			game.set_prompt("")
	else:
		game.set_prompt("")
	game.update_hud(self)

func _interact() -> void:
	ray.force_raycast_update()
	if ray.is_colliding():
		var target = ray.get_collider()
		if target != null and target.has_method("interact"):
			target.interact(self)

func _fire() -> void:
	if game.paused or inv_open or dead or fire_delay > 0.0 or reload_delay > 0.0:
		return
	if int(ammo[weapon]) <= 0:
		game.notify("Magazine empty — press R to reload")
		return
	ammo[weapon] = int(ammo[weapon]) - 1
	fire_delay = 0.32 if weapon == "Pistol" else (0.85 if weapon == "Shotgun" else 0.12)
	ray.target_position = Vector3(0, 0, - (24.0 if weapon == "Rifle" else (10.0 if weapon == "Shotgun" else 18.0)))
	ray.force_raycast_update()
	if ray.is_colliding():
		var target = ray.get_collider()
		if target != null and target.has_method("take_damage"):
			target.take_damage(38.0 if weapon == "Shotgun" else (25.0 if weapon == "Rifle" else 34.0))
	game.notify("Fired " + weapon)
	gun.position.x = 0.30
	await get_tree().create_timer(0.06).timeout
	if is_instance_valid(gun):
		gun.position.x = 0.32

func _reload() -> void:
	if reload_delay > 0.0 or int(ammo[weapon]) >= int(magazine[weapon]) or int(reserve[weapon]) <= 0:
		return
	reload_delay = 1.1 if weapon != "Shotgun" else 1.5
	game.notify("Reloading...")
	await get_tree().create_timer(reload_delay).timeout
	if not is_instance_valid(self): return
	var needed := int(magazine[weapon]) - int(ammo[weapon])
	var loaded := mini(needed, int(reserve[weapon]))
	ammo[weapon] = int(ammo[weapon]) + loaded
	reserve[weapon] = int(reserve[weapon]) - loaded

func _equip(name: String) -> void:
	weapon = name
	game.notify("Equipped " + name)

func hurt(amount: float) -> void:
	if dead or game.paused: return
	health = maxf(0.0, health - amount)
	game.notify("You are hurt!")
	if health <= 0.0:
		dead = true
		game.show_game_over()

func use_item(item_id: String) -> void:
	if int(inventory.get(item_id, 0)) <= 0:
		game.notify("You don't have that item.")
		return
	if item_id == "food":
		hunger = minf(100.0, hunger + 35.0)
	elif item_id == "water":
		thirst = minf(100.0, thirst + 40.0)
	elif item_id == "medkit":
		health = minf(100.0, health + 45.0)
	else:
		game.notify("That item cannot be used.")
		return
	inventory[item_id] = int(inventory[item_id]) - 1
	game.notify("Used " + item_id.replace("_", " "))
	game.toggle_inventory(true)
