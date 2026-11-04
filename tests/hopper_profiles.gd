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
	var frogs = get_nodes_in_group("frogs")
	var mushrooms = get_nodes_in_group("mushroom_hoppers")
	verify(frogs.size() == 2 and mushrooms.size() == 3, "two frogs and three mushroom creatures have profiles")
	var frog = scene.get_node("Actors/Frog")
	var red = scene.get_node("Actors/MonsterRedMushroom")
	var gold = scene.get_node("Actors/MonsterGoldMushroom")
	var giant = scene.get_node("Actors/MonsterMushroomGiant")
	verify(frog.hop_distance > red.hop_distance * 2.0 and frog.air_max < red.air_min, "frogs leap farther and faster than mushrooms")
	verify(frog.ground_acceleration > gold.ground_acceleration and gold.ground_acceleration > giant.ground_acceleration, "frog launch and mushroom weight have different acceleration")
	verify(gold.hop_height > red.hop_height and giant.gather_seconds > red.gather_seconds and giant.land_seconds > gold.land_seconds, "gold mushroom is springier and giant settles slowly")
	verify(frog.arc_style == 1 and frog.crouch_amount.y < red.crouch_amount.y, "frogs use a firmer body and ballistic arc")
	var actors: Array = frogs + mushrooms
	var heights: Dictionary = {}
	var landed: Dictionary = {}
	for actor in actors:
		heights[actor.name] = 0.0
		landed[actor.name] = false
		actor.start_gather()
	for i in range(130):
		await physics_frame
		for actor in actors:
			heights[actor.name] = maxf(heights[actor.name], actor.jump_height)
			landed[actor.name] = landed[actor.name] or actor.state == actor.HopState.LAND
	for actor in actors:
		verify(heights[actor.name] > actor.hop_height * 0.95 and landed[actor.name], actor.name + " completes its distinct jump arc and landing")
		verify(actor.position.distance_to(actor.home) <= actor.wander_radius + 1.0, actor.name + " stays in its local area")
	paused = true
	var snapshots: Dictionary = {}
	for actor in actors:
		snapshots[actor.name] = [actor.position, actor.sprite.position, actor.state_time]
	for i in range(8):
		await process_frame
	var frozen := true
	for actor in actors:
		var before: Array = snapshots[actor.name]
		frozen = frozen and actor.position == before[0] and actor.sprite.position == before[1] and actor.state_time == before[2]
	verify(frozen, "pause freezes frog and mushroom movement and animation")
	paused = false
	print("Hopper profile failures: %d" % failures)
	quit(1 if failures else 0)
