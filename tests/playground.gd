extends SceneTree

var failures := 0

func verify(condition: bool, label: String) -> void:
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/playground.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	var player = scene.get_node("Actors/Player")
	verify(not scene.has_node("Grid") and scene.has_node("Ground"), "continuous meadow replaces grid")
	verify(get_nodes_in_group("npcs").size() == 22, "22 existing animal placements preserved")
	var positions: Array[Vector2] = []
	for npc in get_nodes_in_group("npcs"):
		positions.append(npc.position)
		if not npc.is_in_group("hoppers") and not npc.is_in_group("wildlife"):
			verify(npc.get_script() == null, "%s has no behavior" % npc.name)
	var start: Vector2 = player.position
	Input.action_press("move_right", 0.5)
	for i in range(20):
		await physics_frame
	verify(player.position.x > start.x + 10.0, "smooth analog walking")
	verify(player.velocity.length() < player.walk_speed * 0.6, "half stick preserves half speed")
	Input.action_release("move_right")
	for i in range(15):
		await physics_frame
	verify(player.velocity.length() < 0.1, "stops after release")
	verify(is_zero_approx(player.get_node("Body").rotation), "no leaning")
	var event := InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	scene._unhandled_input(event)
	verify(paused, "pause enabled")
	var held_position: Vector2 = player.position
	Input.action_press("move_right")
	for i in range(10):
		await process_frame
	verify(player.position == held_position, "pause freezes player")
	scene._unhandled_input(event)
	verify(not paused, "same action resumes")
	Input.action_release("move_right")
	var index := 0
	for npc in get_nodes_in_group("npcs"):
		if not npc.is_in_group("hoppers") and not npc.is_in_group("wildlife"):
			verify(npc.position == positions[index], "%s stays stationary" % npc.name)
		index += 1
	# Walk directly into the feet of an animal; no damage or interaction occurs.
	var rabbit = scene.get_node("Actors/BrownRabbit")
	rabbit.set_physics_process(false)
	rabbit.position = Vector2(120,112)
	player.position = Vector2(120,160)
	player.velocity = Vector2.ZERO
	Input.action_press("move_up")
	for i in range(30):
		await physics_frame
	Input.action_release("move_up")
	verify(player.position.y > 120.0, "animal foot collision blocks walking")
	verify(not InputMap.has_action("attack") and not InputMap.has_action("dash"), "no combat or dash inputs")
	print("Playground checks finished; failures: %d" % failures)
	quit(1 if failures else 0)
