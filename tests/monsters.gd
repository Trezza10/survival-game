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
	var body: Sprite2D = player.get_node("Body")
	var atlas: AtlasTexture = body.texture
	verify(atlas.atlas.resource_path == "res://assets/sheets/default_player.png", "new player sprite is assigned")
	verify(is_equal_approx(body.scale.y * atlas.region.size.y,42.0), "player keeps existing world height")
	verify(get_nodes_in_group("monsters").size() == 29, "all 29 supplied monster designs placed")
	verify(get_nodes_in_group("slime_lights").size() == 9, "all nine slimes have colored lights")
	var stationary := true
	var positions: Array[Vector2] = []
	for monster in get_nodes_in_group("monsters"):
		if not monster.is_in_group("hoppers") and not monster.is_in_group("wildlife") and not monster.is_in_group("creature_motion"):
			stationary = stationary and monster.get_script() == null
		positions.append(monster.position)
		var sprite: Sprite2D = monster.get_node("Sprite")
		var texture: AtlasTexture = sprite.texture
		var normal: Texture2D = sprite.material.get_shader_parameter("normal_atlas")
		verify(texture.atlas.get_size() == normal.get_size(), monster.name + " has aligned normals")
	verify(stationary, "non-hopping monsters remain passive props")
	for i in range(10):
		await physics_frame
	var index := 0
	for monster in get_nodes_in_group("monsters"):
		if not monster.is_in_group("hoppers") and not monster.is_in_group("wildlife") and not monster.is_in_group("creature_motion"):
			stationary = stationary and monster.position == positions[index]
		index += 1
	verify(stationary, "non-hopping NPCs remain stationary")
	for light in get_nodes_in_group("slime_lights"):
		verify(light.enabled and light.energy > 0.0 and light.get_parent().has_node("SurfaceGlow"), light.get_parent().name + " emits colored glow")
	verify(player.get_node("Camera").is_current(), "follow camera remains attached to new player")
	print("Monster failures: %d" % failures)
	quit(1 if failures else 0)
