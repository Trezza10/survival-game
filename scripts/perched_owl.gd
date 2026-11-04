extends Node2D

var clock: float = 0.0
var look_time: float = 0.0
var look_interval: float = 4.0
var rng := RandomNumberGenerator.new()
var base_position := Vector2.ZERO
var base_scale := Vector2.ONE
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	rng.seed = int(global_position.x * 93.0 + global_position.y * 131.0)
	clock = rng.randf_range(0.0,20.0)
	look_interval = rng.randf_range(3.5,7.0)
	base_position = sprite.position
	base_scale = sprite.scale

func _physics_process(delta: float) -> void:
	clock += delta
	look_time += delta
	sprite.position.y = base_position.y - sin(clock * 1.4) * 0.4
	sprite.scale.y = base_scale.y * (1.0 + sin(clock * 1.4) * 0.015)
	sprite.rotation = sin(clock * 0.8) * 0.022
	if look_time > look_interval:
		sprite.flip_h = not sprite.flip_h
		look_time = 0.0
		look_interval = rng.randf_range(3.5,7.0)
