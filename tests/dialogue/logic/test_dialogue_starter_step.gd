extends GutTest

var dialogue_starter_step: HFDialogueStarterStep

var event_conditional_stub: HFEventConditional


func before_each() -> void:
	event_conditional_stub = double(HFEventConditional).new()
	
	dialogue_starter_step = HFDialogueStarterStep.new(
		0,
		[event_conditional_stub] as Array[HFEventConditional],
		Vector2.ZERO
	)


func test_dialogue_starter_step_exists() -> void:
	assert_not_null(
		dialogue_starter_step,
		"Dialogue Starter Step should instantiate and not be null"
	)


func test_dialogue_starter_step_has_a_step_id() -> void:
	assert_eq(
		dialogue_starter_step.step_id,
		0
	)


func test_dialogue_starter_step_has_enable_conditions() -> void:
	assert_eq_deep(
		dialogue_starter_step.enable_conditions,
		[event_conditional_stub]
	)


func test_dialogue_starter_step_has_a_graph_position() -> void:
	assert_eq(
		dialogue_starter_step.graph_position,
		Vector2.ZERO
	)


func test_dialogue_starter_step_is_enabled_returns_true_if_enable_conditions_is_empty() -> void:
	dialogue_starter_step.enable_conditions = []
	assert_true(dialogue_starter_step.is_enabled())


func test_dialogue_starter_step_is_enabled_returns_true_if_all_enable_conditions_are_enabled() -> void:
	stub(event_conditional_stub.can_trigger_condition.bind(&"", false, EventsManager.events_map)).to_return(true)
	assert_true(dialogue_starter_step.is_enabled())
	
	var another_condition_stub: HFEventConditional = double(HFEventConditional).new()
	stub(another_condition_stub.can_trigger_condition.bind(&"", false, EventsManager.events_map)).to_return(true)
	dialogue_starter_step.enable_conditions.push_back(another_condition_stub)
	assert_true(dialogue_starter_step.is_enabled())


func test_dialogue_starter_step_is_enabled_returns_false_if_any_enable_conditions_are_not_enabled() -> void:
	stub(event_conditional_stub.can_trigger_condition.bind(&"", false, EventsManager.events_map)).to_return(true)
	assert_true(dialogue_starter_step.is_enabled())
	
	var another_condition_stub: HFEventConditional = double(HFEventConditional).new()
	stub(another_condition_stub.can_trigger_condition.bind(&"", false, EventsManager.events_map)).to_return(false)
	dialogue_starter_step.enable_conditions.push_back(another_condition_stub)
	assert_false(dialogue_starter_step.is_enabled())
