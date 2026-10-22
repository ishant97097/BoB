extends SceneTree

func _initialize():
	call_deferred("run_checks")

func run_checks():
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	assert(scene.bots.size()==11,"Eleven opponents must spawn")
	assert(scene.alive_count()==12,"Match must start with twelve fighters")
	scene.started = true
	scene.menu.hide()
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for i in range(120):
		await physics_frame
	assert(scene.player.position.y>-1,"Player must remain above ground")
	scene.player.shoot()
	assert(scene.player.ammo==11,"Shot must consume ammunition")
	scene.player.health = 50
	scene.player.position = scene.pickups[0].node.position
	scene._process(0.016)
	assert(scene.player.health>=80,"Medical pickup must heal")
	scene.elapsed = 200
	scene._process(0.016)
	assert(scene.zone_radius<60,"Safe zone must shrink")
	scene.player.position = Vector3(0,0.5,10)
	scene.player.health = 100
	for bot in scene.bots:
		bot.damage(200,scene.player)
	assert(scene.finished,"Eliminating all opponents must end match")
	assert(scene.kills==11,"Player eliminations must be counted")
	print("PASS: spawn, physics, firing, healing, shrinking zone, elimination, victory")
	quit()
