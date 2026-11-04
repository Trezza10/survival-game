extends Node2D

## 0 = midnight, 0.25 = sunrise, 0.5 = noon, 0.75 = sunset.
@export_range(0.0, 1.0) var time_of_day: float = 0.38
@export_range(15.0, 1200.0) var cycle_seconds: float = 120.0
@export var cycle_enabled: bool = true
@onready var ambient: CanvasModulate = $Ambient
@onready var sun: DirectionalLight2D = $Sun
@onready var moon: DirectionalLight2D = $Moon
var shadow_nodes: Array[Node] = []

func _ready() -> void:
	shadow_nodes = get_tree().get_nodes_in_group("ground_shadows")
	update_lighting()

func _process(delta: float) -> void:
	if cycle_enabled:
		time_of_day = fposmod(time_of_day + delta / cycle_seconds, 1.0)
	update_lighting()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("preview_lighting") and not event.is_echo():
		time_of_day = 0.0 if sun.energy > 0.2 else 0.38
		update_lighting()
		get_viewport().set_input_as_handled()

func update_lighting() -> void:
	var altitude := sin((time_of_day - 0.25) * TAU)
	var daylight := smoothstep(-0.16, 0.3, altitude)
	var moonlight := smoothstep(0.0, 0.35, -altitude)
	ambient.color = Color(0.20, 0.26, 0.40).lerp(Color(0.64, 0.67, 0.65), daylight)
	sun.energy = daylight * 0.67
	sun.color = Color(1.0, 0.57, 0.32).lerp(Color(1.0, 0.95, 0.82), smoothstep(0.05, 0.65, altitude))
	sun.rotation = lerpf(-1.1, 1.1, clampf((time_of_day - 0.25) / 0.5, 0.0, 1.0))
	sun.height = lerpf(0.18, 0.9, maxf(altitude, 0.0))
	moon.energy = moonlight * 0.38
	moon.height = lerpf(0.25, 0.7, maxf(-altitude, 0.0))
	var night_progress := fposmod(time_of_day - 0.75, 1.0) / 0.5
	moon.rotation = lerpf(-0.85, 0.85, clampf(night_progress, 0.0, 1.0))
	var active_light: DirectionalLight2D = sun if daylight >= moonlight else moon
	var direction := Vector2(-sin(active_light.rotation), cos(active_light.rotation))
	var elevation := maxf(altitude, 0.0) if active_light == sun else maxf(-altitude, 0.0)
	var length_scale := lerpf(1.25, 0.28, elevation)
	var opacity := daylight * 0.32 if active_light == sun else moonlight * 0.22
	for shadow in shadow_nodes:
		# Project the sprite's upright silhouette onto the ground from its feet.
		# These short shadows deliberately avoid infinite DirectionalLight2D streaks.
		shadow.transform = Transform2D(Vector2(1, 0), -direction * length_scale, Vector2.ZERO)
		shadow.modulate.a = opacity
