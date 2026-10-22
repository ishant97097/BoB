extends CharacterBody3D

var health := 100.0
var ammo := 12
var reserve := 72
var reload_time := 0.0
var cooldown := 0.0
var camera: Camera3D
var weapon: Node3D
var world: Node3D
var pitch := 0.0
var flash: MeshInstance3D

func _ready():
	world = get_parent()
	collision_layer = 2
	collision_mask = 1
	var shape = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)
	camera = Camera3D.new()
	camera.position.y = 1.65
	camera.fov = 78
	add_child(camera)
	weapon = Node3D.new()
	camera.add_child(weapon)
	world.visual_box(weapon, Vector3(0.31,-0.27,-0.6), Vector3(0.13,0.15,0.75), Color("49372a"))
	world.visual_box(weapon, Vector3(0.31,-0.23,-0.85), Vector3(0.065,0.065,0.75), Color("323c40"))
	flash = world.visual_box(weapon, Vector3(0.31,-0.23,-1.26), Vector3(0.12,0.12,0.18), Color("ffd47a"))
	flash.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not world.finished:
		rotate_y(-event.relative.x * 0.0022)
		pitch = clamp(pitch-event.relative.y*0.0022,-1.4,1.4)
		camera.rotation.x = pitch
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not world.finished:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			shoot()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
		if event.keycode == KEY_R and ammo < 12 and reserve > 0 and reload_time <= 0:
			reload_time = 1.8

func _physics_process(delta):
	if world.finished:
		return
	cooldown = max(0,cooldown-delta)
	flash.visible = cooldown > 0.32
	if reload_time > 0:
		reload_time -= delta
		if reload_time <= 0:
			var count = mini(12-ammo,reserve)
			ammo += count
			reserve -= count
	var axis = Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
	var direction = (transform.basis * Vector3(axis.x,0,axis.y)).normalized()
	var speed = 9.0 if Input.is_physical_key_pressed(KEY_SHIFT) else 5.5
	velocity.x = direction.x*speed
	velocity.z = direction.z*speed
	if not is_on_floor():
		velocity.y -= 22*delta
	elif Input.is_physical_key_pressed(KEY_SPACE):
		velocity.y = 7
	move_and_slide()
	position.x = clamp(position.x,-87,87)
	position.z = clamp(position.z,-77,83)
	weapon.position.y = sin(Time.get_ticks_msec()*0.012)*0.012*axis.length()
	if Vector2(position.x,position.z).length() > world.zone_radius:
		damage(8*delta)

func shoot():
	if world.finished or cooldown > 0 or reload_time > 0:
		return
	if ammo <= 0:
		world.message = "Magazine empty. Press R to reload."
		return
	ammo -= 1
	cooldown = 0.42
	var origin = camera.global_position
	var end = origin-camera.global_transform.basis.z*180
	var query = PhysicsRayQueryParameters3D.create(origin,end,5)
	var hit = get_world_3d().direct_space_state.intersect_ray(query)
	if hit:
		end = hit.position
		if hit.collider.has_method("damage"):
			hit.collider.damage(34.0,self)
			world.message = "Hit confirmed"
	world.tracer(origin-camera.global_transform.basis.z*1.3,end,Color("ffe0a0"))

func damage(amount: float):
	if world.finished:
		return
	health = max(0,health-amount)
	world.hurt_alpha = min(0.45,world.hurt_alpha+amount*0.012)
	if health <= 0:
		world.finish(false)
