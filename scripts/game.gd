extends Node3D

var mat_ground: StandardMaterial3D
var mat_road: StandardMaterial3D
var mat_brick: StandardMaterial3D
var mat_dark_brick: StandardMaterial3D
var mat_glass: StandardMaterial3D
var mat_gun: StandardMaterial3D
var mat_metal: StandardMaterial3D
var mat_wood: StandardMaterial3D
var player
var props: Node3D
var ui_layer: CanvasLayer
var root_ui: Control
var hud: Label
var crosshair: Label
var health_bar: ProgressBar
var hunger_bar: ProgressBar
var thirst_bar: ProgressBar
var prompt_label: Label
var message_label: Label
var panel: PanelContainer
var panel_content: VBoxContainer
var paused := false
var menu_open := true
var message_time := 0.0
var onboarding_index := 0
var onboarding_timer := 0.0
var onboarding_steps: Array[String] = [
	"WASD move  •  Mouse look  •  Shift sprint",
	"E search / interact  •  LMB fire  •  RMB aim",
	"R reload  •  1 / 2 / 3 switch weapons  •  Tab inventory",
	"Food restores hunger, water restores thirst, medical kits restore health.",
	"Follow the warm lights to find shelter and the trader."
]
var trader_stock := {"food": 8, "water": 8, "medkit": 4, "pistol_ammo": 6, "shells": 4, "rifle_ammo": 4}
var item_data := {
	"food": {"name":"Canned Food", "buy":8, "sell":4, "desc":"Restores hunger."},
	"water": {"name":"Bottled Water", "buy":6, "sell":3, "desc":"Restores thirst."},
	"medkit": {"name":"Medical Kit", "buy":18, "sell":9, "desc":"Restores health."},
	"pistol_ammo": {"name":"Pistol Rounds", "buy":12, "sell":5, "desc":"12 rounds."},
	"shells": {"name":"Shotgun Shells", "buy":16, "sell":7, "desc":"8 shells."},
	"rifle_ammo": {"name":"Rifle Rounds", "buy":20, "sell":8, "desc":"30 rounds."},
	"scrap": {"name":"Antique Watch", "buy":0, "sell":22, "desc":"A valuable relic from the old world."},
	"food_tin": {"name":"Canned Food", "buy":8, "sell":4, "desc":"Restores hunger."}
}

func _ready() -> void:
	_create_materials()
	_create_world()
	_create_ui()
	show_main_menu()

func _create_materials() -> void:
	mat_ground = _material(Color("#424746"), 0.98)
	mat_road = _material(Color("#242a2b"), 0.92)
	mat_brick = _material(Color("#593d36"), 0.94)
	mat_dark_brick = _material(Color("#352d2b"), 0.95)
	mat_glass = _material(Color("#303b3d"), 0.3)
	mat_gun = _material(Color("#242626"), 0.6)
	mat_metal = _material(Color("#555a58"), 0.7)
	mat_wood = _material(Color("#59483a"), 0.95)

func _material(color: Color, rough: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	return m

func _box(parent: Node3D, name: String, pos: Vector3, size: Vector3, material: Material, solid := true) -> Node3D:
	var node: Node3D
	if solid:
		node = StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		node.add_child(collision)
	else:
		node = Node3D.new()
	var mesh_node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_node.mesh = mesh
	mesh_node.material_override = material
	mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	node.add_child(mesh_node)
	node.name = name
	node.position = pos
	parent.add_child(node)
	return node

func _create_world() -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("#3e4a50")
	sky_mat.sky_horizon_color = Color("#858783")
	sky_mat.ground_bottom_color = Color("#252a2b")
	sky_mat.ground_horizon_color = Color("#666c6a")
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#a0a7a5")
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("#747c7c")
	env.fog_density = 0.009
	env_node.environment = env
	add_child(env_node)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 0.65
	sun.shadow_enabled = true
	add_child(sun)
	_box(self, "Wet road base", Vector3(0,-0.3,0), Vector3(104,0.5,104), mat_road)
	_box(self, "Pavement north", Vector3(0,0,-9.3), Vector3(104,0.22,2.8), mat_ground)
	_box(self, "Pavement south", Vector3(0,0,9.3), Vector3(104,0.22,2.8), mat_ground)
	_box(self, "Pavement east", Vector3(9.3,0,0), Vector3(2.8,0.22,104), mat_ground)
	_box(self, "Pavement west", Vector3(-9.3,0,0), Vector3(2.8,0.22,104), mat_ground)
	for x in range(-45, 46, 9):
		_box(self, "Faded lane marking", Vector3(x,0.01,0), Vector3(3.0,0.025,0.12), _material(Color("#9b9682"),0.95), false)
	for z in range(-44, 45, 8):
		_box(self, "Double yellow line", Vector3(0,0.015,z), Vector3(0.08,0.025,2.8), _material(Color("#a68d45"),0.9), false)
	# Brick buildings form a broken, navigable street grid.
	for z in [-22.0, 22.0]:
		for x in [-37.0,-18.0,4.0,27.0,44.0]:
			_building(Vector3(x,0,z), Vector3(15.0,8.5,10.0), mat_brick if int(x) % 2 == 0 else mat_dark_brick)
	for x in [-22.0,22.0]:
		for z in [-39.0,-18.0,3.0,26.0,43.0]:
			_building(Vector3(x,0,z), Vector3(10.0,8.0,15.0), mat_brick)
	# A narrow alley with service walls and a lit doorway.
	_box(self,"Alley wall",Vector3(-3,2.1,-31),Vector3(0.7,4.2,12),mat_dark_brick)
	_box(self,"Alley wall",Vector3(3,2.1,-31),Vector3(0.7,4.2,12),mat_dark_brick)
	_box(self,"Red telephone box",Vector3(-5,1.2,3),Vector3(0.9,2.4,0.9),_material(Color("#782e2a"),0.7))
	_box(self,"Telephone glass",Vector3(-5,1.35,2.52),Vector3(0.48,1.55,0.025),mat_glass,false)
	_box(self,"Abandoned car",Vector3(13,0.75,-3),Vector3(4.6,1.5,2.0),_material(Color("#42484a"),0.75))
	_box(self,"Abandoned van",Vector3(-14,0.8,15),Vector3(5.3,1.6,2.4),_material(Color("#56534b"),0.85))
	_box(self,"Rubbish bin",Vector3(6,0.65,-11),Vector3(0.9,1.3,0.8),mat_metal)
	_box(self,"Barricade",Vector3(-7,0.8,25),Vector3(3.5,1.3,0.5),mat_wood)
	_box(self,"Makeshift sandbags",Vector3(-7,0.45,24.4),Vector3(3.2,0.7,0.65),_material(Color("#79705d"),1))
	# Storefronts and signs.
	_box(self,"NIGHT OWL MARKET sign",Vector3(28,4.3,-16.7),Vector3(7.5,0.85,0.2),_material(Color("#6b4935"),0.9),false)
	_box(self,"IRON & ASH GUNS sign",Vector3(-20,4.2,16.7),Vector3(7.5,0.85,0.2),_material(Color("#3b3835"),0.9),false)
	_box(self,"THE LAST PINT sign",Vector3(3,4.2,16.7),Vector3(6.5,0.8,0.2),_material(Color("#5b382f"),0.9),false)
	props = Node3D.new()
	props.name = "Interactables"
	add_child(props)
	_make_loot("Hideout Supply Crate",Vector3(-39,0.55,0), "food",2)
	_make_loot("Water Crate",Vector3(-36,0.55,1.8),"water",2)
	_make_loot("First Aid Drawer",Vector3(-32,0.55,-1.6),"medkit",1)
	_make_loot("Market Shelf",Vector3(28,0.65,-13.5),"food",2)
	_make_loot("Market Fridge",Vector3(31,0.65,-13.5),"water",2)
	_make_loot("Market Cash Drawer",Vector3(25,0.55,-13.5),"money",12)
	_make_loot("Gun Shop Cabinet",Vector3(-20,0.55,13.5),"pistol_ammo",12)
	_make_loot("Gun Shop Display",Vector3(-17,0.55,13.5),"shells",4)
	_make_loot("Abandoned Car Boot",Vector3(13,0.55,-0.7),"scrap",1)
	_make_loot("Apartment Cabinet",Vector3(41,0.55,18),"food",1)
	_make_loot("Old Desk Drawer",Vector3(2,0.55,-40),"scrap",1)
	_make_trader(Vector3(40,0.7,0))
	_make_zombie(Vector3(4,0,-3),false)
	_make_zombie(Vector3(23,0,-7),false)
	_make_zombie(Vector3(32,0,-23),true)
	_make_zombie(Vector3(-19,0,8),false)
	_make_zombie(Vector3(3,0,29),true)
	_make_zombie(Vector3(41,0,29),false)
	# Shelter lights mark the two safe destinations.
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(-39,3,0)
	lamp.light_color = Color("#e6a76c")
	lamp.light_energy = 1.8
	lamp.omni_range = 9.0
	add_child(lamp)
	var trader_lamp := OmniLight3D.new()
	trader_lamp.position = Vector3(40,3,0)
	trader_lamp.light_color = Color("#e6a76c")
	trader_lamp.light_energy = 2.0
	trader_lamp.omni_range = 8.0
	add_child(trader_lamp)

func _building(center: Vector3, size: Vector3, material: Material) -> void:
	_box(self,"Brick building",center + Vector3(0,size.y/2.0,0),size,material)
	for y in [2.2,4.6,6.7]:
		for x in [-size.x*0.32,0,size.x*0.32]:
			var front_z := center.z + (size.z/2.0 + 0.02) * (1 if center.z < 0 else -1)
			_box(self,"Dark shop window",Vector3(center.x+x,y,front_z),Vector3(1.3,1.3,0.08),mat_glass,false)
	for x in [-size.x*0.35,size.x*0.35]:
		_box(self,"Brick lintel",Vector3(center.x+x,3.1,center.z+size.z/2.0+0.03),Vector3(1.6,0.16,0.12),mat_metal,false)

func _make_loot(title: String, pos: Vector3, item: String, count: int) -> void:
	var box := StaticBody3D.new()
	box.name = title
	box.position = pos
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.0,0.9,0.75)
	var col := CollisionShape3D.new()
	col.shape = shape
	box.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.0,0.9,0.75)
	mesh.mesh = bm
	mesh.material_override = mat_wood
	box.add_child(mesh)
	box.set_script(load("res://scripts/interactable.gd"))
	box.title = title
	box.item_id = item
	box.quantity = count
	box.kind = "loot"
	props.add_child(box)

func _make_trader(pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.2,1.8,0.8)
	var col := CollisionShape3D.new()
	col.shape = shape
	col.position.y = 0.9
	body.add_child(col)
	var mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.45
	capsule.height = 1.8
	mesh.mesh = capsule
	mesh.position.y = 0.9
	mesh.material_override = _material(Color("#665344"),0.9)
	body.add_child(mesh)
	body.set_script(load("res://scripts/interactable.gd"))
	body.title = "Trader"
	body.kind = "trader"
	props.add_child(body)
	_box(self,"Trader's reinforced counter",pos+Vector3(0,0.55,-1.2),Vector3(2.6,1.1,0.65),mat_wood)

func _make_zombie(pos: Vector3, is_runner: bool) -> void:
	var zombie = CharacterBody3D.new()
	zombie.position = pos
	zombie.set_script(load("res://scripts/zombie.gd"))
	zombie.runner = is_runner
	add_child(zombie)

func _create_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	root_ui = Control.new()
	root_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(root_ui)
	hud = Label.new()
	hud.position = Vector2(22,18)
	hud.add_theme_font_size_override("font_size",18)
	hud.add_theme_color_override("font_color",Color("#e1e2dc"))
	root_ui.add_child(hud)
	hud.add_theme_font_size_override("font_size",16)
	var bar_y := 96.0
	health_bar = _make_status_bar("HEALTH",Vector2(22,bar_y),Color("#a65b51"))
	hunger_bar = _make_status_bar("HUNGER",Vector2(22,bar_y+28),Color("#b08b51"))
	thirst_bar = _make_status_bar("THIRST",Vector2(22,bar_y+56),Color("#668e9a"))
	prompt_label = Label.new()
	prompt_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt_label.position = Vector2(-170,-75)
	prompt_label.size = Vector2(340,40)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size",20)
	prompt_label.add_theme_color_override("font_color",Color("#e4c18c"))
	root_ui.add_child(prompt_label)
	message_label = Label.new()
	message_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	message_label.position = Vector2(-260,75)
	message_label.size = Vector2(520,40)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size",18)
	message_label.add_theme_color_override("font_color",Color("#e4c18c"))
	root_ui.add_child(message_label)
	crosshair = Label.new()
	crosshair.name = "Crosshair"
	crosshair.text = "+"
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.position = Vector2(-8, -18)
	crosshair.size = Vector2(16, 36)
	crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crosshair.add_theme_font_size_override("font_size", 27)
	crosshair.add_theme_color_override("font_color", Color("#e9e5d7"))
	root_ui.add_child(crosshair)

func _make_status_bar(bar_name: String, pos: Vector2, fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.name = bar_name
	bar.position = pos
	bar.size = Vector2(210,17)
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.show_percentage = false
	var background := StyleBoxFlat.new()
	background.bg_color = Color("#202626")
	background.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("background",background)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill",fill)
	root_ui.add_child(bar)
	var caption := Label.new()
	caption.text = bar_name
	caption.position = pos + Vector2(218,-2)
	caption.add_theme_font_size_override("font_size",12)
	caption.add_theme_color_override("font_color",Color("#c8c8bf"))
	root_ui.add_child(caption)
	return bar

func _panel(title: String) -> VBoxContainer:
	if panel != null and is_instance_valid(panel):
		panel.queue_free()
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-270,-230)
	panel.size = Vector2(540,460)
	panel.custom_minimum_size = Vector2(540,460)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055,0.065,0.065,0.96)
	style.border_color = Color("#796b58")
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel",style)
	root_ui.add_child(panel)
	panel_content = VBoxContainer.new()
	panel_content.add_theme_constant_override("separation",10)
	panel.add_child(panel_content)
	var heading := Label.new()
	heading.text = title
	heading.add_theme_font_size_override("font_size",27)
	heading.add_theme_color_override("font_color",Color("#e3c49a"))
	panel_content.add_child(heading)
	return panel_content

func _button(label: String, action: Callable, parent: VBoxContainer = null) -> void:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size.y = 38
	b.add_theme_font_size_override("font_size",16)
	b.pressed.connect(action)
	(parent if parent != null else panel_content).add_child(b)

func show_main_menu() -> void:
	menu_open = true
	paused = true
	if player != null and is_instance_valid(player):
		player.aiming = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var c := _panel("LONDON: DEAD HOURS")
	var intro := Label.new()
	intro.text = "SOHO, LONDON  •  04:17 AM\nThe city has gone quiet. Stay alive."
	intro.add_theme_font_size_override("font_size",16)
	c.add_child(intro)
	_button("NEW EXPEDITION",Callable(self,"start_new_game"))
	_button("CONTINUE",Callable(self,"load_game"))
	_button("QUIT",Callable(self,"quit_game"))

func start_new_game() -> void:
	if player != null and is_instance_valid(player): player.queue_free()
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(-42,0,0)
	player.set_script(load("res://scripts/player.gd"))
	player.add_to_group("player")
	add_child(player)
	menu_open = false
	paused = false
	if panel: panel.queue_free()
	panel = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	onboarding_index = 0
	onboarding_timer = 1.0
	notify("SOHO, 04:17 AM. Search for supplies; warm lights mark shelter and the trader.")
	update_hud(player)

func toggle_pause() -> void:
	if menu_open: return
	if panel != null and is_instance_valid(panel):
		if player != null and player.inv_open:
			toggle_inventory(true)
			return
		if player != null and player.dead: return
		panel.queue_free()
		panel = null
		paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	paused = true
	if player != null and is_instance_valid(player):
		player.aiming = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var c := _panel("PAUSED")
	_button("RESUME",Callable(self,"toggle_pause"))
	_button("CONTROLS",Callable(self,"show_controls"))
	_button("SAVE GAME",Callable(self,"save_game"))
	_button("LOAD GAME",Callable(self,"load_game"))
	_button("MAIN MENU",Callable(self,"show_main_menu"))
	_button("QUIT",Callable(self,"quit_game"))

func show_controls() -> void:
	var c := _panel("FIELD CONTROLS")
	var controls := Label.new()
	controls.text = "W A S D  —  Move\nMouse  —  Look around\nShift  —  Sprint\nE  —  Search / interact / trade\nLeft mouse  —  Fire\nRight mouse  —  Aim\nR  —  Reload\n1 / 2 / 3  —  Pistol / shotgun / rifle\nTab  —  Inventory\nEsc  —  Pause / close a panel"
	controls.add_theme_font_size_override("font_size",16)
	c.add_child(controls)
	_button("BACK TO PAUSE MENU",Callable(self,"toggle_pause"))

func toggle_inventory(force_close := false) -> void:
	if player == null or paused and not player.inv_open: return
	if player.inv_open or force_close:
		player.inv_open = false
		if panel and is_instance_valid(panel): panel.queue_free()
		panel = null
		paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	player.inv_open = true
	player.aiming = false
	paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var c := _panel("FIELD INVENTORY")
	var money_label := Label.new()
	money_label.text = "CASH  £" + str(player.money) + "     HEALTH  " + str(int(player.health)) + " / 100"
	money_label.add_theme_font_size_override("font_size",16)
	money_label.add_theme_color_override("font_color",Color("#e3c49a"))
	c.add_child(money_label)
	var item_count := 0
	for id in player.inventory.keys():
		var count := int(player.inventory[id])
		if count > 0:
			item_count += count
			var data: Dictionary = item_data.get(id,{"name":id,"desc":"A recovered item.","category":"SUPPLY"})
			var row := HBoxContainer.new()
			var label := Label.new()
			label.text = "%s  × %d\n%s  ·  %s" % [str(data.get("name",id)),count,str(data.get("category","SUPPLY")),str(data.get("desc",""))]
			label.custom_minimum_size = Vector2(335,48)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.add_theme_font_size_override("font_size",14)
			row.add_child(label)
			if id in ["food","food_tin","water","medkit"]:
				var use := Button.new()
				use.text = "USE"
				use.custom_minimum_size = Vector2(76,42)
				use.pressed.connect(Callable(player,"use_item").bind("food" if id == "food_tin" else id))
				row.add_child(use)
			c.add_child(row)
	if item_count == 0:
		var empty := Label.new()
		empty.text = "Your pack is empty. Search crates, shops and abandoned vehicles."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		c.add_child(empty)
	var equip_label := Label.new()
	equip_label.text = "1 PISTOL  ·  2 SHOTGUN  ·  3 RIFLE"
	c.add_child(equip_label)
	_button("CLOSE  [TAB / ESC]",Callable(self,"toggle_inventory"))

func open_trader() -> void:
	if paused or player == null: return
	player.aiming = false
	paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var c := _panel("THE TRADER")
	var cash := Label.new()
	cash.name = "CashLabel"
	cash.text = "Your cash: £" + str(player.money)
	c.add_child(cash)
	var note := Label.new()
	note.text = "BUY stock or SELL valuables from your pack."
	c.add_child(note)
	for id in trader_stock.keys():
		var row := HBoxContainer.new()
		var label := Label.new()
		label.text = str(item_data[id].name) + "  ×" + str(trader_stock[id]) + "   £" + str(item_data[id].buy)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var buy := Button.new()
		buy.text = "BUY"
		buy.pressed.connect(Callable(self,"buy_item").bind(id))
		row.add_child(buy)
		var sell := Button.new()
		sell.text = "SELL"
		sell.pressed.connect(Callable(self,"sell_item").bind(id))
		row.add_child(sell)
		c.add_child(row)
	_button("LEAVE TRADER  [ESC]",Callable(self,"toggle_pause"))

func buy_item(id: String) -> void:
	var price := int(item_data[id].buy)
	if int(trader_stock.get(id,0)) <= 0: notify("Out of stock."); return
	if player.money < price: notify("Not enough cash."); return
	player.money -= price
	trader_stock[id] = int(trader_stock[id]) - 1
	if id == "pistol_ammo": player.reserve["Pistol"] += 12
	elif id == "shells": player.reserve["Shotgun"] += 4
	elif id == "rifle_ammo": player.reserve["Rifle"] += 30
	else: player.inventory[id] = int(player.inventory.get(id,0)) + 1
	notify("Purchased " + str(item_data[id].name) + ".")
	open_trader()

func sell_item(id: String) -> void:
	if int(player.inventory.get(id,0)) <= 0: notify("You don't have that item to sell."); return
	var price := int(item_data.get(id,{"sell":0}).sell)
	if price <= 0: notify("The trader won't buy that."); return
	player.inventory[id] = int(player.inventory[id]) - 1
	player.money += price
	notify("Sold " + str(item_data[id].name) + " for £" + str(price) + ".")
	open_trader()

func set_prompt(value: String) -> void:
	if prompt_label: prompt_label.text = value

func notify(value: String) -> void:
	if message_label:
		message_label.text = value
		message_time = 3.0

func update_hud(p: CharacterBody3D) -> void:
	if hud == null: return
	hud.text = "LONDON  /  DEAD HOURS\nCASH  £%d\n%s   %d / %d  |  RESERVE %d" % [p.money,p.weapon,int(p.ammo[p.weapon]),int(p.magazine[p.weapon]),int(p.reserve[p.weapon])]
	if health_bar != null:
		health_bar.value = p.health
		hunger_bar.value = p.hunger
		thirst_bar.value = p.thirst

func _process(delta: float) -> void:
	if onboarding_timer > 0.0 and not paused:
		onboarding_timer -= delta
		if onboarding_timer <= 0.0:
			if onboarding_index < onboarding_steps.size():
				notify(onboarding_steps[onboarding_index])
				onboarding_index += 1
				onboarding_timer = 4.5
			else:
				onboarding_timer = 0.0
	if message_time > 0.0:
		message_time -= delta
		if message_time <= 0.0 and message_label: message_label.text = ""
	if player != null and not paused and is_instance_valid(player):
		update_hud(player)
	if crosshair != null:
		crosshair.visible = player != null and is_instance_valid(player) and not paused and not menu_open and not player.dead

func show_game_over() -> void:
	paused = true
	if player != null and is_instance_valid(player):
		player.aiming = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var c := _panel("YOU DID NOT SURVIVE")
	var label := Label.new()
	label.text = "The streets have claimed another scavenger."
	c.add_child(label)
	_button("TRY AGAIN",Callable(self,"start_new_game"))
	_button("MAIN MENU",Callable(self,"show_main_menu"))

func save_game() -> void:
	if player == null or not is_instance_valid(player):
		notify("Save failed: there is no active expedition.")
		return
	var safe_inventory: Dictionary = {}
	for id in ["food", "water", "medkit", "scrap"]:
		safe_inventory[id] = clampi(int(player.inventory.get(id, 0)), 0, 9999)
	var safe_ammo: Dictionary = {}
	var safe_reserve: Dictionary = {}
	for name in ["Pistol", "Shotgun", "Rifle"]:
		var capacity := int(player.magazine.get(name, 0))
		safe_ammo[name] = clampi(int(player.ammo.get(name, 0)), 0, maxi(0, capacity))
		safe_reserve[name] = clampi(int(player.reserve.get(name, 0)), 0, 99999)
	var saved_weapon := str(player.weapon)
	if not ["Pistol", "Shotgun", "Rifle"].has(saved_weapon):
		saved_weapon = "Pistol"
	var pos: Vector3 = player.global_position
	var data := {
		"version": 1,
		"money": clampi(int(player.money), 0, 1000000000),
		"health": clampf(float(player.health), 0.0, 100.0),
		"hunger": clampf(float(player.hunger), 0.0, 100.0),
		"thirst": clampf(float(player.thirst), 0.0, 100.0),
		"inventory": safe_inventory,
		"weapon": saved_weapon,
		"ammo": safe_ammo,
		"reserve": safe_reserve,
		"position": [pos.x, pos.y, pos.z]
	}
	var json_text := JSON.stringify(data)
	var file := FileAccess.open("user://dead_hours_save.json", FileAccess.WRITE)
	if file == null:
		notify("Save failed: could not open the save file (error %d)." % FileAccess.get_open_error())
		return
	file.store_string(json_text)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		notify("Save failed: the file could not be written (error %d)." % write_error)
		return
	notify("Game saved.")

func load_game() -> void:
	var path := "user://dead_hours_save.json"
	if not FileAccess.file_exists(path):
		notify("No save found. Start a NEW EXPEDITION first.")
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		notify("Load failed: could not open the save file (error %d)." % FileAccess.get_open_error())
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		notify("Load failed: the save file is invalid or damaged.")
		return
	if not parsed.has("version") or int(parsed.get("version", 0)) != 1:
		notify("Load failed: this save format is not supported.")
		return

	start_new_game()
	player.money = int(_bounded_number(parsed.get("money", 35), 35.0, 0.0, 1000000000.0))
	player.health = _bounded_number(parsed.get("health", 100), 100.0, 1.0, 100.0)
	player.hunger = _bounded_number(parsed.get("hunger", 100), 100.0, 0.0, 100.0)
	player.thirst = _bounded_number(parsed.get("thirst", 100), 100.0, 0.0, 100.0)

	var saved_inventory = parsed.get("inventory", {})
	if saved_inventory is Dictionary:
		for id in ["food", "water", "medkit", "scrap"]:
			if saved_inventory.has(id):
				player.inventory[id] = int(_bounded_number(saved_inventory[id], int(player.inventory.get(id, 0)), 0.0, 9999.0))

	var saved_weapon := str(parsed.get("weapon", "Pistol"))
	if ["Pistol", "Shotgun", "Rifle"].has(saved_weapon):
		player.weapon = saved_weapon
	for name in ["Pistol", "Shotgun", "Rifle"]:
		var capacity := int(player.magazine[name])
		var saved_ammo = parsed.get("ammo", {})
		if saved_ammo is Dictionary and saved_ammo.has(name):
			player.ammo[name] = int(_bounded_number(saved_ammo[name], int(player.ammo[name]), 0.0, float(capacity)))
		var saved_reserve = parsed.get("reserve", {})
		if saved_reserve is Dictionary and saved_reserve.has(name):
			player.reserve[name] = int(_bounded_number(saved_reserve[name], int(player.reserve[name]), 0.0, 99999.0))

	var saved_position = parsed.get("position", [])
	if saved_position is Array and saved_position.size() == 3:
		var x := _bounded_number(saved_position[0], -42.0, -1000.0, 1000.0)
		var y := _bounded_number(saved_position[1], 0.0, -10.0, 1000.0)
		var z := _bounded_number(saved_position[2], 0.0, -1000.0, 1000.0)
		player.global_position = Vector3(x, y, z)
	player._refresh_weapon_model()
	notify("Progress loaded.")

func _bounded_number(value, fallback: float, minimum: float, maximum: float) -> float:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return fallback
	var number := float(value)
	if not is_finite(number):
		return fallback
	return clampf(number, minimum, maximum)

func quit_game() -> void:
	get_tree().quit()
