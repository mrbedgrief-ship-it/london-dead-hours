extends CharacterBody3D

@export var runner := false
var health := 65.0
var speed := 1.55
var attack_timer := 0.0
var dead := false
var player
var body_mesh: MeshInstance3D

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
	body_mesh = MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.34 if not runner else 0.29
	mesh.height = 1.65
	body_mesh.mesh = mesh
	body_mesh.position.y = 0.88
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.28, 0.32, 0.27) if not runner else Color(0.38, 0.20, 0.17)
	mat.roughness = 1.0
	body_mesh.material_override = mat
	add_child(body_mesh)
	var head := MeshInstance3D.new()
	var hm := SphereMesh.new()
	hm.radius = 0.22
	hm.height = 0.44
	head.mesh = hm
	head.position.y = 1.8
	head.material_override = mat
	add_child(head)

func _physics_process(delta: float) -> void:
	if dead: return
	attack_timer = maxf(0.0, attack_timer - delta)
	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty(): player = players[0]
		return
	var distance := global_position.distance_to(player.global_position)
	if distance < 17.0 and distance > 1.25:
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
	if not is_on_floor(): velocity.y -= 18.0 * delta
	move_and_slide()

func take_damage(amount: float) -> void:
	if dead: return
	health -= amount
	if health <= 0.0:
		dead = true
		velocity = Vector3.ZERO
		collision_layer = 0
		collision_mask = 0
		body_mesh.visible = false
		for child in get_children():
			if child is MeshInstance3D: child.visible = false
		var corpse := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.85, 0.25, 0.45)
		corpse.mesh = mesh
		corpse.position.y = 0.18
		add_child(corpse)
