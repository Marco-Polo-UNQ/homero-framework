extends Node3D

@export var enabled: bool : set = set_enabled


func set_enabled(value: bool) -> void:
	enabled = value
	set_physics_process(enabled)


func _ready() -> void:
	set_physics_process(enabled)


func _physics_process(delta: float) -> void:
	var movement: Vector2 = Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	var vel: Vector2 = movement * 2.0 * delta
	position.x += vel.x
	position.z += vel.y
