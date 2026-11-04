extends Node2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Actors.process_mode = Node.PROCESS_MODE_PAUSABLE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		get_tree().paused = not get_tree().paused
		get_viewport().set_input_as_handled()
