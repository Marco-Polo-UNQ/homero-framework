class_name HFDialogueStep
extends Resource

signal step_advanced(next_step_id: int)

@export_category("Dialogue Step Info")
@export var unique_id: int
@export var dialogue_key: StringName
@export var next_step_id: int
@export var speaker: HFDialogueSpeaker
@export var options: Array[HFDialogueOption] :
	set (opts):
		options = opts
		for dialogue_option: HFDialogueOption in options:
			dialogue_option.option_selected.connect(
				func (option_id: StringName, option_next_step: int) -> void:
					_on_advance_step(option_next_step)
			)
@export var dialogue_events: HFEventTriggerGroup

@export_category("Editor Metadata (ignore)")
@export var graph_position: Vector2


func _init(
	p_unique_id: int = 0,
	p_dialogue_key: StringName = "",
	p_next_step_id: int = 0,
	p_options: Array[HFDialogueOption] = []
) -> void:
	unique_id = p_unique_id
	dialogue_key = p_dialogue_key
	next_step_id = p_next_step_id
	options = p_options


func on_step_is_current() -> void:
	if dialogue_events != null:
		dialogue_events.trigger_events()


func advance_step() -> void:
	_on_advance_step(next_step_id)


func _on_advance_step(to_step_id: int) -> void:
	step_advanced.emit(to_step_id)
