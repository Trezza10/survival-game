extends CharacterBody2D

@export var walk_speed: float = 175.0
@export var acceleration: float = 1000.0
@export var deceleration: float = 1400.0
@export var bob_height: float = 1.5
@export var stride_length: float = 34.0
var distance_walked: float = 0.0
@onready var body: Sprite2D = $Body
@onready var rest_y: float = $Body.position.y

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var touch := get_tree().get_first_node_in_group("touch_controls")
	if touch != null and touch.direction.length_squared() > direction.length_squared():
		direction = touch.direction
	var rate := acceleration if direction.length_squared() > 0.0 else deceleration
	velocity = velocity.move_toward(direction * walk_speed, rate * delta)
	var before := position
	move_and_slide()
	position = position.clamp(Vector2(16, 36), Vector2(1184, 884))
	var traveled := position.distance_to(before)
	if traveled > 0.01:
		distance_walked += traveled
		body.position.y = rest_y - absf(sin(distance_walked / stride_length * PI)) * bob_height
	else:
		body.position.y = move_toward(body.position.y, rest_y, 10.0 * delta)
