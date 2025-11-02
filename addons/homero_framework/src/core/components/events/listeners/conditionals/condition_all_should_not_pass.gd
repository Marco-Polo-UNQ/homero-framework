class_name HFConditionAllShouldNotPass
extends HFEventConditional
## Condition that checks that all of the specified event tags have not passed (are false).

## Event Tags to check against.
@export var event_tags: PackedStringArray


func _init(
	p_event_tags: PackedStringArray = PackedStringArray([]),
	p_graph_position: Vector2 = Vector2.ZERO
) -> void:
	super(p_graph_position)
	event_tags = p_event_tags


func can_trigger_condition(
	event_tag: StringName,
	value: bool,
	events_map: Dictionary[StringName, bool]
) -> bool:
	var all_check: bool = true
	for tag in event_tags:
		all_check = all_check && events_map.has(tag) && events_map[tag]
	return !all_check
