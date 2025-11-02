class_name HFDialogueStarterStep
extends Resource
## Dialogue starter step resource for dialogue sequences.
##
## Represents a starting condition in a dialogue sequence, linked to a
## [HFDialogueStep] with optional conditional events for activation.

## The id of the [HFDialogueStep] to serve as the start of the dialogue sequence
## in a given sequence.
@export var step_id: int
## Conditions that must be met for this starting sequence to be enabled.
@export var enable_conditions: Array[HFEventConditional]

## Dialogue editor graph position metadata, not visible in editor inspector.
@export_storage var graph_position: Vector2

## Initializes the dialogue starter step with parameters.
func _init(
	p_step_id: int = 0,
	p_enable_conditions: Array[HFEventConditional] = [],
	p_graph_position: Vector2 = Vector2.ZERO
) -> void:
	step_id = p_step_id
	enable_conditions = p_enable_conditions
	graph_position = p_graph_position

## Returns true if all [method HFEventConditional.can_trigger_condition] in
## [member enable_conditions] return true.
func is_enabled() -> bool:
	var is_enabled: bool = true
	for condition in enable_conditions:
		is_enabled = is_enabled && condition.can_trigger_condition(
			&"", false, EventsManager.events_map
		)
	return is_enabled
