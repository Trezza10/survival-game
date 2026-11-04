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
	var wind = scene.get_node("Wind")
	verify(wind.materials.size() == 60, "living trees and all foliage have paired wind/shadow materials")
	var start: float = wind.wind_time
	for i in range(8):
		await process_frame
	verify(wind.wind_time > start, "wind animation advances")
	var clocks_match := true
	for material in wind.materials:
		if not is_equal_approx(material.get_shader_parameter("wind_time"), wind.wind_time):
			clocks_match = false
	verify(clocks_match, "color, normal and shadow materials share wind clock")
	var leaves: CPUParticles2D = wind.get_node("DriftingLeaves")
	verify(leaves.emitting and leaves.amount == 110, "increased drifting pixel leaves")
	verify(wind.get_node("WindStreaks").emitting and wind.get_node("WindStreaks").amount == 38, "wind streak particles are emitting")
	var emitters = get_nodes_in_group("tree_leaf_emitters")
	verify(emitters.size() > 20, "living tree canopies emit leaves")
	var canopy_origins := true
	for emitter in emitters:
		canopy_origins = canopy_origins and emitter.emitting and emitter.position.y < -30 and emitter.get_parent().name.begins_with("EnvironmentTree")
	verify(canopy_origins, "tree leaves originate in the canopies")
	var anchored := true
	for visual in get_nodes_in_group("wind_visuals"):
		if visual.material.get_shader_parameter("wind_anchor") <= 0.0:
			anchored = false
	verify(anchored, "wind materials preserve anchored lower portions")
	paused = true
	start = wind.wind_time
	for i in range(8):
		await process_frame
	verify(wind.wind_time == start and not leaves.can_process(), "pause freezes wind and leaf particles")
	var paused_particles := true
	for emitter in get_nodes_in_group("wind_particles"):
		paused_particles = paused_particles and not emitter.can_process()
	verify(paused_particles, "pause freezes every streak and canopy emitter")
	paused = false
	var hero_visual = scene.get_node("Actors/Player/Body")
	verify(not hero_visual.is_in_group("wind_visuals") and not hero_visual.material.get_shader_parameter("wind_amplitude"), "player is unaffected by wind")
	for npc in get_nodes_in_group("npcs"):
		var visual = npc.get_node("Sprite")
		verify(not visual.is_in_group("wind_visuals") and not visual.material.get_shader_parameter("wind_amplitude"), npc.name + " is not wind-deformed")
	print("Wind failures: %d" % failures)
	quit(1 if failures else 0)
