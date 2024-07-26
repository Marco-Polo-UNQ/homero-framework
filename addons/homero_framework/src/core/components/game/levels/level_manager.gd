class_name HFLevelManager
extends Node
## Generic level manager implementation

signal change_level_called(level_id: StringName)

@export var levels: Array[HFLevelData]

var levels_map: Dictionary = {}
var current_level_id: StringName
var current_level: HFLevelInstance


func _ready() -> void:
	levels_map = {}
	for level in levels:
		levels_map[level.level_id] = level


func change_level(level_id: StringName) -> void:
	if !levels_map.has(level_id):
		HFLog.e("Level with id '%s' doesn't exist, aborting level change!" % level_id)
		return
	
	if levels_map[level_id].level_instance_scene == null:
		HFLog.e("Level with id '%s' has a null or wrong instance scene!" % level_id)
		return
	
	change_level_called.emit(level_id)
	call_deferred("_change_level", level_id)


func _change_level(level_id: StringName) -> void:
	if current_level != null:
		if current_level.is_inside_tree():
			current_level.get_parent().remove_child(current_level)
		current_level.queue_free()
		current_level = null
	
	current_level = levels_map[level_id].level_instance_scene.instantiate()
	current_level.change_level.connect(change_level)
	add_child(current_level)
	
	current_level_id = level_id
