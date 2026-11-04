extends StaticBody2D

@export var hits_required := 4
var hits := 0
var felled := false
var shake := 0.0
var clock := 0.0
var fall_sign := 1.0
var falling_time := 0.0
@onready var visual: Sprite2D = $Sprite
@onready var silhouette: Sprite2D = $GroundShadow/Silhouette
@onready var base_position := visual.position

func chop(direction: Vector2) -> void:
	if felled:
		return
	hits += 1
	shake = 1.0
	$WoodChips.amount = 30 if hits >= hits_required else 14
	$WoodChips.restart()
	$HitSound.pitch_scale = 0.92 + hits * 0.06
	$HitSound.play()
	if hits >= hits_required:
		felled = true
		fall_sign = 1.0 if direction.x >= 0 else -1.0
		$Feet.set_deferred("disabled",true)
		$Stump.visible = true
		if has_node("CanopyLeaves"):
			$CanopyLeaves.emitting = false
		$FallSound.play()
		# Existing perched owls depart rather than remaining on a falling tree.
		for owl in get_children():
			if owl.is_in_group("perched_owls"):
				owl.set_physics_process(false)
				var flight := create_tween().set_parallel(true)
				flight.tween_property(owl,"position",owl.position+Vector2(150*fall_sign,-180),0.85)
				flight.tween_property(owl,"modulate:a",0.0,0.85)

func _physics_process(delta: float) -> void:
	clock += delta
	if felled:
		falling_time += delta
		var t := clampf(falling_time / 0.75,0,1)
		var angle := fall_sign * t*t * 1.45
		visual.rotation = angle
		visual.position = base_position.rotated(angle)
		visual.modulate.a = 1.0 - smoothstep(0.65,1.0,t)
		silhouette.rotation = angle
		silhouette.position = base_position.rotated(angle)
		silhouette.modulate.a = visual.modulate.a
		if t >= 1:
			visual.visible = false
			$GroundShadow.visible = false
			set_physics_process(false)
	else:
		shake = move_toward(shake,0,delta*4.0)
		visual.rotation = sin(clock*65)*0.035*shake
		visual.position = base_position + Vector2(sin(clock*85)*1.8*shake,0)
		silhouette.rotation = visual.rotation
		silhouette.position = visual.position
