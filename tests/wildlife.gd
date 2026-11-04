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
	verify(get_nodes_in_group("rabbits").size() == 4, "all four rabbits use their own hop profile")
	verify(get_nodes_in_group("wildlife").size() == 24, "all requested animals plus monster hog and bee have passive behaviors")
	var profiles: Dictionary = {}
	var positions: Dictionary = {}
	for actor in get_nodes_in_group("ground_wildlife"):
		profiles[actor.species] = actor
		positions[actor.name] = actor.position
	verify(profiles.size() == 8, "eight distinct wandering and flight profiles")
	verify(profiles["squirrel"].walk_speed > profiles["fox"].walk_speed and profiles["fox"].walk_speed > profiles["raccoon"].walk_speed and profiles["hedgehog"].walk_speed < profiles["hog"].walk_speed, "species pacing is distinct")
	var owl_positions: Dictionary = {}
	for owl in get_nodes_in_group("perched_owls"):
		verify(owl.get_parent().name.begins_with("EnvironmentTree") and owl.get_node("Feet").disabled and not owl.get_node("GroundShadow").visible, owl.name + " is perched on a tree without ground collision")
		owl_positions[owl.name] = owl.position
	var rabbit = get_nodes_in_group("rabbits")[0]
	rabbit.start_gather()
	var highest := 0.0
	for i in range(300):
		await physics_frame
		highest = maxf(highest,rabbit.jump_height)
	verify(highest > 6.0 and highest < 13.0, "rabbits use quick low hops")
	var moved := 0
	var bounded := true
	for actor in get_nodes_in_group("ground_wildlife"):
		if actor.position.distance_to(positions[actor.name]) > 1.0:
			moved += 1
		bounded = bounded and actor.position.distance_to(actor.home) <= actor.wander_radius + 8.0
	verify(moved >= 8, "wildlife wanders through the meadow")
	verify(bounded, "wildlife remains near its local home")
	var bee = profiles["bee"]
	verify(bee.sprite.position.y < bee.base_position.y - 8.0 and bee.shadow.modulate.a < 0.6, "bee hovers above a softened ground shadow")
	for owl in get_nodes_in_group("perched_owls"):
		verify(owl.position == owl_positions[owl.name] and owl.clock > 0.0, owl.name + " stays on its perch while idling")
	paused = true
	var snapshots: Dictionary = {}
	for actor in get_nodes_in_group("wildlife"):
		snapshots[actor.name] = [actor.position,actor.get_node("Sprite").position,actor.get_node("Sprite").rotation]
	for i in range(10):
		await process_frame
	var frozen := true
	for actor in get_nodes_in_group("wildlife"):
		var before: Array = snapshots[actor.name]
		frozen = frozen and actor.position == before[0] and actor.get_node("Sprite").position == before[1] and actor.get_node("Sprite").rotation == before[2]
	verify(frozen, "pause freezes every animal gait, hop, hover and owl idle")
	paused = false
	print("Wildlife failures: %d" % failures)
	quit(1 if failures else 0)
