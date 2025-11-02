extends EditorInspectorPlugin
## Inspector plugin for editing dialogue sequences in the editor.

## Emitted when the edit button is pressed for a dialogue sequence.
signal edit_called(dialogue_sequence: HFDialogueSpeaker)

## The script for the custom property editor widget.
const WIDGET_SCRIPT: Script = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_editor_inspector_widget.gd"
)

# Determines if this plugin can handle the given object.
func _can_handle(object) -> bool:
	return object is HFDialogueSequence


# Parses a property and adds a custom editor if needed.
func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	if name == "_edit_dialogue":
		var widget: EditorProperty = WIDGET_SCRIPT.new()
		add_property_editor(name, widget)
		widget.edit_called.connect(_on_edit_called)
	return true

# Handles the edit_called signal from the widget.
func _on_edit_called(dialogue_sequence: HFDialogueSequence) -> void:
	edit_called.emit(dialogue_sequence)
