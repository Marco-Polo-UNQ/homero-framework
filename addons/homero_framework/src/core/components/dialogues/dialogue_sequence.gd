class_name HFDialogueSequence
extends Resource

signal dialogue_started()
signal dialogue_ended()
signal step_changed(new_step: HFDialogueStep)

@export var edit_dialogue: bool = false

@export_category("Dialogue Steps")
@export var starting_steps: Array[HFDialogueStarterStep]
@export var dialogue_steps: Array[HFDialogueStep] :
	set (steps):
		dialogue_steps = steps
		steps_map = {}
		for dialogue_step in dialogue_steps:
			steps_map[dialogue_step.step_id] = dialogue_step
			if !dialogue_step.step_advanced.is_connected(_on_dialogue_step_advanced):
				dialogue_step.step_advanced.connect(_on_dialogue_step_advanced)

@export_category("Dialogue Events")
@export var start_events: HFEventTriggerGroup
@export var end_events: HFEventTriggerGroup

var active: bool = false

var steps_map: Dictionary
var current_step: HFDialogueStep


func _init(
	p_starting_steps: Array[HFDialogueStarterStep] = [],
	p_dialogue_steps: Array[HFDialogueStep] = []
) -> void:
	starting_steps = p_starting_steps
	dialogue_steps = p_dialogue_steps


func start_sequence() -> void:
	current_step = null
	for starting_step: HFDialogueStarterStep in starting_steps:
		HFLog.d(
			"Testing step '%s' with is_enabled: '%s' step_exists: '%s' for step map '%s'" % [
				starting_step.step_id,
				starting_step.is_enabled(),
				step_exists(starting_step.step_id),
				steps_map
			]
		)
		if starting_step.is_enabled() && step_exists(starting_step.step_id):
			current_step = get_step(starting_step.step_id)
			break
	
	if current_step != null:
		HFLog.d("Dialogue sequence has a valid starting step, activating")
		_on_dialogue_started()
		current_step.on_step_is_current()
		step_changed.emit(current_step)
	else:
		HFLog.d("Dialogue sequence found no starting step, doing nothing")
		_on_dialogue_ended()


func step_exists(step_id: StringName) -> bool:
	return steps_map.has(step_id)


func get_step(step_id: StringName) -> HFDialogueStep:
	return steps_map[step_id] if step_exists(step_id) else null


func advance_step() -> void:
	if current_step.options.is_empty():
		current_step.advance_step()


func _on_dialogue_step_advanced(next_step_id: StringName) -> void:
	HFLog.d("Handling advance step for step_id '%s'" % next_step_id)
	if next_step_id.is_empty() || !step_exists(next_step_id):
		HFLog.d("Step empty or doesn't exist, ending dialogue")
		_on_dialogue_ended()
	else:
		HFLog.d("Step exists, loading new step")
		current_step = get_step(next_step_id)
		current_step.on_step_is_current()
		step_changed.emit(current_step)


func _on_dialogue_started() -> void:
	if start_events != null:
		start_events.trigger_events()
	active = true
	dialogue_started.emit()


func _on_dialogue_ended() -> void:
	if end_events != null:
		end_events.trigger_events()
	active = false
	dialogue_ended.emit()
