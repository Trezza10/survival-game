extends Control

var direction := Vector2.ZERO
var finger := -1
var origin := Vector2.ZERO
var tip := Vector2.ZERO
const RADIUS := 64.0

func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		visible = true
		if event.pressed and event.position.distance_to(Vector2(size.x-90,size.y-90)) < 62:
			var axe := get_node("../../Actors/Player/Axe")
			axe.try_swing()
			get_viewport().set_input_as_handled()
		elif event.pressed and event.position.x > size.x - 96 and event.position.y < 96:
			get_tree().paused = not get_tree().paused
			_reset()
			get_viewport().set_input_as_handled()
		elif event.pressed and finger == -1 and event.position.x < size.x * 0.6 and not get_tree().paused:
			finger = event.index
			origin = event.position
			tip = origin
		elif not event.pressed and event.index == finger:
			_reset()
	elif event is InputEventScreenDrag and event.index == finger:
		tip = origin + (event.position - origin).limit_length(RADIUS)
		direction = (tip - origin) / RADIUS
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_reset()

func _reset() -> void:
	finger = -1
	direction = Vector2.ZERO
	queue_redraw()

func _draw() -> void:
	var axe_center := Vector2(size.x-90,size.y-90)
	draw_circle(axe_center,54,Color(0.12,0.16,0.12,0.7))
	draw_arc(axe_center,54,0,TAU,32,Color(0.9,0.85,0.64,0.65),2)
	draw_line(axe_center+Vector2(-14,19),axe_center+Vector2(12,-17),Color(0.72,0.48,0.26),7)
	draw_colored_polygon(PackedVector2Array([axe_center+Vector2(1,-17),axe_center+Vector2(14,-29),axe_center+Vector2(30,-10),axe_center+Vector2(16,0)]),Color(0.87,0.91,0.87))
	if finger != -1:
		draw_circle(origin, RADIUS, Color(1,1,1,0.12))
		draw_circle(tip, 24, Color(1,1,1,0.4))
	var p := Vector2(size.x - 52, 44)
	draw_circle(p, 28, Color(0,0,0,0.3))
	if get_tree().paused:
		draw_colored_polygon(PackedVector2Array([p+Vector2(-6,-10),p+Vector2(10,0),p+Vector2(-6,10)]), Color.WHITE)
	else:
		draw_rect(Rect2(p+Vector2(-9,-10),Vector2(5,20)),Color.WHITE)
		draw_rect(Rect2(p+Vector2(4,-10),Vector2(5,20)),Color.WHITE)
