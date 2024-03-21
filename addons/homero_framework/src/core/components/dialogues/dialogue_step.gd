class_name HFDialogueStep
extends Resource

signal step_advanced(next_step_id: StringName)

@export_category("Dialogue Step Info")
@export var step_id: StringName
@export var next_step_id: StringName
@export var speaker: HFDialogueSpeaker
@export var options: Array[HFDialogueOption] :
	set (opts):
		options = opts
		for dialogue_option in options:
			dialogue_option.option_selected.connect(
				func (option_id: StringName, next_step_id: StringName) -> void:
					_on_advance_step(next_step_id)
			)
@export var dialogue_events: HFEventTriggerGroup


func _init(
	p_step_id: StringName = "",
	p_next_step_id: StringName = "",
	p_options: Array[HFDialogueOption] = []
) -> void:
	step_id = p_step_id
	next_step_id = p_next_step_id
	options = p_options


func on_step_is_current() -> void:
	if dialogue_events != null:
		dialogue_events.trigger_events()


func advance_step() -> void:
	_on_advance_step(next_step_id)


func _on_advance_step(to_step_id: StringName) -> void:
	step_advanced.emit(to_step_id)
