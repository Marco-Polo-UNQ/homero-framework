class_name HFLevelInstance
extends Node

signal change_level(level_id)


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func on_world_change_level(level_id: String) -> void:
	change_level.emit(level_id)
