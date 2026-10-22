extends SceneTree

func _initialize():
	call_deferred("capture")

func capture():
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.menu.hide()
	scene.player.position = Vector3(0,1,40)
	scene.player.camera.rotation.x = -0.03
	scene.started = true
	scene._process(0.016)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../3d-preview.png")
	quit()
