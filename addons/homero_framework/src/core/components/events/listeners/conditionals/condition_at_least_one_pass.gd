class_name HFConditionAtLeastOnePass
extends HFEventConditional

@export var event_tags: PackedStringArray


func can_trigger_condition(
	event_tag: String,
	value: bool,
	events_map: Dictionary
) -> bool:
	var all_check: bool = false
	for tag in event_tags:
		all_check = all_check || (events_map.has(tag) && events_map[tag])
	return all_check


func get_resource_class() -> String:
	return "HFConditionAtLeastOnePass"
