@tool
extends EditorProperty

signal edit_called(dialogue_sequence: HFDialogueSequence)

# The main control for editing the property.
var property_control: Button


func _init() -> void:
	property_control = Button.new()
	add_child(property_control)
	add_focusable(property_control)
	property_control.text = "Edit"
	property_control.pressed.connect(_on_edit_pressed)


func _on_edit_pressed() -> void:
	edit_called.emit(get_edited_object())
