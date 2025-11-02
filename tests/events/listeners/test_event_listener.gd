extends GutTest

var event_listener: HFEventListener

var listener_conditional_stub1: HFEventConditional
var listener_conditional_stub2: HFEventConditional


func before_each() -> void:
	listener_conditional_stub1 = double(HFEventConditional).new(Vector2.ZERO)
	listener_conditional_stub2 = double(HFEventConditional).new(Vector2.ZERO)
	event_listener = HFEventListener.new()
	event_listener.listener_conditionals = [listener_conditional_stub1, listener_conditional_stub2]
	add_child_autoqfree(event_listener)


func test_event_listener_exists() -> void:
	assert_not_null(
		event_listener,
		"Event Listener should instantiate and not be null"
	)


func test_event_listener_can_have_listener_conditionals() -> void:
	assert_eq_deep(
		event_listener.listener_conditionals,
		[listener_conditional_stub1, listener_conditional_stub2]
	)


func test_event_listener_is_listening_to_events_manager_event_changed_signal() -> void:
	assert_true(EventsManager.event_changed.is_connected(event_listener.event_triggered))


func test_event_listener_is_listening_to_conditionals_condition_changed_signal() -> void:
	for conditional: HFEventConditional in event_listener.listener_conditionals:
		assert_true(
			conditional.condition_changed.is_connected(
				event_listener.event_triggered
			)
		)


func test_event_listener_can_add_new_conditionals_and_listen_to_their_condition_changed_signal() -> void:
	var another_listener_conditional_stub: HFEventConditional = double(HFEventConditional).new(Vector2.ZERO)
	event_listener.add_conditional(another_listener_conditional_stub)
	assert_true(event_listener.listener_conditionals.has(another_listener_conditional_stub))
	assert_true(
		another_listener_conditional_stub.condition_changed.is_connected(
			event_listener.event_triggered
		)
	)


func test_event_listener_can_remove_existing_conditionals() -> void:
	assert_true(event_listener.listener_conditionals.has(listener_conditional_stub1))
	assert_true(
		listener_conditional_stub1.condition_changed.is_connected(
			event_listener.event_triggered
		)
	)
	event_listener.remove_conditional(listener_conditional_stub1)
	assert_false(event_listener.listener_conditionals.has(listener_conditional_stub1))
	assert_false(
		listener_conditional_stub1.condition_changed.is_connected(
			event_listener.event_triggered
		)
	)


func test_event_listener_cannot_remove_conditionals_it_doesnt_have() -> void:
	var another_listener_conditional_stub: HFEventConditional = double(HFEventConditional).new(Vector2.ZERO)
	assert_false(event_listener.listener_conditionals.has(another_listener_conditional_stub))
	assert_false(
		another_listener_conditional_stub.condition_changed.is_connected(
			event_listener.event_triggered
		)
	)
	event_listener.remove_conditional(another_listener_conditional_stub)
	assert_false(event_listener.listener_conditionals.has(another_listener_conditional_stub))
	assert_false(
		another_listener_conditional_stub.condition_changed.is_connected(
			event_listener.event_triggered
		)
	)



func test_event_listener_event_triggered_is_active_remains_false_without_emiting_any_signal_if_not_all_conditionals_pass() -> void:
	watch_signals(event_listener)
	assert_false(event_listener.is_active)
	stub(listener_conditional_stub1.can_trigger_condition.bind(&"", false, {})).to_return(false)
	stub(listener_conditional_stub2.can_trigger_condition.bind(&"", false, {})).to_return(false)
	event_listener.event_triggered(&"", false, {})
	assert_signal_not_emitted(event_listener.effect_activated)
	assert_signal_not_emitted(event_listener.effect_deactivated)
	assert_false(event_listener.is_active)
	stub(listener_conditional_stub1.can_trigger_condition.bind(&"", false, {})).to_return(true)
	stub(listener_conditional_stub2.can_trigger_condition.bind(&"", false, {})).to_return(false)
	event_listener.event_triggered(&"", false, {})
	assert_signal_not_emitted(event_listener.effect_activated)
	assert_signal_not_emitted(event_listener.effect_deactivated)
	assert_false(event_listener.is_active)
	stub(listener_conditional_stub1.can_trigger_condition.bind(&"", false, {})).to_return(false)
	stub(listener_conditional_stub2.can_trigger_condition.bind(&"", false, {})).to_return(true)
	event_listener.event_triggered(&"", false, {})
	assert_signal_not_emitted(event_listener.effect_activated)
	assert_signal_not_emitted(event_listener.effect_deactivated)
	assert_false(event_listener.is_active)


func test_event_listener_event_triggered_is_active_toggles_true_and_emits_signal_if_it_was_false_and_all_conditionals_pass() -> void:
	watch_signals(event_listener)
	assert_false(event_listener.is_active)
	stub(listener_conditional_stub1.can_trigger_condition.bind(&"", false, {})).to_return(true)
	stub(listener_conditional_stub2.can_trigger_condition.bind(&"", false, {})).to_return(true)
	event_listener.event_triggered(&"", false, {})
	assert_signal_emitted(event_listener.effect_activated)
	assert_signal_not_emitted(event_listener.effect_deactivated)
	assert_true(event_listener.is_active)


func test_event_listener_event_triggered_is_active_remains_true_without_emiting_any_signal_if_it_was_true_and_all_conditionals_still_pass() -> void:
	watch_signals(event_listener)
	assert_false(event_listener.is_active)
	stub(listener_conditional_stub1.can_trigger_condition.bind(&"", false, {})).to_return(true)
	stub(listener_conditional_stub2.can_trigger_condition.bind(&"", false, {})).to_return(true)
	event_listener.event_triggered(&"", false, {})
	assert_true(event_listener.is_active)
	event_listener.event_triggered(&"", false, {})
	assert_true(event_listener.is_active)
	assert_signal_emit_count(event_listener.effect_activated, 1)


func test_event_listener_event_triggered_is_active_turns_false_emiting_a_signal_if_it_was_true_and_not_all_conditionals_pass() -> void:
	watch_signals(event_listener)
	assert_false(event_listener.is_active)
	stub(listener_conditional_stub1.can_trigger_condition.bind(&"", false, {})).to_return(true)
	stub(listener_conditional_stub2.can_trigger_condition.bind(&"", false, {})).to_return(true)
	event_listener.event_triggered(&"", false, {})
	assert_true(event_listener.is_active)
	stub(listener_conditional_stub1.can_trigger_condition.bind(&"", false, {})).to_return(false)
	stub(listener_conditional_stub2.can_trigger_condition.bind(&"", false, {})).to_return(false)
	event_listener.event_triggered(&"", false, {})
	assert_false(event_listener.is_active)
	assert_signal_emit_count(event_listener.effect_activated, 1)
	assert_signal_emit_count(event_listener.effect_deactivated, 1)


func test_event_listener_event_triggered_does_nothing_if_listener_conditionals_is_empty() -> void:
	watch_signals(event_listener)
	event_listener.listener_conditionals = []
	assert_false(event_listener.is_active)
	event_listener.event_triggered(&"", false, {})
	assert_signal_not_emitted(event_listener.effect_activated)
	assert_signal_not_emitted(event_listener.effect_deactivated)
	assert_false(event_listener.is_active)


func test_event_listener_listens_conditional_condition_changed_signal_calling_event_triggered() -> void:
	watch_signals(event_listener)
	assert_false(event_listener.is_active)
	stub(listener_conditional_stub1.can_trigger_condition.bind(&"", false, {})).to_return(true)
	stub(listener_conditional_stub2.can_trigger_condition.bind(&"", false, {})).to_return(true)
	listener_conditional_stub1.condition_changed.emit()
	assert_true(event_listener.is_active)
	assert_signal_emit_count(event_listener.effect_activated, 1)
