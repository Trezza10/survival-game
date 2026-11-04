extends Node2D

const REACH := 64.0
const DURATION := 0.42
var elapsed := DURATION
var facing := Vector2.UP
var swing_direction := Vector2.UP
var target: Node2D
var impacted := false
@onready var hero: CharacterBody2D = get_parent()

func _physics_process(delta: float) -> void:
	if hero.velocity.length() > 12:
		facing = hero.velocity.normalized()
	if Input.is_action_just_pressed("swing_axe"):
		try_swing()
	if elapsed < DURATION:
		elapsed += delta
		if elapsed >= 0.15 and not impacted:
			impacted = true
			if is_instance_valid(target) and hero.global_position.distance_to(target.global_position) <= REACH + 6:
				target.chop(swing_direction)
		queue_redraw()

func try_swing() -> void:
	if get_tree().paused or elapsed < DURATION:
		return
	target = null
	var best := INF
	for tree in get_tree().get_nodes_in_group("choppable_trees"):
		var offset: Vector2 = tree.global_position - hero.global_position
		var distance := offset.length()
		if tree.felled or distance > REACH or distance < 1:
			continue
		var alignment := offset.normalized().dot(facing)
		if alignment < -0.25:
			continue
		var ray := PhysicsRayQueryParameters2D.create(hero.global_position - Vector2(0,4),tree.global_position - Vector2(0,4),1,[hero.get_rid()])
		var obstruction := hero.get_world_2d().direct_space_state.intersect_ray(ray)
		if not obstruction.is_empty() and obstruction.collider != tree:
			continue
		var score := distance - alignment * 12.0
		if score < best:
			best = score
			target = tree
	swing_direction = hero.global_position.direction_to(target.global_position) if target != null else facing
	elapsed = 0.0
	impacted = false
	$Whoosh.pitch_scale = randf_range(0.95,1.08)
	$Whoosh.play()
	queue_redraw()

func _draw() -> void:
	if elapsed >= DURATION:
		return
	var progress := clampf(elapsed / 0.28,0,1)
	var angle := swing_direction.angle() + lerpf(-1.65,1.1,1.0-pow(1.0-progress,3))
	var center := Vector2(0,-15)
	# A short stepped trail and a geometric axe need no new sprite frames.
	for i in range(4):
		var a := angle - i * 0.15
		draw_line(center + Vector2.from_angle(a)*23,center + Vector2.from_angle(a)*35,Color(1,0.92,0.65,(1-progress)*0.22),2)
	var shaft := Vector2.from_angle(angle)
	var side := shaft.orthogonal()
	draw_line(center+shaft*6,center+shaft*30,Color(0.30,0.17,0.09),5)
	draw_line(center+shaft*6,center+shaft*30,Color(0.68,0.43,0.22),2)
	var head := center + shaft * 29
	draw_colored_polygon(PackedVector2Array([head-shaft*5-side*3,head+shaft*5-side*3,head+shaft*7+side*11,head-shaft*7+side*11]),Color(0.76,0.83,0.84))
	draw_line(head-shaft*7+side*11,head+shaft*7+side*11,Color(1,0.97,0.82),2)
