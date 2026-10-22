extends Node3D

const Player = preload("res://player.gd")
const Bot = preload("res://bot.gd")
var rng := RandomNumberGenerator.new()
var player: CharacterBody3D
var bots: Array = []
var pickups: Array = []
var zone_radius := 112.0
var elapsed := 0.0
var kills := 0
var finished := false
var started := false
var message := "Stay inside the circle. Be the last banner standing."
var hurt_alpha := 0.0
var zone: MeshInstance3D
var stats: Label
var info: Label
var center: Label
var damage_overlay: ColorRect
var menu: Control
var minimap: Control

func material(color: Color) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	return m

func visual_box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = material(color)
	parent.add_child(mesh)
	mesh.position = pos
	return mesh

func solid(pos: Vector3, size: Vector3, color: Color):
	var body = StaticBody3D.new()
	add_child(body)
	body.position = pos
	visual_box(body,Vector3.ZERO,size,color)
	var shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	return body

func _ready():
	rng.seed = 1764
	build_landscape()
	player = Player.new()
	add_child(player)
	player.position = Vector3(0,1,18)
	for i in range(11):
		var bot = Bot.new()
		add_child(bot)
		var angle = TAU*float(i)/11.0
		bot.position = Vector3(cos(angle)*65,1,sin(angle)*61)
		bots.append(bot)
	for i in range(18):
		var pos = Vector3(rng.randf_range(-68,68),0.5,rng.randf_range(-65,68))
		var kind = i%2
		var item = visual_box(self,pos,Vector3(0.8,0.7,0.8),Color("6bba96") if kind==0 else Color("d9b463"))
		pickups.append({"node":item,"kind":kind})
	build_hud()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func build_landscape():
	var environment = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("668eaa")
	sky_mat.sky_horizon_color = Color("ddd3b3")
	sky_mat.ground_horizon_color = Color("b7b08a")
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c4d3d1")
	env.ambient_light_energy = 0.65
	environment.environment = env
	add_child(environment)
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40,-30,0)
	sun.light_color = Color("ffe0a6")
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	add_child(sun)
	solid(Vector3(0,-0.6,0),Vector3(180,1,170),Color("8b9164"))
	visual_box(self,Vector3(0,-0.15,-112),Vector3(450,0.15,65),Color("427a8c"))
	visual_box(self,Vector3(0,-0.13,-80),Vector3(180,0.15,9),Color("c5b480"))
	for i in range(25):
		visual_box(self,Vector3(rng.randf_range(-200,200),0,-115-i%4*4),Vector3(rng.randf_range(5,20),0.03,0.12),Color("82a6a7"))
	# Open fort gateway faces south. Courtyard and walls provide solid cover.
	var stone = Color("a77956")
	solid(Vector3(0,3,-20),Vector3(44,6,2),stone)
	solid(Vector3(-22,3,0),Vector3(2,6,42),stone)
	solid(Vector3(22,3,0),Vector3(2,6,42),stone)
	solid(Vector3(-14,3,20),Vector3(16,6,2),stone)
	solid(Vector3(14,3,20),Vector3(16,6,2),stone)
	solid(Vector3(0,6.3,20),Vector3(12,2,2),stone)
	visual_box(self,Vector3(0,-0.03,0),Vector3(42,0.1,38),Color("b49d76"))
	for x in [-22,22]:
		for z in [-20,20]:
			solid(Vector3(x,4,z),Vector3(6,8,6),Color("936347"))
			for dx in [-2,0,2]:
				solid(Vector3(x+dx,8.6,z),Vector3(1,1.2,6),stone)
	for x in range(-20,22,4):
		solid(Vector3(x,6.6,-20),Vector3(1.8,1.2,2),stone)
	for i in range(16):
		var side = -1 if i%2==0 else 1
		var x = side*rng.randf_range(33,72)
		var z = rng.randf_range(-52,63)
		solid(Vector3(x,1.6,z),Vector3(7,3.2,6),Color("b99c72"))
		solid(Vector3(x,3.4,z),Vector3(8,0.5,7),Color("665e42"))
		visual_box(self,Vector3(x,1,z+3.03),Vector3(1.4,2,0.08),Color("433c2d"))
	for i in range(35):
		var x = rng.randf_range(-80,80)
		var z = rng.randf_range(-70,75)
		if absf(x)<28 and absf(z)<26:
			continue
		if i%2==0:
			solid(Vector3(x,0.8,z),Vector3(2.5,1.6,1.5),Color("827b61"))
		else:
			solid(Vector3(x,2,z),Vector3(0.7,4,0.7),Color("66503b"))
			var leaves = MeshInstance3D.new()
			var sphere = SphereMesh.new()
			sphere.radius = 2.4
			sphere.height = 5
			leaves.mesh = sphere
			leaves.material_override = material(Color("526644"))
			add_child(leaves)
			leaves.position = Vector3(x,5,z)
	# A translucent wall makes the shrinking safe-zone boundary visible.
	zone = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 1
	cylinder.bottom_radius = 1
	cylinder.height = 26
	cylinder.radial_segments = 96
	cylinder.cap_top = false
	cylinder.cap_bottom = false
	zone.mesh = cylinder
	var zm = material(Color(0.3,0.75,0.88,0.17))
	zm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	zm.cull_mode = BaseMaterial3D.CULL_DISABLED
	zm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	zone.material_override = zm
	add_child(zone)
	zone.position.y = 10
	zone.scale = Vector3(112,1,112)

func label_at(pos: Vector2, size: int, text: String) -> Label:
	var label = Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",Color("f0e7d0"))
	label.add_theme_color_override("font_shadow_color",Color("172527"))
	label.add_theme_constant_override("shadow_offset_x",2)
	label.add_theme_constant_override("shadow_offset_y",2)
	label.text = text
	return label

func build_hud():
	var canvas = CanvasLayer.new()
	add_child(canvas)
	var hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(hud)
	hud.add_child(label_at(Vector2(28,20),24,"BATTLE OF BUXAR  /  LAST BANNER"))
	stats = label_at(Vector2(28,60),20,"")
	hud.add_child(stats)
	info = label_at(Vector2(28,626),17,"")
	hud.add_child(info)
	var cross = label_at(Vector2(625,337),24,"+")
	hud.add_child(cross)
	center = label_at(Vector2(300,280),38,"")
	hud.add_child(center)
	damage_overlay = ColorRect.new()
	damage_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_overlay.color = Color(0.7,0.1,0.05,0)
	hud.add_child(damage_overlay)
	menu = Control.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas.add_child(menu)
	var background = ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.04,0.09,0.1,0.93)
	menu.add_child(background)
	menu.add_child(label_at(Vector2(100,90),18,"BUXAR, BIHAR  •  3D SURVIVAL PROTOTYPE"))
	menu.add_child(label_at(Vector2(100,140),64,"The last banner\nof Buxar."))
	menu.add_child(label_at(Vector2(100,330),20,"One fort. Twelve fighters. A closing circle.\nFind cover, collect supplies, and be the last survivor."))
	menu.add_child(label_at(Vector2(100,420),17,"WASD  Move    MOUSE  Aim    LEFT CLICK  Fire\nSHIFT  Sprint    SPACE  Jump    R  Reload    ESC  Release mouse\nGreen crates restore health. Brass crates replenish ammunition."))
	var start = Button.new()
	start.text = "ENTER THE BATTLE  →"
	start.position = Vector2(100,535)
	start.size = Vector2(300,60)
	start.pressed.connect(func():
		started = true
		menu.hide()
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED)
	menu.add_child(start)
	menu.add_child(label_at(Vector2(100,635),13,"Fictional offline match. Buxar-inspired terrain and placeholder art; not a surveyed map or historical reconstruction."))

func _process(delta):
	if not started or finished:
		return
	elapsed += delta
	zone_radius = maxf(8,112-maxf(0,elapsed-25)*0.34)
	zone.scale = Vector3(zone_radius,1,zone_radius)
	hurt_alpha = maxf(0,hurt_alpha-delta*0.4)
	damage_overlay.color.a = hurt_alpha
	stats.text = "HEALTH %03d    |    AMMO %02d / %02d    |    ALIVE %02d    |    KILLS %02d    |    ZONE %dm" % [ceili(player.health),player.ammo,player.reserve,alive_count(),kills,zone_radius]
	var status = "RELOADING…" if player.reload_time > 0 else message
	if Vector2(player.position.x,player.position.z).length()>zone_radius:
		status = "OUTSIDE THE SAFE ZONE — move toward the fort!"
	info.text = status+"\nWASD Move · Shift Sprint · Space Jump · Click Fire · R Reload · Esc Mouse"
	for item in pickups.duplicate():
		var node = item.node
		node.rotation.y += delta
		if player.position.distance_to(node.position)<2.2:
			if item.kind==0:
				if player.health>=100:
					continue
				player.health = minf(100,player.health+35)
				message = "Medical supplies collected. +35 health."
			else:
				player.reserve += 24
				message = "Ammunition collected. +24 rounds."
			node.queue_free()
			pickups.erase(item)

func alive_count() -> int:
	var count = 1 if is_instance_valid(player) and player.health>0 else 0
	for bot in bots:
		if bot.alive:
			count += 1
	return count

func check_win():
	if not finished and alive_count()==1 and player.health>0:
		finish(true)

func finish(win: bool):
	finished = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	center.text = ("VICTORY · THE LAST BANNER" if win else "YOUR BANNER HAS FALLEN")+"\n%d eliminations · %d seconds\nPress Enter to play again" % [kills,int(elapsed)]
	center.add_theme_font_size_override("font_size",28)

func _unhandled_input(event):
	if finished and event is InputEventKey and event.pressed and event.keycode==KEY_ENTER:
		get_tree().reload_current_scene()

func tracer(origin: Vector3, end: Vector3, color: Color):
	var length = origin.distance_to(end)
	if length<0.1:
		return
	var line = visual_box(self,(origin+end)*0.5,Vector3(0.025,0.025,length),color)
	line.look_at(end,Vector3.UP)
	get_tree().create_timer(0.07).timeout.connect(line.queue_free)
