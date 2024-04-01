class_name HFEventConditional
extends Resource

signal condition_changed

@export_category("Editor Metadata (ignore)")
@export var graph_position: Vector2


func can_trigger_condition(
	event_tag: String,
	value: bool,
	events_map: Dictionary
) -> bool:
	return true
