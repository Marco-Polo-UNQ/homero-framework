@abstract
class_name HFEventConditional
extends Resource
## Base abstract class for all event conditionals checks.
##
## Usually used in tandem with [HFEventListener]s to determine if a condition
## is triggered or not by events based on custom conditions.

## Signal used in case of needing to notify a change in state outside of the
## main [EventsManager] notifications from any class that extends from this one.
signal condition_changed()

## Dialogue editor graph position metadata, not visible in editor inspector.
@export_storage var graph_position: Vector2


func _init(p_graph_position: Vector2 = Vector2.ZERO) -> void:
	graph_position = p_graph_position


## Main status check method, should return true if the condition the conditional
## checks for is met.
## [br][br]
## [param event_tag]:  The event_tag that triggered the check.[br]
## [param value]:      The value status change of that [param event_tag].[br]
## [param events_map]: The entire events_map.[br]
@abstract
func can_trigger_condition(
	event_tag: StringName,
	value: bool,
	events_map: Dictionary[StringName, bool]
) -> bool
