extends Node2D

@export var animate: bool = true
@export_range(0.0, 3.0) var speed: float = 1.0
var wind_time: float = 0.0
var materials: Array[ShaderMaterial] = []

func _ready() -> void:
	var seen: Dictionary = {}
	for visual in get_tree().get_nodes_in_group("wind_visuals"):
		var material: ShaderMaterial = visual.material
		if material != null and not seen.has(material.get_instance_id()):
			seen[material.get_instance_id()] = true
			materials.append(material)
	apply_time()

func _process(delta: float) -> void:
	if animate:
		wind_time += delta * speed
		apply_time()

func apply_time() -> void:
	for material in materials:
		material.set_shader_parameter("wind_time", wind_time)
