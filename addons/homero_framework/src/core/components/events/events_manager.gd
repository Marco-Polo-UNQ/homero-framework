## Events manager for toggling and resetting events in the framework.
##
## Stores a map of event tags and their states, and emits signals when events change.
extends Node

## Emitted when an event changes.
signal event_changed(tag: String, value: bool, events_map: Dictionary)

## Dictionary mapping event tags to their states.
var events_map: Dictionary[StringName, bool] = {}

## Toggles the state of an event and emits the event_changed signal.
func toggle_event(tag: StringName, value: bool) -> void:
	HFLog.d("Event toggled %s %s" % [tag, value])
	events_map[tag] = value
	event_changed.emit(tag, value, events_map)

## Resets all events to their default state.
func reset_events() -> void:
	events_map.clear()
