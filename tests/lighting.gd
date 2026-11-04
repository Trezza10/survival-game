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
	var lighting = scene.get_node("Lighting")
	lighting.cycle_enabled = false
	verify(get_nodes_in_group("ground_shadows").size() == 23 + get_nodes_in_group("environment").size() + get_nodes_in_group("monsters").size(), "animals, player, monsters and environment have saved shadows")
	var mapped_visuals: Array[Node] = get_nodes_in_group("environment")
	mapped_visuals.append_array(get_nodes_in_group("npcs"))
	mapped_visuals.append_array(get_nodes_in_group("monsters"))
	mapped_visuals.append(scene.get_node("Actors/Player"))
	var normal_coverage := true
	for owner in mapped_visuals:
		var visual: Sprite2D = owner.get_node("Body" if owner.name == "Player" else "Sprite")
		var material: ShaderMaterial = visual.material
		var normal: Texture2D = material.get_shader_parameter("normal_atlas")
		var atlas: AtlasTexture = visual.texture
		if normal == null or normal.get_size() != atlas.atlas.get_size():
			normal_coverage = false
	verify(normal_coverage, "all animals, scenery and player have aligned normal-map atlases")
	var animal_designs: Dictionary = {}
	for npc in get_nodes_in_group("npcs"):
		var sprite: Sprite2D = npc.get_node("Sprite")
		var atlas: AtlasTexture = sprite.texture
		verify(atlas.atlas.resource_path == "res://assets/sheets/forest_animals.png", npc.name + " uses replacement animal sheet")
		animal_designs[atlas.region] = true
	verify(animal_designs.size() == 10, "all ten replacement animal designs are used")
	verify(get_nodes_in_group("normal_demo_lights").size() == 6, "player and five demonstration lights are saved in scene")
	var hero = scene.get_node("Actors/Player")
	var lamp: PointLight2D = hero.get_node("PlayerLight")
	var lamp_start := lamp.global_position
	hero.position.x += 10.0
	verify(lamp.global_position == lamp_start + Vector2(10,0), "player light follows the player")
	hero.position.x -= 10.0
	lighting.time_of_day = 0.38
	lighting.update_lighting()
	var day_color: Color = lighting.ambient.color
	verify(lighting.sun.energy > 0.5 and is_zero_approx(lighting.moon.energy), "day uses sun")
	var day_transform: Transform2D = get_nodes_in_group("ground_shadows")[0].transform
	lighting.time_of_day = 0.65
	lighting.update_lighting()
	verify(day_transform != get_nodes_in_group("ground_shadows")[0].transform, "sun movement changes shadow projection")
	lighting.time_of_day = 0.0
	lighting.update_lighting()
	verify(is_zero_approx(lighting.sun.energy) and lighting.moon.energy > 0.3, "night uses moon")
	verify(lighting.ambient.color.get_luminance() < day_color.get_luminance(), "night ambient is darker")
	lighting.cycle_enabled = true
	var before: float = lighting.time_of_day
	for i in range(5):
		await process_frame
	verify(lighting.time_of_day != before, "cycle advances")
	paused = true
	before = lighting.time_of_day
	for i in range(5):
		await process_frame
	verify(lighting.time_of_day == before, "pause freezes lighting")
	paused = false
	print("Lighting failures: %d" % failures)
	quit(1 if failures else 0)
