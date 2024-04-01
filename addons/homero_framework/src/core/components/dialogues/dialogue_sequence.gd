class_name HFDialogueSequence
extends Resource

signal dialogue_started()
signal dialogue_ended()
signal step_changed(new_step: HFDialogueStep)

@export var edit_dialogue: bool = false

@export_category("Dialogue Steps")
@export var starting_steps: Array[HFDialogueStarterStep]
@export var dialogue_steps: Array[HFDialogueStep] :
	set(steps):
		dialogue_steps = steps
		dialogues_map = {}
		for step: HFDialogueStep in dialogue_steps:
			dialogues_map[step.unique_id] = step

var dialogues_map: Dictionary

var active: bool = false

var current_step: HFDialogueStep


func _init(
	p_edit_dialogue: bool = false,
	p_starting_steps: Array[HFDialogueStarterStep] = [],
	p_dialogue_steps: Array[HFDialogueStep] = []
) -> void:
	edit_dialogue = false
	starting_steps = p_starting_steps
	dialogue_steps = p_dialogue_steps
	dialogues_map = {}
	for step: HFDialogueStep in dialogue_steps:
		dialogues_map[step.unique_id] = step


func start_sequence() -> void:
	current_step = null
	dialogues_map = {}
	for step: HFDialogueStep in dialogue_steps:
		dialogues_map[step.unique_id] = step
	
	for starting_step: HFDialogueStarterStep in starting_steps:
		HFLog.d(
			"Testing step '%s' with is_enabled: '%s' with steps %s with map %s" % [
				starting_step.step_id,
				starting_step.is_enabled(),
				dialogue_steps,
				dialogues_map
			]
		)
		if starting_step.is_enabled() && dialogues_map.has(starting_step.step_id):
			HFLog.d("Dialogue sequence has a valid starting step, activating")
			_on_dialogue_started()
			_set_step_as_current(starting_step.step_id)
			return
	
	HFLog.d("Dialogue sequence found no starting step, doing nothing")
	_on_dialogue_ended()


func advance_step() -> void:
	if current_step.options.is_empty():
		current_step.advance_step()


func _set_step_as_current(next_step_id: int) -> void:
	HFLog.d("Handling advance step for step '%s'" % next_step_id)
	if current_step != null:
		if current_step.step_advanced.is_connected(_set_step_as_current):
			current_step.step_advanced.disconnect(_set_step_as_current)
	
	var next_step: HFDialogueStep = dialogues_map[next_step_id] if dialogues_map.has(next_step_id) else null
	
	if next_step == null:
		HFLog.d("Step empty or doesn't exist, ending dialogue")
		_on_dialogue_ended()
	else:
		current_step = next_step
		if !current_step.step_advanced.is_connected(_set_step_as_current):
			current_step.step_advanced.connect(_set_step_as_current)
		current_step.on_step_is_current()
		step_changed.emit(current_step)


func _on_dialogue_started() -> void:
	active = true
	dialogue_started.emit()


func _on_dialogue_ended() -> void:
	active = false
	dialogue_ended.emit()
