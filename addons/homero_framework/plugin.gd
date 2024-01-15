@tool
extends EditorPlugin

const version_checker_path: PackedScene = preload("res://addons/homero_framework/src/core/editor/version_checker.tscn")

var version_checker: Control


# Initialization of the plugin.
func _enter_tree() -> void:
	version_checker = version_checker_path.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, version_checker)
	
	var plugin_version: String = get_plugin_version()
	version_checker.check_version(plugin_version)
	
	HFLog.d("Loaded successfully, current version %s" % plugin_version)


# Clean-up of the plugin.
func _exit_tree() -> void:
	if version_checker != null:
		remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, version_checker)
		version_checker.queue_free()
		version_checker = null
	
	HFLog.w("Unloaded successfully")
