@tool
extends EditorPlugin

const VERSION_CHECKER_SCENE: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/version/version_checker.tscn"
)
const DIALOGUE_EDITOR_INSPECTOR_PLUGIN_SCRIPT: Script = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_editor_inspector_plugin.gd"
)
const DIALOGUE_EDITOR_SCENE: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_graph_editor.tscn"
)
const EVENTS_MANAGER_PATH: String = \
	"res://addons/homero_framework/src/core/components/events/events_manager.gd"
const EVENTS_MANAGER_SINGLETON_NAME: String = "EventsManager"
const SCREEN_CONSTANTS_CLASS_NAME: String = "HFScreenConstants"
const SCREEN_CONSTANTS_DEFAULT_PATH: String = "res://screens_constants.gd"

var version_checker: Control
var dialogue_editor_inspector_plugin: EditorInspectorPlugin
var dialogue_editor: Control
var dialogue_editor_button: Button


# Initialization of the plugin.
func _enter_tree() -> void:
	HFLog.d("Initializing plugin")
	
	# On the editor, checks if the [HFScreenConstants] utility class
	# used by the screen manager system exists somewhere, and if not,
	# creates a new file in the aforementioned path and placeholder code.
	_check_class_file_exists_or_create(
		SCREEN_CONSTANTS_CLASS_NAME,
		SCREEN_CONSTANTS_DEFAULT_PATH,
		_get_default_screen_constants_content()
	)
	
	version_checker = VERSION_CHECKER_SCENE.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, version_checker)
	
	dialogue_editor_inspector_plugin = DIALOGUE_EDITOR_INSPECTOR_PLUGIN_SCRIPT.new()
	dialogue_editor_inspector_plugin.edit_called.connect(_on_dialogue_editor_inspector_plugin_edit_called)
	add_inspector_plugin(dialogue_editor_inspector_plugin)
	
	add_autoload_singleton(EVENTS_MANAGER_SINGLETON_NAME, EVENTS_MANAGER_PATH)
	
	var plugin_version: String = get_plugin_version()
	version_checker.check_version(plugin_version)
	
	HFLog.d("Loaded successfully, current version %s" % plugin_version)


# Clean-up of the plugin.
func _exit_tree() -> void:
	HFLog.d("Unloading plugin")
	
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
	
	remove_autoload_singleton(EVENTS_MANAGER_SINGLETON_NAME)
	
	HFLog.d("Unloaded successfully")


func _on_dialogue_editor_inspector_plugin_edit_called(dialogue_sequence: HFDialogueSequence) -> void:
	HFLog.d("Edit dialogue sequence called for %s" % dialogue_sequence)
	if dialogue_editor == null:
		dialogue_editor = DIALOGUE_EDITOR_SCENE.instantiate()
		dialogue_editor_button = add_control_to_bottom_panel(
			dialogue_editor,
			"Dialogue Editor"
		)
	dialogue_editor.setup(dialogue_sequence)
	dialogue_editor_button.set_pressed(true)


# Utils function that checks the existence of a user-defined class, and if it doesn't exist
# it creates a new file in a path with a determined content.
func _check_class_file_exists_or_create(
	class_p: String,
	file_path: String,
	content: String = _get_default_screen_constants_content()
) -> void:
	var class_found: bool = false
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	for class_data: Dictionary in global_class_list:
		if class_data.class == class_p:
			class_found = true
			break
	if !class_found:
		HFLog.d(
			"Class %s doesn't exist, attempting to create a placeholder at %s" %
			[class_p, file_path]
		)
		if !FileAccess.file_exists(file_path):
			var file = FileAccess.open(file_path, FileAccess.WRITE)
			file.store_line(content)
			HFLog.d("File %s created!" % file_path)
		else:
			HFLog.w(
				"File %s already exists, can't create placeholder for class %s" %
				[file_path, class_p]
			)
	else:
		HFLog.d("Class %s exists!" % class_p)


# Returns the default content of the script containing the HFScreenConstants data
func _get_default_screen_constants_content() -> String:
	return "class_name HFScreenConstants\n" +\
				"extends Object\n\n" +\
				"## Custom screen constants class to be used with [HFScreenManager] and [HFScreenLoader]\n\n" +\
				"## Custom enum used for static references to [HFScreenLoader], to be used with [member HFScreenLoader.screen_id].\n" +\
				"## Usage:\n" +\
				"## [codeblock]\n" +\
				"## enum SCREENS {\n" +\
				"##     LOADING,\n" +\
				"##     SCREEN1,\n" +\
				"##     SCREEN2\n" +\
				"##     }\n" +\
				"## [/codeblock]\n" +\
				"enum SCREENS {\n" +\
				"	DEFAULT\n" +\
				"}"
