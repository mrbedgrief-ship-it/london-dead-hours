extends CharacterBody3D

@export var runner := false
var health := 65.0
var speed := 1.55
var attack_timer := 0.0
var dead := false
var player
var visual_root: Node3D
var torso: MeshInstance3D
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var animation_clock := 0.0

func _ready() -> void:
	speed = 3.0 if runner else 1.45
	health = 52.0 if runner else 75.0
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.75
	var col := CollisionShape3D.new()
	col.shape = shape
	col.position.y = 0.88
	add_child(col)
	# Decorative rig meshes have no collision: hitscan rays target this CharacterBody3D.
	visual_root = Node3D.new()
	visual_root.name = "HumanoidVisual"
	add_child(visual_root)
	var shirt_color := Color("#3c4640") if not runner else Color("#55403a")
	var trousers_color := Color("#353a38") if not runner else Color("#34312f")
	var skin_color := Color("#81766a") if not runner else Color("#8b6d61")
	var cloth := _material(shirt_color)
	var trousers := _material(trousers_color)
	var skin := _material(skin_color)
	var dirt := _material(Color("#292d2b"))
	var stained := _material(Color("#573632") if runner else Color("#4b4038"))
	torso = _add_box(visual_root,"Torso",Vector3(0,1.17,0),Vector3(0.55,0.68,0.31),cloth)
	_add_box(visual_root,"Ragged outer layer",Vector3(0,1.13,0.035),Vector3(0.60,0.43,0.34),stained)
	_add_box(visual_root,"Neck",Vector3(0,1.57,0),Vector3(0.16,0.15,0.16),skin)
	_add_box(visual_root,"Head",Vector3(0,1.79,0),Vector3(0.31,0.37,0.29),skin)
	_add_box(visual_root,"Hair",Vector3(0,1.99,-0.025),Vector3(0.33,0.09,0.30),dirt)
	_add_box(visual_root,"Jaw",Vector3(0,1.66,0.045),Vector3(0.23,0.10,0.20),stained)
	_add_box(visual_root,"Torn shirt patch",Vector3(0.12,1.23,0.18),Vector3(0.12,0.23,0.025),dirt)
	left_arm = _limb_pivot(visual_root,"LeftArm",Vector3(-0.34,1.42,0),Vector3(0.17,0.43,0.18),cloth,skin)
	right_arm = _limb_pivot(visual_root,"RightArm",Vector3(0.34,1.42,0),Vector3(0.17,0.43,0.18),cloth,skin)
	left_leg = _leg_pivot(visual_root,"LeftLeg",Vector3(-0.16,0.78,0),trousers,dirt)
	right_leg = _leg_pivot(visual_root,"RightLeg",Vector3(0.16,0.78,0),trousers,dirt)
	if runner:
		_add_box(visual_root,"Runner torn shoulder",Vector3(-0.29,1.40,0),Vector3(0.18,0.22,0.21),stained)
		visual_root.scale = Vector3(0.92,1.02,0.92)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.96
	return material

func _add_box(parent: Node3D, part_name: String, pos: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.position = pos
	part.material_override = material
	part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(part)
	return part

func _limb_pivot(parent: Node3D, part_name: String, pos: Vector3, size: Vector3, cloth: Material, skin: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = part_name
	pivot.position = pos
	parent.add_child(pivot)
	_add_box(pivot,"Upper sleeve",Vector3(0,-0.20,0),size,cloth)
	_add_box(pivot,"Forearm",Vector3(0,-0.47,0.015),Vector3(size.x*0.82,0.27,size.z*0.82),cloth)
	_add_box(pivot,"Hand",Vector3(0,-0.64,0.035),Vector3(0.12,0.13,0.13),skin)
	return pivot

func _leg_pivot(parent: Node3D, part_name: String, pos: Vector3, trousers: Material, boots: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = part_name
	pivot.position = pos
	parent.add_child(pivot)
	_add_box(pivot,"Trouser leg",Vector3(0,-0.25,0),Vector3(0.21,0.49,0.25),trousers)
	_add_box(pivot,"Shin",Vector3(0,-0.51,0.015),Vector3(0.17,0.25,0.20),trousers)
	_add_box(pivot,"Boot",Vector3(0,-0.65,-0.055),Vector3(0.23,0.13,0.34),boots)
	return pivot

func _physics_process(delta: float) -> void:
	if dead:
		return
	var game_node = get_parent()
	if game_node != null and game_node.get("paused") == true:
		velocity = Vector3.ZERO
		return
	if not is_instance_valid(player):
		player = null
	attack_timer = maxf(0.0, attack_timer - delta)
	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0]
		return
	if player.dead:
		velocity = Vector3.ZERO
		return
	var distance: float = global_position.distance_to(player.global_position)
	if distance < 17.0 and distance > 1.45:
		var direction: Vector3 = player.global_position - global_position
		direction.y = 0.0
		direction = direction.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
	elif distance <= 1.45:
		velocity.x = 0.0
		velocity.z = 0.0
		if attack_timer <= 0.0:
			player.hurt(12.0 if runner else 7.0)
			attack_timer = 1.25 if runner else 1.7
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta)
		velocity.z = move_toward(velocity.z, 0.0, speed * delta)
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	move_and_slide()
	_animate_body(delta)

func _animate_body(delta: float) -> void:
	animation_clock += delta * (8.5 if runner else 4.5)
	var moving: bool = Vector2(velocity.x, velocity.z).length() > 0.18
	var gait: float = sin(animation_clock) if moving else sin(animation_clock * 0.45) * 0.08
	if left_leg != null:
		left_leg.rotation.x = gait * (0.58 if runner else 0.34)
		right_leg.rotation.x = -gait * (0.58 if runner else 0.34)
		left_arm.rotation.x = -gait * 0.42 - (0.3 if runner else 0.12)
		right_arm.rotation.x = gait * 0.42 - (0.3 if runner else 0.12)
		torso.rotation.z = sin(animation_clock * 0.5) * (0.07 if runner else 0.035)
		torso.rotation.x = -0.10 if runner and moving else 0.035

func take_damage(amount: float) -> void:
	if dead or not is_finite(amount) or amount <= 0.0:
		return
	health = maxf(0.0, health - amount)
	if health <= 0.0:
		dead = true
		velocity = Vector3.ZERO
		collision_layer = 0
		collision_mask = 0
		for child in get_children():
			if child is CollisionShape3D:
				child.disabled = true
		if visual_root != null:
			visual_root.rotation.z = PI * 0.5
			visual_root.position.y = 0.32
