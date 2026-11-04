extends SceneTree

var failures := 0

func verify(ok: bool, label: String) -> void:
	if ok:
		print("PASS: " + label)
	else:
		failures += 1
		push_error(label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/playground.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	var player = scene.get_node("Actors/Player")
	var camera: Camera2D = player.get_node("Camera")
	verify(ProjectSettings.get_setting("display/window/size/viewport_width") == 1280 and ProjectSettings.get_setting("display/window/size/viewport_height") == 720, "1280 by 720 widescreen viewport")
	verify(ProjectSettings.get_setting("display/window/stretch/aspect") == "keep", "aspect ratio preserved during resize")
	verify(get_root().get_camera_2d() == camera and camera.position_smoothing_enabled, "saved smooth follow camera is active")
	verify(camera.get_parent() == player and camera.get_parent() != player.get_node("Body"), "camera follows body position rather than walking bob")
	var half_view := Vector2(1280,720) / camera.zoom * 0.5
	for point in [Vector2(16,36),Vector2(1184,884),Vector2(600,450)]:
		player.position = point
		await physics_frame
		camera.reset_smoothing()
		camera.force_update_scroll()
		var center := camera.get_screen_center_position()
		verify(center.x-half_view.x >= -1.0 and center.y-half_view.y >= -1.0 and center.x+half_view.x <= 1201.0 and center.y+half_view.y <= 901.0, "camera view stays inside meadow at " + str(point))
	print("Camera failures: %d" % failures)
	quit(1 if failures else 0)
