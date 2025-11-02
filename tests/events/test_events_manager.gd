extends GutTest


func after_each() -> void:
	EventsManager.reset_events()


func test_events_manager_exists() -> void:
	assert_not_null(
		EventsManager,
		"Events Manager should instantiate and not be null"
	)


func test_events_manager_can_toggle_events_and_emit_an_event_changed_signal() -> void:
	watch_signals(EventsManager)
	assert_true(EventsManager.events_map.is_empty())
	assert_false(EventsManager.events_map.has(&"test"))
	EventsManager.toggle_event(&"test", true)
	assert_true(EventsManager.events_map.has(&"test"))
	assert_true(EventsManager.events_map[&"test"])
	assert_signal_emitted_with_parameters(EventsManager.event_changed, [&"test", true, EventsManager.events_map])
	EventsManager.toggle_event(&"test", false)
	assert_true(EventsManager.events_map.has(&"test"))
	assert_false(EventsManager.events_map[&"test"])
	assert_signal_emitted_with_parameters(EventsManager.event_changed, [&"test", false, EventsManager.events_map])


func test_events_manager_can_reset_all_registered_events() -> void:
	EventsManager.toggle_event(&"test", true)
	assert_true(EventsManager.events_map.has(&"test"))
	assert_true(EventsManager.events_map[&"test"])
	EventsManager.reset_events()
	assert_false(EventsManager.events_map.has(&"test"))
	assert_true(EventsManager.events_map.is_empty())
