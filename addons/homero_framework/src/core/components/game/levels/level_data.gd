class_name HFLevelData
extends Resource

@export var level_id: String
@export_file("*.tscn") var _level_instance_path: String

var level_instance_scene: PackedScene :
	set (_value):
		return
	get:
		if !_level_instance_path.is_empty() && ResourceLoader.exists(_level_instance_path):
			return ResourceLoader.load(_level_instance_path, "PackedScene")
		return null


func _init(
	level_id_p: String = "",
	level_instance_path_p: String = ""
) -> void:
	level_id = level_id_p
	_level_instance_path = level_instance_path_p

