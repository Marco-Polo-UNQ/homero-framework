class_name HFEventTriggerGroup
extends Resource

@export var events_enable: PackedStringArray
@export var events_disable: PackedStringArray

@export_category("Editor Metadata (ignore)")
@export var graph_position: Vector2


func _init(
	p_events_enable: PackedStringArray = PackedStringArray([]),
	p_events_disable: PackedStringArray = PackedStringArray([])
) -> void:
	events_enable = p_events_enable
	events_disable = p_events_disable


func trigger_events() -> void:
	_toggle_events(events_enable, true)
	_toggle_events(events_disable, false)


func _toggle_events(events: PackedStringArray, value: bool) -> void:
	for event in events:
		EventsManager.toggle_event(event, value)

