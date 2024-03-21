extends EditorInspectorPlugin

signal edit_called(dialogue_sequence: HFDialogueSequence)

var widget_script: Script = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_editor_inspector_widget.gd"
)


func _can_handle(object) -> bool:
	return object is HFDialogueSequence


func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	if name == "edit_dialogue":
		var widget: EditorProperty = widget_script.new()
		add_property_editor(name, widget)
		widget.edit_called.connect(_on_edit_called)
		return true
	else:
		return false


func _on_edit_called(dialogue_sequence: HFDialogueSequence) -> void:
	edit_called.emit(dialogue_sequence)
