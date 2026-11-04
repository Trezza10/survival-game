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
	var creatures = get_nodes_in_group("creature_motion")
	verify(creatures.size() == 15, "all remaining monster designs have saved motion profiles")
	var positions: Dictionary = {}
	var styles: Dictionary = {}
	for actor in creatures:
		positions[actor.name] = actor.position
		styles[actor.motion_style] = actor
	verify(styles.size() == 15, "each added monster has its own profile")
	verify(styles["rat"].walk_speed > styles["goblin"].walk_speed and styles["goblin"].walk_speed > styles["golem"].walk_speed and styles["golem"].walk_speed > styles["tree_giant"].walk_speed, "scurrying, patrolling and lumbering speeds differ")
	for i in range(360):
		await physics_frame
	var moved := 0
	var bounded := true
	for actor in creatures:
		if actor.position.distance_to(positions[actor.name]) > 1.0:
			moved += 1
		bounded = bounded and actor.position.distance_to(actor.home) <= actor.wander_radius + 8.0
	verify(moved >= 8, "mobile monsters wander or fly")
	verify(bounded, "monster motion remains local")
	verify(styles["plant"].position == positions[styles["plant"].name] and styles["runestone"].position == positions[styles["runestone"].name], "plant and runestone stay rooted")
	for style in ["bat","wisp","fire_wisp"]:
		var actor = styles[style]
		verify(actor.sprite.position.y < actor.base_position.y - 4.0 and actor.shadow.modulate.a < .6 and actor.collision_layer == 0, style + " floats above a soft ground shadow")
	paused = true
	var snapshots: Dictionary = {}
	for actor in creatures:
		snapshots[actor.name] = [actor.position,actor.sprite.position,actor.sprite.scale,actor.sprite.rotation,actor.clock]
	for i in range(10):
		await process_frame
	var frozen := true
	for actor in creatures:
		var before: Array = snapshots[actor.name]
		frozen = frozen and actor.position == before[0] and actor.sprite.position == before[1] and actor.sprite.scale == before[2] and actor.sprite.rotation == before[3] and actor.clock == before[4]
	verify(frozen, "pause freezes all new monster movement and idle animation")
	paused = false
	print("Creature motion failures: %d" % failures)
	quit(1 if failures else 0)
