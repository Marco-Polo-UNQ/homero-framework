## Event trigger group resource for enabling and disabling events.
##
## Stores lists of event tags to enable or disable, and provides a method to trigger them.
class_name HFEventTriggerGroup
extends Resource

## List of event tags to enable.
@export var events_enable: PackedStringArray
## List of event tags to disable.
@export var events_disable: PackedStringArray

## Editor graph position metadata.
@export_storage var graph_position: Vector2


## Initializes the event trigger group with parameters.
func _init(
	p_events_enable: PackedStringArray = PackedStringArray([]),
	p_events_disable: PackedStringArray = PackedStringArray([]),
	p_graph_position: Vector2 = Vector2.ZERO
) -> void:
	events_enable = p_events_enable
	events_disable = p_events_disable
	graph_position = p_graph_position

## Triggers the enable and disable events.
func trigger_events() -> void:
	_toggle_events(events_enable, true)
	_toggle_events(events_disable, false)

## Toggles the given events on or off.
func _toggle_events(events: PackedStringArray, value: bool) -> void:
	for event in events:
		EventsManager.toggle_event(event, value)
