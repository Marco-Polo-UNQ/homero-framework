extends GutTest

var dialogue_option: HFDialogueOption

var event_conditional_stub: HFEventConditional
var event_trigger_group_stub: HFEventTriggerGroup


func before_each() -> void:
	event_conditional_stub = double(HFEventConditional).new()
	event_trigger_group_stub = double(HFEventTriggerGroup).new(PackedStringArray([]), PackedStringArray([]))
	
	dialogue_option = HFDialogueOption.new(
		"test",
		0,
		[event_conditional_stub],
		event_trigger_group_stub,
		Vector2.ZERO
	)
	autofree(dialogue_option)


func test_dialogue_option_exists() -> void:
	assert_not_null(
		dialogue_option,
		"Dialogue Option should instantiate and not be null"
	)


func test_dialogue_option_has_a_dialogue_key() -> void:
	assert_eq(
		dialogue_option.dialogue_key,
		"test"
	)


func test_dialogue_option_has_a_next_step_id() -> void:
	assert_eq(
		dialogue_option.next_step_id,
		0
	)


func test_dialogue_option_has_enable_conditions() -> void:
	assert_eq_deep(
		dialogue_option.enable_conditions,
		[event_conditional_stub]
	)


func test_dialogue_option_has_option_events() -> void:
	assert_eq(
		dialogue_option.option_events,
		event_trigger_group_stub
	)


func test_dialogue_option_has_graph_position() -> void:
	assert_eq(
		dialogue_option.graph_position,
		Vector2.ZERO
	)


func test_dialogue_option_is_enabled_returns_true_if_enable_conditions_is_empty() -> void:
	dialogue_option.enable_conditions = []
	assert_true(dialogue_option.is_enabled())


func test_dialogue_option_is_enabled_returns_true_if_all_enable_conditions_are_enabled() -> void:
	stub(event_conditional_stub.can_trigger_condition.bind("", true, EventsManager.events_map)).to_return(true)
	assert_true(dialogue_option.is_enabled())
	
	var another_condition_stub: HFEventConditional = double(HFEventConditional).new()
	stub(another_condition_stub.can_trigger_condition.bind("", true, EventsManager.events_map)).to_return(true)
	dialogue_option.enable_conditions.push_back(another_condition_stub)
	assert_true(dialogue_option.is_enabled())


func test_dialogue_option_is_enabled_returns_false_if_any_enable_conditions_are_not_enabled() -> void:
	stub(event_conditional_stub.can_trigger_condition.bind("", true, EventsManager.events_map)).to_return(true)
	assert_true(dialogue_option.is_enabled())
	
	var another_condition_stub: HFEventConditional = double(HFEventConditional).new()
	stub(another_condition_stub.can_trigger_condition.bind("", true, EventsManager.events_map)).to_return(false)
	dialogue_option.enable_conditions.push_back(another_condition_stub)
	assert_false(dialogue_option.is_enabled())


func test_dialogue_option_select_option_emits_option_selected_signal() -> void:
	watch_signals(dialogue_option)
	dialogue_option.select_option()
	assert_signal_emitted_with_parameters(dialogue_option.option_selected, ["test", 0])


func test_dialogue_option_triggers_options_events_on_select_option() -> void:
	watch_signals(dialogue_option)
	dialogue_option.select_option()
	assert_signal_emitted_with_parameters(dialogue_option.option_selected, ["test", 0])
	assert_called_count(event_trigger_group_stub.trigger_events, 1)
