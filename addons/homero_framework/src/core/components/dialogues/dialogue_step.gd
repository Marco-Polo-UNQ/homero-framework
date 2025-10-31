class_name HFDialogueStep
extends Resource
## Dialogue step resource for a dialogue sequence.
##
## Main building block of a dialogue sequence where it represents a single step
## with associated options, an optional linked speaker, and optional events
## that can be triggered.

## Emitted when this step advances to another step.
signal step_advanced(next_step_id: int)

@export_category("Dialogue Step Info")
## The unique id for this step.
@export var unique_id: int = -1
## The dialogue key for this step.
@export var dialogue_key: StringName
## The id of the next step to go to. If it's the same as [member unique_id]
## it can lead to an endless dialogue loop.
@export var next_step_id: int
## The speaker for this step.
@export var speaker: HFDialogueSpeaker
## The options available at this step.
@export var options: Array[HFDialogueOption] :
	set (opts):
		options = opts
		for dialogue_option: HFDialogueOption in options:
			dialogue_option.option_selected.connect(_on_option_selected)
## The events triggered at this step.
@export var dialogue_events: HFEventTriggerGroup

## Dialogue editor graph position metadata, not visible in editor inspector.
@export_storage var graph_position: Vector2

## Initializes the dialogue step with parameters.
func _init(
	p_unique_id: int = -1,
	p_dialogue_key: StringName = &"",
	p_next_step_id: int = -1,
	p_speaker: HFDialogueSpeaker = null,
	p_options: Array[HFDialogueOption] = [],
	p_dialogue_events: HFEventTriggerGroup = null,
	p_graph_position: Vector2 = Vector2.ZERO
) -> void:
	unique_id = p_unique_id
	dialogue_key = p_dialogue_key
	next_step_id = p_next_step_id
	speaker = p_speaker
	options = p_options
	dialogue_events = p_dialogue_events
	graph_position = p_graph_position

## Called when this step becomes the current step. Triggers events if any.
func on_step_is_current() -> void:
	if dialogue_events != null:
		dialogue_events.trigger_events()

## Advances to the next step.
func advance_step() -> void:
	_on_advance_step(next_step_id)

# Emits the step_advanced signal to advance to the given step id.
func _on_advance_step(to_step_id: int) -> void:
	step_advanced.emit(to_step_id)

# Handles the selection of an option and emits the step advance signal with
# the step determined by the option
func _on_option_selected(_option_id: StringName, option_next_step: int) -> void:
	_on_advance_step(option_next_step)
