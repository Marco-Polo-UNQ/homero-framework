extends Node2D

@export var enabled: bool : set = set_enabled


func set_enabled(value: bool) -> void:
	enabled = value
	set_physics_process(enabled)


func _ready() -> void:
	set_physics_process(enabled)


func _physics_process(delta: float) -> void:
	var movement: Vector2 = Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	position += movement * 200.0 * delta
