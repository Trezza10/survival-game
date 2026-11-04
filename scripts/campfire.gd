extends StaticBody2D

@export var light_energy: float = 1.05
var flicker_time: float = 0.0
@onready var light: PointLight2D = $FireLight
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var flame: AnimatedSprite2D = $FlameGlow

func _process(delta: float) -> void:
	flicker_time += delta
	var pulse := sin(flicker_time * 7.3) * 0.07 + sin(flicker_time * 13.7 + 1.3) * 0.04 + sin(flicker_time * 3.1) * 0.04
	light.energy = light_energy * (1.0 + pulse)
	light.texture_scale = 0.75 + pulse * 0.025
	flame.frame = sprite.frame
	flame.frame_progress = sprite.frame_progress
