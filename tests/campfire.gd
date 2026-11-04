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
	var fire = scene.get_node("Actors/Campfire")
	var sprite: AnimatedSprite2D = fire.get_node("Sprite")
	var particles: CPUParticles2D = fire.get_node("Embers")
	verify(sprite.sprite_frames.get_frame_count("burn") == 3 and sprite.is_playing(), "three supplied campfire frames animate")
	verify(particles.emitting and particles.amount == 18, "pixel embers are emitting")
	verify(fire.get_node("FireLight").color.r > fire.get_node("FireLight").color.b, "warm red-orange point light")
	var normal: Texture2D = sprite.material.get_shader_parameter("normal_atlas")
	var atlas: AtlasTexture = sprite.sprite_frames.get_frame_texture("burn",0)
	verify(normal != null and normal.get_size() == atlas.atlas.get_size(), "all animation frames have aligned normal atlas")
	var start: float = fire.flicker_time
	for i in range(12):
		await process_frame
	verify(fire.flicker_time > start, "light flicker advances")
	paused = true
	start = fire.flicker_time
	var frame := sprite.frame
	var progress := sprite.frame_progress
	for i in range(8):
		await process_frame
	verify(fire.flicker_time == start and sprite.frame == frame and sprite.frame_progress == progress, "pause freezes fire animation and flicker")
	verify(not particles.can_process(), "pause suspends particle simulation")
	paused = false
	print("Campfire failures: %d" % failures)
	quit(1 if failures else 0)
