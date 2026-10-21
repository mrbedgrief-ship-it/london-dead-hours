extends CharacterBody3D

const WALK_SPEED := 4.2
const SPRINT_SPEED := 6.5
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.0018
const NORMAL_FOV := 78.0
const AIM_FOV := 62.0

const WEAPON_CONFIG := {
	"Pistol": {"capacity": 12, "damage": 34.0, "fire_interval": 0.32, "reload_time": 1.1, "range": 45.0, "pellets": 1, "spread": 0.002},
	"Shotgun": {"capacity": 6, "damage": 13.0, "fire_interval": 0.85, "reload_time": 1.5, "range": 22.0, "pellets": 7, "spread": 0.055},
	"Rifle": {"capacity": 30, "damage": 25.0, "fire_interval": 0.12, "reload_time": 1.7, "range": 65.0, "pellets": 1, "spread": 0.004}
}

var health := 100.0
var hunger := 100.0
var thirst := 100.0
var money := 35
var inventory: Dictionary = {"food": 2, "water": 2, "medkit": 1, "scrap": 0}
var weapon := "Pistol"
# ammo is the number of rounds currently in each weapon's magazine.
var ammo: Dictionary = {"Pistol": 12, "Shotgun": 6, "Rifle": 30}
var reserve: Dictionary = {"Pistol": 36, "Shotgun": 8, "Rifle": 30}
var magazine: Dictionary = {"Pistol": 12, "Shotgun": 6, "Rifle": 30}
var fire_delay := 0.0
var reload_delay := 0.0
var reloading_weapon := ""
var aiming := false
var inv_open := false
var dead := false
var camera: Camera3D
var ray: RayCast3D
var weapon_root: Node3D
var weapon_models: Dictionary = {}
var game
var movement_clock: float = 0.0
var viewmodel_sway: Vector2 = Vector2.ZERO
var weapon_kick: float = 0.0
var recoil_return: float = 0.0
var reload_visual_time: float = 0.0
var muzzle_flash_time: float = 0.0
var muzzle_flash: MeshInstance3D
var damage_flash_time: float = 0.0
var damage_overlay: ColorRect

func _ready() -> void:
	game = get_parent()
	_build_player_collision()
	_build_camera()
	_build_weapon_models()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_player_collision() -> void:
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.36
	shape.height = 1.75
	col.shape = shape
	col.position.y = 0.88
	add_child(col)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "FirstPersonCamera"
	camera.position = Vector3(0.0, 1.58, 0.0)
	camera.fov = NORMAL_FOV
	camera.current = true
	add_child(camera)
	ray = RayCast3D.new()
	ray.name = "AimRay"
	ray.target_position = Vector3(0.0, 0.0, -3.0)
	ray.collide_with_areas = true
	ray.collide_with_bodies = true
	ray.enabled = true
	ray.add_exception(self)
	camera.add_child(ray)
	var feedback_layer := CanvasLayer.new()
	feedback_layer.name = "DamageFeedbackLayer"
	add_child(feedback_layer)
	damage_overlay = ColorRect.new()
	damage_overlay.name = "DamageFlash"
	damage_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_overlay.color = Color(0.42, 0.025, 0.015, 0.0)
	feedback_layer.add_child(damage_overlay)

func _build_weapon_models() -> void:
	weapon_root = Node3D.new()
	weapon_root.name = "FirstPersonWeapon"
	weapon_root.position = Vector3.ZERO
	camera.add_child(weapon_root)
	_build_viewmodel_arms()

	var pistol := Node3D.new()
	pistol.name = "PistolModel"
	_add_weapon_box(pistol, Vector3(0.15, 0.12, 0.30), Vector3(0.29, -0.22, -0.40), game.mat_gun)
	_add_weapon_box(pistol, Vector3(0.10, 0.18, 0.13), Vector3(0.29, -0.34, -0.34), game.mat_metal)
	_add_weapon_box(pistol, Vector3(0.055, 0.045, 0.11), Vector3(0.29, -0.15, -0.56), game.mat_metal)
	_add_weapon_box(pistol, Vector3(0.035, 0.035, 0.18), Vector3(0.29, -0.19, -0.62), game.mat_metal)
	_add_weapon_box(pistol, Vector3(0.06, 0.025, 0.045), Vector3(0.29, -0.13, -0.45), game.mat_metal)
	_add_weapon_box(pistol, Vector3(0.13, 0.035, 0.13), Vector3(0.29, -0.37, -0.32), game.mat_gun)
	weapon_root.add_child(pistol)
	weapon_models["Pistol"] = pistol

	var shotgun := Node3D.new()
	shotgun.name = "ShotgunModel"
	_add_weapon_box(shotgun, Vector3(0.105, 0.095, 0.72), Vector3(0.28, -0.21, -0.63), game.mat_metal)
	_add_weapon_box(shotgun, Vector3(0.17, 0.13, 0.30), Vector3(0.28, -0.23, -0.39), game.mat_gun)
	_add_weapon_box(shotgun, Vector3(0.12, 0.09, 0.22), Vector3(0.28, -0.30, -0.61), game.mat_wood)
	_add_weapon_box(shotgun, Vector3(0.12, 0.13, 0.24), Vector3(0.28, -0.25, -0.18), game.mat_wood)
	_add_weapon_box(shotgun, Vector3(0.09, 0.055, 0.42), Vector3(0.28, -0.25, -0.83), game.mat_metal)
	_add_weapon_box(shotgun, Vector3(0.055, 0.035, 0.12), Vector3(0.28, -0.13, -0.57), game.mat_gun)
	_add_weapon_box(shotgun, Vector3(0.10, 0.10, 0.16), Vector3(0.28, -0.35, -0.40), game.mat_gun)
	weapon_root.add_child(shotgun)
	weapon_models["Shotgun"] = shotgun

	var rifle := Node3D.new()
	rifle.name = "RifleModel"
	_add_weapon_box(rifle, Vector3(0.085, 0.085, 0.78), Vector3(0.28, -0.20, -0.66), game.mat_metal)
	_add_weapon_box(rifle, Vector3(0.16, 0.13, 0.34), Vector3(0.28, -0.23, -0.39), game.mat_gun)
	_add_weapon_box(rifle, Vector3(0.12, 0.14, 0.27), Vector3(0.28, -0.25, -0.13), game.mat_wood)
	_add_weapon_box(rifle, Vector3(0.11, 0.075, 0.21), Vector3(0.28, -0.30, -0.57), game.mat_gun)
	_add_weapon_box(rifle, Vector3(0.045, 0.06, 0.12), Vector3(0.28, -0.13, -0.39), game.mat_metal)
	_add_weapon_box(rifle, Vector3(0.075, 0.08, 0.23), Vector3(0.28, -0.23, -0.92), game.mat_metal)
	_add_weapon_box(rifle, Vector3(0.055, 0.12, 0.10), Vector3(0.28, -0.10, -0.45), game.mat_gun)
	_add_weapon_box(rifle, Vector3(0.11, 0.18, 0.15), Vector3(0.28, -0.35, -0.50), game.mat_gun)
	_add_weapon_box(rifle, Vector3(0.08, 0.05, 0.28), Vector3(0.28, -0.22, -0.03), game.mat_wood)
	weapon_root.add_child(rifle)
	weapon_models["Rifle"] = rifle
	# A small emissive flash is a real scene object, toggled only during firing.
	var flash_material := StandardMaterial3D.new()
	flash_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash_material.albedo_color = Color("#ffcc78")
	flash_material.emission_enabled = true
	flash_material.emission = Color("#ff8b32")
	flash_material.emission_energy_multiplier = 3.0
	muzzle_flash = MeshInstance3D.new()
	muzzle_flash.name = "MuzzleFlash"
	var flash_mesh := SphereMesh.new()
	flash_mesh.radius = 0.055
	flash_mesh.height = 0.11
	muzzle_flash.mesh = flash_mesh
	muzzle_flash.material_override = flash_material
	muzzle_flash.position = Vector3(0.28, -0.18, -0.98)
	muzzle_flash.visible = false
	weapon_root.add_child(muzzle_flash)
	_refresh_weapon_model()

func _build_viewmodel_arms() -> void:
	var sleeve := StandardMaterial3D.new()
	sleeve.albedo_color = Color("#303936")
	sleeve.roughness = 0.94
	var glove := StandardMaterial3D.new()
	glove.albedo_color = Color("#282b29")
	glove.roughness = 0.98
	_add_viewmodel_capsule("LeftSleeve", Vector3(-0.19, -0.39, -0.31), 0.085, 0.43, sleeve, -0.58)
	_add_viewmodel_capsule("RightSleeve", Vector3(0.24, -0.36, -0.31), 0.085, 0.40, sleeve, 0.52)
	_add_viewmodel_capsule("LeftGlove", Vector3(-0.045, -0.30, -0.58), 0.065, 0.16, glove, -0.15)
	_add_viewmodel_capsule("RightGlove", Vector3(0.23, -0.28, -0.56), 0.065, 0.16, glove, 0.12)

func _add_viewmodel_capsule(part_name: String, pos: Vector3, radius: float, height: float, material: Material, roll: float) -> void:
	var part := MeshInstance3D.new()
	part.name = part_name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 10
	mesh.rings = 4
	part.mesh = mesh
	part.position = pos
	part.rotation.z = roll
	part.material_override = material
	part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	weapon_root.add_child(part)

func _add_weapon_box(parent: Node3D, size: Vector3, pos: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mesh_instance)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if _gameplay_active():
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			viewmodel_sway.x = clampf(viewmodel_sway.x - event.relative.x * 0.000035, -0.035, 0.035)
			viewmodel_sway.y = clampf(viewmodel_sway.y + event.relative.y * 0.000035, -0.025, 0.025)
			camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-82.0), deg_to_rad(82.0))
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and _gameplay_active():
				aiming = true
			elif not event.pressed:
				aiming = false
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_instance_valid(game) and not game.paused and not inv_open and not dead and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				get_viewport().set_input_as_handled()
				return
			if _gameplay_active():
				_fire()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.is_action_pressed("pause"):
		if not dead:
			game.toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("inventory"):
		if not dead and (not game.paused or inv_open):
			game.toggle_inventory()
		get_viewport().set_input_as_handled()
		return
	if not _gameplay_active():
		return
	if event.is_action_pressed("interact"):
		_interact()
	elif event.is_action_pressed("reload"):
		_reload()
	elif event.keycode == KEY_1:
		_equip("Pistol")
	elif event.keycode == KEY_2:
		_equip("Shotgun")
	elif event.keycode == KEY_3:
		_equip("Rifle")

func _gameplay_active() -> bool:
	return is_instance_valid(game) and not dead and not game.paused and not inv_open and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if not is_instance_valid(camera):
		return
	var target_fov: float = AIM_FOV if aiming and _gameplay_active() else NORMAL_FOV
	camera.fov = lerpf(camera.fov, target_fov, minf(1.0, delta * 12.0))
	movement_clock += delta * (10.0 if velocity.length() > 3.0 else 6.0)
	weapon_kick = move_toward(weapon_kick, 0.0, delta * 1.8)
	if recoil_return > 0.0:
		var recover: float = minf(recoil_return, delta * 1.8)
		camera.rotation.x = clampf(camera.rotation.x + recover, deg_to_rad(-82.0), deg_to_rad(82.0))
		recoil_return -= recover
	viewmodel_sway = viewmodel_sway.lerp(Vector2.ZERO, minf(1.0, delta * 8.0))
	muzzle_flash_time = maxf(0.0, muzzle_flash_time - delta)
	if muzzle_flash != null:
		muzzle_flash.visible = muzzle_flash_time > 0.0 and not paused_if_gameplay_locked()
	if reload_visual_time > 0.0:
		reload_visual_time = maxf(0.0, reload_visual_time - delta)
	var moving: float = Vector2(velocity.x, velocity.z).length()
	var bob: float = 0.0 if aiming or not _gameplay_active() else sin(movement_clock) * minf(0.018, moving * 0.003)
	var reload_dip: float = 0.0
	if reload_delay > 0.0 and WEAPON_CONFIG.has(weapon):
		var reload_total: float = float(WEAPON_CONFIG[weapon]["reload_time"])
		var progress: float = 1.0 - reload_delay / maxf(0.01, reload_total)
		reload_dip = sin(progress * PI) * 0.20
	if weapon_root != null:
		var aim_offset: Vector3 = Vector3(-0.055, -0.045, 0.10) if aiming else Vector3.ZERO
		weapon_root.position = Vector3(viewmodel_sway.x, bob - reload_dip - (0.015 if aiming else 0.0), weapon_kick + aim_offset.z) + aim_offset
		weapon_root.rotation = Vector3(-weapon_kick * 0.8, viewmodel_sway.x * 0.7, viewmodel_sway.y * 0.65)
	if damage_overlay != null:
		damage_flash_time = maxf(0.0, damage_flash_time - delta)
		var alpha: float = clampf(damage_flash_time / 0.32, 0.0, 1.0) * 0.32
		damage_overlay.color = Color(0.42, 0.025, 0.015, alpha)

func paused_if_gameplay_locked() -> bool:
	return not _gameplay_active()

func _physics_process(delta: float) -> void:
	if dead or game.paused or inv_open:
		velocity = Vector3.ZERO
		return
	fire_delay = maxf(0.0, fire_delay - delta)
	if reload_delay > 0.0:
		reload_delay = maxf(0.0, reload_delay - delta)
		if reload_delay <= 0.0:
			_finish_reload()
	hunger = maxf(0.0, hunger - delta * 0.12)
	thirst = maxf(0.0, thirst - delta * 0.18)
	if hunger <= 0.0 or thirst <= 0.0:
		health -= delta * 0.8
	if health <= 0.0:
		dead = true
		game.show_game_over()
		return

	var direction_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(direction_input.x, 0.0, direction_input.y)).normalized()
	var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	if direction.length_squared() > 0.0:
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
	if not _gameplay_active() or fire_delay > 0.0 or reload_delay > 0.0:
		return
	if not WEAPON_CONFIG.has(weapon):
		game.notify("Weapon unavailable.")
		return
	var config: Dictionary = WEAPON_CONFIG[weapon]
	if int(ammo.get(weapon, 0)) <= 0:
		game.notify("Magazine empty — press R to reload")
		return

	if int(ammo[weapon]) <= 0:
		game.notify("Magazine empty — press R to reload")
		return
	ammo[weapon] = int(ammo[weapon]) - 1
	fire_delay = float(config["fire_interval"])
	weapon_kick = 0.13 if weapon == "Shotgun" else (0.055 if weapon == "Rifle" else 0.075)
	var recoil_angle: float = deg_to_rad(2.4 if weapon == "Shotgun" else (0.65 if weapon == "Rifle" else 1.25))
	camera.rotation.x = maxf(deg_to_rad(-82.0), camera.rotation.x - recoil_angle)
	recoil_return += recoil_angle
	muzzle_flash_time = 0.045 if weapon == "Rifle" else 0.065
	var hit_count := 0
	var pellets := int(config["pellets"])
	for pellet_index in range(pellets):
		var forward: Vector3 = -camera.global_basis.z
		var right: Vector3 = camera.global_basis.x
		var up: Vector3 = camera.global_basis.y
		var spread := float(config["spread"])
		var direction := (forward + right * randf_range(-spread, spread) + up * randf_range(-spread, spread)).normalized()
		var query := PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position + direction * float(config["range"]))
		query.exclude = [get_rid()]
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.collision_mask = 0xFFFFFFFF
		var result := get_world_3d().direct_space_state.intersect_ray(query)
		if not result.is_empty():
			var target = result.get("collider")
			if target != null and target.has_method("take_damage"):
				var hit_position: Vector3 = result.get("position", Vector3.ZERO)
				var damage: float = float(config["damage"])
				var is_headshot: bool = hit_position.y >= target.global_position.y + 1.52
				if is_headshot:
					damage *= 2.0
				if target.has_method("take_damage"):
					target.take_damage(damage, hit_position, is_headshot)
				hit_count += 1
	game.notify("Fired %s  |  %d in magazine" % [weapon, int(ammo[weapon])])
	if hit_count > 0:
		game.notify("%s hit confirmed" % weapon)

func _reload() -> void:
	if not _gameplay_active() or reload_delay > 0.0:
		return
	if not WEAPON_CONFIG.has(weapon):
		return
	var capacity := int(WEAPON_CONFIG[weapon]["capacity"])
	if int(ammo.get(weapon, 0)) >= capacity:
		game.notify("Magazine already full.")
		return
	if int(reserve.get(weapon, 0)) <= 0:
		game.notify("No reserve ammunition for " + weapon + ".")
		return
	reloading_weapon = weapon
	aiming = false
	reload_delay = float(WEAPON_CONFIG[weapon]["reload_time"])
	reload_visual_time = reload_delay
	weapon_kick = 0.0
	game.notify("Reloading " + weapon + "...")

func _finish_reload() -> void:
	var name := reloading_weapon
	reloading_weapon = ""
	if not WEAPON_CONFIG.has(name):
		return
	var capacity := int(WEAPON_CONFIG[name]["capacity"])
	var needed := maxi(0, capacity - int(ammo.get(name, 0)))
	var loaded := mini(needed, int(reserve.get(name, 0)))
	ammo[name] = int(ammo.get(name, 0)) + loaded
	reserve[name] = int(reserve.get(name, 0)) - loaded
	if loaded > 0:
		game.notify("%s reloaded: %d / %d" % [name, int(ammo[name]), capacity])
	else:
		game.notify("Reload cancelled.")

func _equip(name: String) -> void:
	if not WEAPON_CONFIG.has(name):
		return
	if reload_delay > 0.0:
		game.notify("Finish reloading before switching weapons.")
		return
	weapon = name
	aiming = false
	_refresh_weapon_model()
	game.notify("Equipped " + name)

func _refresh_weapon_model() -> void:
	for name in weapon_models.keys():
		var model: Node3D = weapon_models[name]
		model.visible = name == weapon
	if WEAPON_CONFIG.has(weapon):
		magazine[weapon] = int(WEAPON_CONFIG[weapon]["capacity"])

func hurt(amount: float) -> void:
	if dead or game.paused or amount <= 0.0:
		return
	health = maxf(0.0, health - amount)
	damage_flash_time = 0.32
	game.notify("You are hurt!  -%d HP" % int(round(amount)))
	if health <= 0.0:
		dead = true
		game.show_game_over()

func use_item(item_id: String) -> void:
	# Keep legacy food_tin loot compatible without splitting the underlying inventory.
	var effect_id: String = "food" if item_id == "food_tin" else item_id
	if int(inventory.get(item_id, 0)) <= 0:
		game.notify("You don't have that item.")
		return
	if effect_id == "food":
		if hunger >= 98.0:
			game.notify("You're not hungry enough to waste food.")
			return
		hunger = minf(100.0, hunger + 35.0)
	elif effect_id == "water":
		if thirst >= 98.0:
			game.notify("You're not thirsty enough to waste water.")
			return
		thirst = minf(100.0, thirst + 40.0)
	elif effect_id == "medkit":
		if health >= 98.0:
			game.notify("You're not injured enough to use a medical kit.")
			return
		health = minf(100.0, health + 45.0)
	else:
		game.notify("That item cannot be used.")
		return
	inventory[item_id] = maxi(0, int(inventory.get(item_id, 0)) - 1)
	var display_name: String = item_id.replace("_", " ")
	var item_info: Variant = game.item_data.get(item_id, {})
	if item_info is Dictionary:
		display_name = str(item_info.get("name", display_name))
	game.notify("Used " + display_name + ".")
	game.toggle_inventory(true)
