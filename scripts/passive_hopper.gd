extends CharacterBody2D

enum HopState { REST, GATHER, AIR, LAND }
@export var wander_radius: float = 75.0
@export var hop_height: float = 12.0
@export var hop_distance: float = 28.0
@export var gather_seconds: float = 0.18
@export var land_seconds: float = 0.24
@export var air_min: float = 0.46
@export var air_max: float = 0.64
@export var rest_min: float = 0.7
@export var rest_max: float = 2.0
@export var ground_acceleration: float = 0.0
@export_range(0.0,1.0) var launch_speed_ratio: float = 1.0
@export var crouch_amount := Vector2(0.23,0.26)
@export var takeoff_stretch := Vector2(0.84,1.22)
@export var landing_amount := Vector2(0.30,0.28)
@export var landing_wobble: float = 0.0
@export_enum("Soft", "Ballistic") var arc_style: int = 0
@export var face_travel: bool = false
var state := HopState.REST
var state_time: float = 0.0
var rest_duration: float = 1.0
var air_duration: float = 0.52
var jump_height: float = 0.0
var home := Vector2.ZERO
var hop_velocity := Vector2.ZERO
var rng := RandomNumberGenerator.new()
@onready var sprite: Sprite2D = $Sprite
@onready var glow: Sprite2D = get_node_or_null("SurfaceGlow")
@onready var silhouette: Sprite2D = $GroundShadow/Silhouette
@onready var halo: Sprite2D = get_node_or_null("SoftHalo")
@onready var light: PointLight2D = get_node_or_null("ColorGlow")
var base_scale := Vector2.ONE
var base_position := Vector2.ZERO
var shadow_scale := Vector2.ONE
var shadow_position := Vector2.ZERO
var halo_scale := Vector2.ONE
var halo_alpha: float = 0.13
var light_position := Vector2.ZERO
var sprite_height: float = 0.0

func _ready() -> void:
	home = position
	rng.seed = int(position.x * 137.0 + position.y * 719.0)
	rest_duration = rng.randf_range(rest_min * 0.65, rest_max)
	base_scale = sprite.scale
	base_position = sprite.position
	shadow_scale = silhouette.scale
	shadow_position = silhouette.position
	if halo != null:
		halo_scale = halo.scale
		halo_alpha = halo.modulate.a
	if light != null:
		light_position = light.position
	sprite_height = sprite.texture.get_height() * base_scale.y

func _physics_process(delta: float) -> void:
	state_time += delta
	match state:
		HopState.REST:
			pose(Vector2.ONE, 0.0)
			if state_time >= rest_duration:
				start_gather()
		HopState.GATHER:
			var t := clampf(state_time / gather_seconds, 0.0, 1.0)
			pose(Vector2(1.0 + crouch_amount.x * t, 1.0 - crouch_amount.y * t), 0.0)
			if t >= 1.0:
				state = HopState.AIR
				state_time = 0.0
				velocity = hop_velocity * launch_speed_ratio
		HopState.AIR:
			var t := clampf(state_time / air_duration, 0.0, 1.0)
			if ground_acceleration > 0.0:
				velocity = velocity.move_toward(hop_velocity, ground_acceleration * delta)
			else:
				velocity = hop_velocity
			move_and_slide()
			position = position.clamp(Vector2(18, 28), Vector2(1182, 880))
			if get_slide_collision_count() > 0:
				hop_velocity = velocity
			var stretch := takeoff_stretch.lerp(Vector2(1.05, 0.96), smoothstep(0.18, 0.9, t))
			var arc := 4.0 * t * (1.0 - t) if arc_style == 1 else sin(t * PI)
			pose(stretch, arc * hop_height)
			if t >= 1.0:
				velocity = Vector2.ZERO
				state = HopState.LAND
				state_time = 0.0
		HopState.LAND:
			var t := clampf(state_time / land_seconds, 0.0, 1.0)
			var squash := sin(t * PI) * (1.0 - t * 0.5)
			pose(Vector2(1.0 + squash * landing_amount.x, 1.0 - squash * landing_amount.y), 0.0)
			sprite.rotation = sin(t * TAU * 1.5) * (1.0 - t) * landing_wobble
			if t >= 1.0:
				state = HopState.REST
				state_time = 0.0
				rest_duration = rng.randf_range(rest_min, rest_max)

func start_gather() -> void:
	state = HopState.GATHER
	state_time = 0.0
	air_duration = rng.randf_range(air_min, air_max)
	var distance := hop_distance * rng.randf_range(0.65, 1.2)
	hop_velocity = Vector2.ZERO
	for attempt in range(10):
		var direction := Vector2.from_angle(rng.randf_range(0.0, TAU))
		if position.distance_to(home) > wander_radius * 0.65:
			direction = position.direction_to(home).rotated(rng.randf_range(-0.5, 0.5))
		var target := position + direction * distance
		if target.distance_to(home) > wander_radius or not Rect2(18,28,1164,852).has_point(target):
			continue
		if test_move(global_transform, direction * distance):
			continue
		hop_velocity = direction * distance / air_duration
		break
	if face_travel and absf(hop_velocity.x) > 1.0:
		sprite.flip_h = hop_velocity.x > 0.0
		silhouette.flip_h = sprite.flip_h
	# If surrounded, bounce in place and choose again after landing.

func pose(deformation: Vector2, height: float) -> void:
	jump_height = height
	var local_height := height / maxf(absf(global_scale.y), 0.001)
	sprite.rotation = 0.0
	sprite.scale = base_scale * deformation
	var foot_y := base_position.y + sprite_height * 0.5
	sprite.position = Vector2(base_position.x, foot_y - sprite_height * deformation.y * 0.5 - local_height)
	if glow != null:
		glow.scale = sprite.scale
		glow.position = sprite.position
	var airborne := clampf(height / maxf(hop_height, 0.1), 0.0, 1.0)
	var shrink := lerpf(1.0, 0.72, airborne)
	silhouette.scale = shadow_scale * shrink
	silhouette.position.y = shadow_position.y + sprite_height * 0.5 * (1.0 - shrink)
	silhouette.modulate.a = lerpf(1.0, 0.5, airborne)
	if halo != null:
		halo.scale = halo_scale * lerpf(1.0, 0.85, airborne)
		halo.modulate.a = halo_alpha * lerpf(1.0, 0.65, airborne)
	if light != null:
		light.position = light_position - Vector2(0, local_height * 0.5)
