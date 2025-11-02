extends GutTest

var event_trigger_group: HFEventTriggerGroup


func before_each() -> void:
	event_trigger_group = HFEventTriggerGroup.new(
		PackedStringArray(["test_event_enable"]),
		PackedStringArray(["test_event_disable"]),
		Vector2.ZERO
	)


func test_event_trigger_group_exists() -> void:
	assert_not_null(
		event_trigger_group,
		"Event Trigger Group should instantiate and not be null"
	)


func test_event_trigger_group_has_events_enable() -> void:
	assert_eq_deep(
		event_trigger_group.events_enable,
		PackedStringArray(["test_event_enable"])
	)


func test_event_trigger_group_has_events_disable() -> void:
	assert_eq_deep(
		event_trigger_group.events_disable,
		PackedStringArray(["test_event_disable"])
	)


func test_event_trigger_group_has_graph_position() -> void:
	assert_eq_deep(
		event_trigger_group.graph_position,
		Vector2.ZERO
	)


func test_event_trigger_group_can_trigger_all_its_events() -> void:
	assert_true(EventsManager.events_map.is_empty())
	event_trigger_group.trigger_events()
	assert_true(EventsManager.events_map.has(&"test_event_enable"))
	assert_true(EventsManager.events_map.has(&"test_event_disable"))
	assert_true(EventsManager.events_map[&"test_event_enable"])
	assert_false(EventsManager.events_map[&"test_event_disable"])
