class_name HFDialogueOption
extends Resource
## Dialogue option resource for branching dialogue steps.
##
## Represents a selectable option in a dialogue step, with conditions and events.

## Emitted when this option is selected.[br]
## [param dialogue_key] The key of the dialogue.[br]
## [param next_step_id] The id of the next step to go to.
signal option_selected(dialogue_key: StringName, next_step_id: int)

@export_category("Dialogue Option Info")
## The dialogue key for this dialogue option.
@export var dialogue_key: StringName
## The internal id of the next [HFDialogueStep] to go to if this
## option is selected.
@export var next_step_id: int
## Conditions that must be met for this option to be enabled.
@export var enable_conditions: Array[HFEventConditional]

@export_category("Dialogue Events")
## Events triggered when this option is selected.
@export var option_events: HFEventTriggerGroup

## Dialogue Editor graph position metadata, not visible in the inspector.
@export_storage var graph_position: Vector2

# Resource constructor.
func _init(
	p_dialogue_key: StringName = "",
	p_next_step_id: int = 0,
	p_enable_conditions: Array[HFEventConditional] = [],
	p_option_events: HFEventTriggerGroup = null,
	p_graph_position: Vector2 = Vector2.ZERO
) -> void:
	dialogue_key = p_dialogue_key
	next_step_id = p_next_step_id
	enable_conditions = p_enable_conditions
	option_events = p_option_events
	graph_position = p_graph_position

## Returns true if all [member enable_conditions] are met.
func is_enabled() -> bool:
	var is_enabled: bool = true
	for condition in enable_conditions:
		is_enabled = is_enabled && condition.can_trigger_condition(
			&"", false, EventsManager.events_map
		)
	return is_enabled

## Selects this option, triggers events, and emits the [signal option_selected] signal.
func select_option() -> void:
	HFLog.d("Option selected %s with next step %s" % [dialogue_key, next_step_id])
	if option_events != null:
		option_events.trigger_events()
	option_selected.emit(dialogue_key, next_step_id)
