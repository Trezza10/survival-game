extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/playground.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	var hero = scene.get_node("Actors/Player")
	var axe = hero.get_node("Axe")
	var tree = scene.get_node("Actors/EnvironmentTree01")
	hero.position = Vector2(600,850)
	tree.position = Vector2(600,810)
	await physics_frame
	axe.facing = Vector2.UP
	var touch = get_first_node_in_group("touch_controls")
	var button := InputEventScreenTouch.new()
	button.position = Vector2(touch.size.x-90,touch.size.y-90)
	button.pressed = true
	button.index = 1
	touch._input(button)
	assert(axe.target == tree)
	axe.try_swing()
	for i in range(24): await physics_frame
	assert(tree.hits == 1, "cooldown prevents repeated damage per swing")
	assert(not tree.felled)
	assert(tree.get_node("Stump").material.get_shader_parameter("normal_atlas") != null)
	for hit in range(3):
		for i in range(12): await physics_frame
		axe.try_swing()
		for i in range(30): await physics_frame
	assert(tree.felled and tree.hits == 4)
	assert(tree.get_node("Feet").disabled)
	assert(tree.get_node("Stump").visible)
	var fall_clock: float = tree.falling_time
	paused = true
	for i in range(8): await process_frame
	assert(tree.falling_time == fall_clock)
	paused = false
	for i in range(60): await physics_frame
	assert(not tree.get_node("Sprite").visible)
	axe.try_swing()
	assert(axe.target != tree)
	for i in range(30): await physics_frame
	assert(tree.hits == 4)
	print("PASS: mobile axe, targeting, cooldown, four-hit felling, mapped stump, cleared collision, pause and no repeat damage")
	quit()
