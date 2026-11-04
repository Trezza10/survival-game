extends CharacterBody2D

@export_enum("fox","raccoon","squirrel","duck","hog","deer","bee","hedgehog") var species: String = "fox"
@export var walk_speed: float = 40.0
@export var acceleration: float = 250.0
@export var wander_radius: float = 80.0
@export var walk_times := Vector2(0.8,2.0)
@export var rest_times := Vector2(0.8,2.0)
@export var step_frequency: float = 9.0
@export var bob_height: float = 1.0
var home := Vector2.ZERO
var target := Vector2.ZERO
var moving := false
var state_time: float = 0.0
var state_duration: float = 1.0
var clock: float = 0.0
var gait: float = 0.0
var rng := RandomNumberGenerator.new()
var base_position := Vector2.ZERO
var base_scale := Vector2.ONE
var shadow_scale := Vector2.ONE
@onready var sprite: Sprite2D = $Sprite
@onready var shadow: Sprite2D = $GroundShadow/Silhouette

func _ready() -> void:
	home = position
	target = position
	rng.seed = int(position.x * 347.0 + position.y * 911.0)
	clock = rng.randf_range(0.0,20.0)
	state_duration = rng.randf_range(0.3,rest_times.y)
	base_position = sprite.position
	base_scale = sprite.scale
	shadow_scale = shadow.scale

func _physics_process(delta: float) -> void:
	clock += delta
	state_time += delta
	if species == "bee":
		fly(delta)
		return
	if state_time >= state_duration or (moving and position.distance_to(target) < 5.0):
		if moving:
			rest()
		else:
			choose_target()
	var desired := position.direction_to(target) * walk_speed if moving else Vector2.ZERO
	velocity = velocity.move_toward(desired, acceleration * delta)
	move_and_slide()
	position = position.clamp(Vector2(18,28),Vector2(1182,880))
	if moving and get_slide_collision_count() > 0 and state_time > 0.12:
		rest()
	var amount := clampf(velocity.length() / maxf(walk_speed,1.0),0.0,1.0)
	gait += delta * step_frequency * amount
	var bob := absf(sin(gait)) * bob_height * amount
	var side := 0.0
	var tilt := 0.0
	if species == "duck":
		tilt = sin(gait) * 0.075 * amount
		side = sin(gait) * 0.7 * amount
	elif species == "squirrel":
		tilt = velocity.normalized().x * 0.045 * amount
	elif species == "hog" and not moving:
		tilt = sin(clock * 2.0) * 0.045
		bob = -maxf(0.0,sin(clock * 2.0)) * 0.7
	elif species == "deer" and not moving:
		tilt = sin(clock * 0.9) * 0.055
	elif species == "raccoon" and not moving:
		tilt = sin(clock * 1.8) * 0.025
	elif species == "hedgehog" and not moving:
		side = sin(clock * 2.4) * 0.2
	set_pose(bob,side,tilt)

func rest() -> void:
	moving = false
	state_time = 0.0
	state_duration = rng.randf_range(rest_times.x,rest_times.y)

func choose_target() -> void:
	rest()
	for attempt in range(12):
		var direction := Vector2.from_angle(rng.randf_range(0.0,TAU))
		if position.distance_to(home) > wander_radius * 0.6:
			direction = position.direction_to(home).rotated(rng.randf_range(-0.45,0.45))
		var distance := rng.randf_range(18.0,minf(65.0,wander_radius * 0.65))
		var candidate := position + direction * distance
		if not Rect2(18,28,1164,852).has_point(candidate) or candidate.distance_to(home) > wander_radius:
			continue
		if test_move(global_transform, direction * distance):
			continue
		target = candidate
		moving = true
		state_time = 0.0
		state_duration = rng.randf_range(walk_times.x,walk_times.y)
		break

func fly(delta: float) -> void:
	target = home + Vector2(sin(clock * 0.62) * wander_radius * 0.65,cos(clock * 0.91) * wander_radius * 0.42)
	target = target.clamp(Vector2(24,40),Vector2(1176,870))
	velocity = velocity.move_toward((target-position).limit_length(walk_speed),acceleration * delta)
	move_and_slide()
	moving = true
	var hover := 13.0 + sin(clock * 5.2) * 3.0
	set_pose(hover,0.0,sin(clock * 6.0) * 0.07)
	sprite.scale.x = base_scale.x * (1.0 + sin(clock * 32.0) * 0.035)
	shadow.scale = shadow_scale * 0.70
	shadow.modulate.a = 0.45

func set_pose(height: float, side: float, tilt: float) -> void:
	sprite.position = base_position + Vector2(side / maxf(absf(global_scale.x),0.001),-height / maxf(absf(global_scale.y),0.001))
	sprite.rotation = tilt
	if absf(velocity.x) > 3.0:
		sprite.flip_h = velocity.x > 0.0
		shadow.flip_h = sprite.flip_h
