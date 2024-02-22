class_name HFEventConditional
extends Resource

signal condition_changed


func can_trigger_condition(
	event_tag: String,
	value: bool,
	events_map: Dictionary
) -> bool:
	return true
