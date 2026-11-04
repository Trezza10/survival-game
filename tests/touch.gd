extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/playground.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	var touch = get_first_node_in_group("touch_controls")
	var press := InputEventScreenTouch.new()
	press.index = 0
	press.position = Vector2(100,500)
	press.pressed = true
	touch._input(press)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(164,500)
	touch._input(drag)
	assert(touch.direction.is_equal_approx(Vector2.RIGHT))
	var hero = scene.get_node("Actors/Player")
	var start: Vector2 = hero.position
	for i in range(20): await physics_frame
	assert(hero.position.x > start.x + 10)
	press.pressed = false
	touch._input(press)
	assert(touch.direction == Vector2.ZERO)
	press.position = Vector2(touch.size.x - 40,40)
	press.pressed = true
	touch._input(press)
	assert(paused)
	touch._input(press)
	assert(not paused)
	print("PASS: touch walking, release and pause/resume")
	quit()
