@tool
extends EditorProperty
## Inspector property widget for editing dialogue sequences in the editor.

## Emitted when the edit button is pressed for a dialogue sequence.
signal edit_called(dialogue_sequence: HFDialogueSequence)

## The main control for editing the property.
var property_control: Button


# Initializes the property widget and sets up the edit button.
func _init() -> void:
	property_control = Button.new()
	add_child(property_control)
	add_focusable(property_control)
	property_control.text = "Edit"
	property_control.pressed.connect(_on_edit_pressed)
	label = "Edit Dialogue"
	read_only = true
	deletable = false

# Handles the edit button being pressed.
func _on_edit_pressed() -> void:
	edit_called.emit(get_edited_object())
