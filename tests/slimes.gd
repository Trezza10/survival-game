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
	var slimes = get_nodes_in_group("slimes")
	verify(slimes.size() == 9, "all nine slimes have hopping behavior")
	var slime = slimes[0]
	# An open spot gives a deterministic movement/collision exercise.
	slime.position = Vector2(600,400)
	slime.home = slime.position
	slime.start_gather()
	var start: Vector2 = slime.position
	var max_height := 0.0
	var gathered := false
	var landed := false
	var aligned := true
	for i in range(85):
		await physics_frame
		max_height = maxf(max_height, slime.jump_height)
		gathered = gathered or (slime.state == slime.HopState.GATHER and slime.sprite.scale.y < slime.base_scale.y)
		landed = landed or slime.state == slime.HopState.LAND
		aligned = aligned and slime.sprite.position.is_equal_approx(slime.glow.position) and slime.sprite.scale.is_equal_approx(slime.glow.scale)
	verify(gathered and max_height > 8.0 and landed, "anticipation squish, airborne hop and landing squash occur")
	verify(slime.position.distance_to(start) > 2.0, "slime wanders during hop")
	verify(aligned, "colored glow follows squash and stretch exactly")
	verify(slime.position.distance_to(slime.home) <= slime.wander_radius + 1.0, "slime stays near its home")
	paused = true
	var held_position: Vector2 = slime.position
	var held_pose: Vector2 = slime.sprite.position
	var held_time: float = slime.state_time
	for i in range(8):
		await process_frame
	verify(slime.position == held_position and slime.sprite.position == held_pose and slime.state_time == held_time, "pause freezes slime movement and animation")
	paused = false
	# Blocking scenery should result in a safe alternate direction or in-place hop.
	for actor in slimes:
		verify(actor is CharacterBody2D and actor.collision_mask == 3, actor.name + " uses collision-aware movement")
	print("Slime failures: %d" % failures)
	quit(1 if failures else 0)
