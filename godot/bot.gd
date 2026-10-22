extends CharacterBody3D

var health := 100.0
var world: Node3D
var target: Node3D
var shot_timer := 0.0
var think_timer := 0.0
var strafe := 1.0
var alive := true

func _ready():
	world = get_parent()
	collision_layer = 4
	collision_mask = 1
	var shape = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.height = 1.8
	capsule.radius = 0.45
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)
	world.visual_box(self,Vector3(0,1.0,0),Vector3(0.7,1.0,0.4),Color("8e4941"))
	world.visual_box(self,Vector3(0,1.65,0),Vector3(0.42,0.42,0.42),Color("b88b65"))
	world.visual_box(self,Vector3(0,1.89,0),Vector3(0.48,0.14,0.48),Color("d3bc88"))
	for x in [-0.2,0.2]:
		world.visual_box(self,Vector3(x,0.3,0),Vector3(0.22,0.6,0.25),Color("383b35"))
	world.visual_box(self,Vector3(0.35,1.15,-0.42),Vector3(0.1,0.12,0.85),Color("373d3a"))
	shot_timer = world.rng.randf_range(0.5,2)
	strafe = -1 if world.rng.randf() < 0.5 else 1

func _physics_process(delta):
	if not alive or world.finished:
		return
	think_timer -= delta
	shot_timer -= delta
	if think_timer <= 0:
		think_timer = 0.7
		target = world.player
		var closest = global_position.distance_to(target.global_position)
		for bot in world.bots:
			if bot != self and bot.alive:
				var distance = global_position.distance_to(bot.global_position)
				if distance < closest:
					closest = distance
					target = bot
	var destination = Vector3.ZERO
	if is_instance_valid(target):
		destination = target.global_position
	if Vector2(position.x,position.z).length() > world.zone_radius-5:
		destination = Vector3.ZERO
	var offset = destination-global_position
	offset.y = 0
	var direction = offset.normalized()
	if offset.length() < 20 and destination != Vector3.ZERO:
		direction = Vector3(-direction.z,0,direction.x)*strafe
	velocity.x = direction.x*3.8
	velocity.z = direction.z*3.8
	velocity.y -= 22*delta
	if is_on_wall():
		velocity.y = 6
		strafe *= -1
	move_and_slide()
	if offset.length() > 0.2:
		look_at(global_position+offset,Vector3.UP)
	if is_instance_valid(target) and shot_timer <= 0 and global_position.distance_to(target.global_position) < 65:
		shot_timer = world.rng.randf_range(1.1,2.3)
		var origin = global_position+Vector3.UP*1.5
		var end = target.global_position+Vector3.UP*1.1
		var query = PhysicsRayQueryParameters3D.create(origin,end,7,[get_rid()])
		var hit = get_world_3d().direct_space_state.intersect_ray(query)
		if hit and hit.collider == target:
			world.tracer(origin,end,Color("ff9972"))
			if world.rng.randf() < 0.52:
				if target == world.player:
					target.damage(9.0)
				else:
					target.damage(16.0,self)
	if Vector2(position.x,position.z).length() > world.zone_radius:
		damage(10*delta,null)

func damage(amount: float, attacker):
	if not alive:
		return
	health -= amount
	if is_instance_valid(attacker):
		target = attacker
	if health <= 0:
		alive = false
		collision_layer = 0
		rotation.z = PI/2
		position.y = 0.35
		if attacker == world.player:
			world.kills += 1
		world.message = "A banner has fallen. %d fighters remain." % world.alive_count()
		world.check_win()
