@tool
extends EditorPlugin

const version_checker_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/version/version_checker.tscn"
)

const dialogue_editor_inspector_plugin_script: Script = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_editor_inspector_plugin.gd"
)
const dialogue_editor_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_graph_editor.tscn"
)

var version_checker: Control
var dialogue_editor_inspector_plugin: EditorInspectorPlugin
var dialogue_editor: Control
var dialogue_editor_button: Button


# Initialization of the plugin.
func _enter_tree() -> void:
	version_checker = version_checker_scene.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, version_checker)
	
	dialogue_editor_inspector_plugin = dialogue_editor_inspector_plugin_script.new()
	dialogue_editor_inspector_plugin.edit_called.connect(_on_dialogue_editor_inspector_plugin_edit_called)
	add_inspector_plugin(dialogue_editor_inspector_plugin)
	
	var plugin_version: String = get_plugin_version()
	version_checker.check_version(plugin_version)
	
	HFLog.d("Loaded successfully, current version %s" % plugin_version)


# Clean-up of the plugin.
func _exit_tree() -> void:
	if version_checker != null:
		remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, version_checker)
		version_checker.queue_free()
		version_checker = null
	
	if dialogue_editor_inspector_plugin != null:
		remove_inspector_plugin(dialogue_editor_inspector_plugin)
		dialogue_editor_inspector_plugin = null
	
	if dialogue_editor != null:
		remove_control_from_bottom_panel(dialogue_editor)
		dialogue_editor.queue_free()
		dialogue_editor = null
	
	HFLog.w("Unloaded successfully")



func _on_dialogue_editor_inspector_plugin_edit_called(dialogue_sequence: HFDialogueSequence) -> void:
	print("Edit dialogue sequence called for %s" % dialogue_sequence)
	if dialogue_editor == null:
		dialogue_editor = dialogue_editor_scene.instantiate()
		dialogue_editor_button = add_control_to_bottom_panel(dialogue_editor, "Dialogue Editor")
	dialogue_editor.setup(dialogue_sequence)
	dialogue_editor_button.set_pressed(true)
