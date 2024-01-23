class_name HFOrthographicCamera
extends Node3D

@export var follow_node: Node3D :
	set (value):
		follow_node = value
		set_physics_process(follow_node != null)

@export var follow_strength: float


func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(follow_node.global_position, delta * follow_strength)


var dragging: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.is_pressed()
	elif event is InputEventMouseMotion && dragging:
		rotate_y(event.relative.x / get_viewport().size.x)
