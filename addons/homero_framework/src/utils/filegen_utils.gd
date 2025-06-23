class_name HFFilegenUtils
extends Node


static func check_class_file_exists_or_create(
	class_p: String,
	file_path: String,
	content: String = ""
) -> void:
	if !ClassDB.class_exists(class_p):
		if !FileAccess.file_exists(file_path):
			var file = FileAccess.open(file_path, FileAccess.WRITE)
			file.store_line(content)
