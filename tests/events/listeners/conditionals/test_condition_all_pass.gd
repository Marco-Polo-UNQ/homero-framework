extends GutTest

var condition_all_pass: HFConditionAllPass


func before_each() -> void:
	condition_all_pass = HFConditionAllPass.new(
		PackedStringArray(["test1", "test2"]),
		Vector2.ZERO
	)


func test_condition_all_pass_exists() -> void:
	assert_not_null(
		condition_all_pass,
		"Event Conditional should instantiate and not be null"
	)


func test_condition_all_pass_has_event_tags() -> void:
	assert_eq_deep(
		condition_all_pass.event_tags,
		PackedStringArray(["test1", "test2"])
	)


func test_condition_all_pass_has_a_graph_position() -> void:
	assert_eq(
		condition_all_pass.graph_position,
		Vector2.ZERO
	)


func test_condition_all_pass_can_trigger_condition_returns_true_if_all_event_tags_are_true() -> void:
	assert_true(condition_all_pass.can_trigger_condition(&"", false, {"test1": true, "test2": true}))


func test_condition_all_pass_can_trigger_condition_returns_false_if_only_one_event_tag_is_true() -> void:
	assert_false(condition_all_pass.can_trigger_condition(&"", false, {"test1": true}))
	assert_false(condition_all_pass.can_trigger_condition(&"", false, {"test2": true}))
	assert_false(condition_all_pass.can_trigger_condition(&"", false, {"test1": true, "test2": false}))
	assert_false(condition_all_pass.can_trigger_condition(&"", false, {"test1": false, "test2": true}))


func test_condition_all_pass_can_trigger_condition_returns_false_if_event_tags_are_not_present_or_are_false() -> void:
	assert_false(condition_all_pass.can_trigger_condition(&"", false, {}))
	assert_false(condition_all_pass.can_trigger_condition(&"", false, {"another": true}))
	assert_false(condition_all_pass.can_trigger_condition(&"", false, {"test1": false, "test2": false}))


func test_condition_all_pass_can_trigger_condition_returns_true_if_event_tags_is_empty() -> void:
	condition_all_pass.event_tags = PackedStringArray([])
	assert_true(condition_all_pass.can_trigger_condition(&"", false, {"test": true}))
