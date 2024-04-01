@tool
extends Control

signal new_starting_step_requested()
signal new_dialogue_step_requested()
signal new_dialogue_option_requested()
signal new_dialogue_event_requested()
signal new_dialogue_speaker_requested()
signal new_dialogue_conditional_requested(conditional: HFEventConditional)

@onready var conditionals_buttons_container: Node = %ConditionalsButtonsContainer
@onready var conditionals_list_dropdown: Control = %ConditionalsListDropdown
@onready var dialogue_conditional_button: Control = %DialogueConditionalButton


func _ready() -> void:
	_toggle_popup(false)


func setup(point: Vector2) -> void:
	position = point
	_toggle_popup(true)
	
	for button: Node in conditionals_buttons_container.get_children():
		conditionals_buttons_container.remove_child(button)
		button.queue_free()
	
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	for class_dict: Dictionary in global_class_list:
		if class_dict.base == "HFEventConditional" && class_dict.class != "HFEventConditional":
			var new_button: Button = Button.new()
			conditionals_buttons_container.add_child(new_button)
			new_button.text = class_dict.class
			new_button.pressed.connect(_on_dialogue_conditional_button_pressed.bind(class_dict.path))


func _on_starting_step_button_pressed() -> void:
	new_starting_step_requested.emit()
	_toggle_popup(false)


func _on_dialogue_step_button_pressed() -> void:
	new_dialogue_step_requested.emit()
	_toggle_popup(false)


func _on_dialogue_option_button_pressed() -> void:
	new_dialogue_option_requested.emit()
	_toggle_popup(false)


func _on_dialogue_event_button_pressed() -> void:
	new_dialogue_event_requested.emit()
	_toggle_popup(false)


func _on_dialogue_speaker_button_pressed() -> void:
	new_dialogue_speaker_requested.emit()
	_toggle_popup(false)


func _on_dialogue_conditional_button_pressed(conditional_path: String) -> void:
	var new_condition: HFEventConditional = load(conditional_path).new()
	new_dialogue_conditional_requested.emit(new_condition)
	_toggle_popup(false)


func _on_dialogue_conditional_button_mouse_entered() -> void:
	conditionals_list_dropdown.show()


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton &&
		event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT] &&
		event.is_pressed() &&
		(
			!get_global_rect().has_point(event.global_position) &&
			(
				!conditionals_list_dropdown.visible ||
				!conditionals_list_dropdown.get_global_rect().has_point(event.global_position)
			)
		)
	):
		_toggle_popup(false)
	elif (
		event is InputEventMouseMotion &&
		conditionals_list_dropdown.visible &&
		!conditionals_list_dropdown.get_global_rect().has_point(event.global_position) &&
		!dialogue_conditional_button.get_global_rect().has_point(event.global_position)
	):
		conditionals_list_dropdown.hide()


func _toggle_popup(status: bool) -> void:
	visible = status
	set_process_input(status)
	if !status:
		conditionals_list_dropdown.hide()
