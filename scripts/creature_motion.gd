extends "res://scripts/wildlife.gd"

@export_enum("goblin","armored","horned","golem","moss_golem","tree_giant","crystal","spider","rat","bat","wisp","fire_wisp","mage","plant","runestone") var motion_style: String = "goblin"

func _physics_process(delta: float) -> void:
	if motion_style in ["bat","wisp","fire_wisp"]:
		fly_creature(delta)
		return
	if motion_style in ["plant","runestone"]:
		clock += delta
		state_time += delta
		moving = false
		velocity = Vector2.ZERO
		var pulse := sin(clock * (2.4 if motion_style == "plant" else 1.4))
		var amount := 0.035 if motion_style == "plant" else 0.009
		var tilt := sin(clock * 1.15) * (0.045 if motion_style == "plant" else 0.01)
		set_pose(0.0,0.0,tilt)
		deform(Vector2(1.0 + pulse * amount,1.0 - pulse * amount),0.0)
		return
	super._physics_process(delta)
	var amount := clampf(velocity.length() / maxf(walk_speed,1.0),0.0,1.0)
	match motion_style:
		"goblin":
			set_pose(absf(sin(gait))*bob_height*amount,sin(gait)*0.5*amount,sin(gait)*0.035*amount)
		"armored", "horned":
			set_pose(absf(sin(gait))*bob_height*amount,0.0,sin(gait)*0.04*amount)
		"golem", "moss_golem", "tree_giant":
			var weight := 0.055 if motion_style == "golem" else 0.033
			set_pose(absf(sin(gait))*bob_height*amount,0.0,sin(gait)*weight*amount + sin(clock*.8)*.008)
			deform(Vector2(1.0+sin(clock*1.5)*.009,1.0-sin(clock*1.5)*.009),absf(sin(gait))*bob_height*amount)
		"crystal":
			set_pose(absf(sin(gait))*1.8*amount,0.0,sin(gait)*.06*amount)
		"spider":
			set_pose(absf(sin(gait))*.3*amount,sin(gait*1.3)*.35*amount,sin(gait)*.025*amount)
			deform(Vector2(1.0+sin(gait)*.035*amount,1.0-sin(gait)*.02*amount),0.0)
		"rat":
			set_pose(absf(sin(gait))*.3*amount,0.0,sin(clock*4.0)*.025 if not moving else velocity.normalized().x*.04)
		"mage":
			set_pose(5.0+sin(clock*1.9)*1.5,0.0,sin(clock*1.3)*.025)
			shadow.scale = shadow_scale*.82
			shadow.modulate.a = .7

func fly_creature(delta: float) -> void:
	clock += delta
	state_time += delta
	var bat := motion_style == "bat"
	var rate := 0.95 if bat else (0.65 if motion_style == "fire_wisp" else 0.42)
	var orbit := Vector2(sin(clock*rate),sin(clock*rate*2.0)*.45) if bat else Vector2(sin(clock*rate),cos(clock*rate*.83)*.65)
	target = (home + orbit * wander_radius * .72).clamp(Vector2(24,40),Vector2(1176,870))
	velocity = velocity.move_toward((target-position)*1.8,acceleration*delta).limit_length(walk_speed)
	move_and_slide()
	moving = true
	var height := 18.0+sin(clock*9.0)*2.5 if bat else 9.0+sin(clock*(5.0 if motion_style=="fire_wisp" else 2.4))*3.0
	set_pose(height,0.0,velocity.x/maxf(walk_speed,1.0)*.13 if bat else sin(clock*2.2)*.04)
	if bat:
		deform(Vector2(.84+absf(sin(clock*16.0))*.16,1.0),height)
	else:
		var pulse := sin(clock*(5.0 if motion_style=="fire_wisp" else 2.0))*.045
		deform(Vector2(1.0-pulse,1.0+pulse),height)
	shadow.scale = shadow_scale*.65
	shadow.modulate.a = .4

func deform(shape: Vector2, height: float) -> void:
	sprite.scale = base_scale*shape
	var body_height := sprite.texture.get_height()*base_scale.y
	var foot := base_position.y+body_height*.5
	sprite.position.y = foot-body_height*shape.y*.5-height/maxf(absf(global_scale.y),.001)
