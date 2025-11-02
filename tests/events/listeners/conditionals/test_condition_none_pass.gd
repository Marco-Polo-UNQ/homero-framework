extends GutTest

var condition_none_pass: HFConditionNonePass


func before_each() -> void:
	condition_none_pass = HFConditionNonePass.new(
		PackedStringArray(["test1", "test2"]),
		Vector2.ZERO
	)


func test_condition_none_pass_exists() -> void:
	assert_not_null(
		condition_none_pass,
		"Event Conditional should instantiate and not be null"
	)


func test_condition_none_pass_has_event_tags() -> void:
	assert_eq_deep(
		condition_none_pass.event_tags,
		PackedStringArray(["test1", "test2"])
	)


func test_condition_none_pass_has_a_graph_position() -> void:
	assert_eq(
		condition_none_pass.graph_position,
		Vector2.ZERO
	)


func test_condition_none_pass_can_trigger_condition_returns_false_if_at_least_one_event_tag_is_true() -> void:
	assert_false(condition_none_pass.can_trigger_condition(&"", false, {"test1": true}))
	assert_false(condition_none_pass.can_trigger_condition(&"", false, {"test2": true}))
	assert_false(condition_none_pass.can_trigger_condition(&"", false, {"test1": true, "test2": false}))
	assert_false(condition_none_pass.can_trigger_condition(&"", false, {"test1": false, "test2": true}))
	assert_false(condition_none_pass.can_trigger_condition(&"", false, {"test1": true, "test2": true}))


func test_condition_none_pass_can_trigger_condition_returns_true_if_event_tags_are_not_present_or_are_false() -> void:
	assert_true(condition_none_pass.can_trigger_condition(&"", false, {}))
	assert_true(condition_none_pass.can_trigger_condition(&"", false, {"another": true}))
	assert_true(condition_none_pass.can_trigger_condition(&"", false, {"test1": false, "test2": false}))


func test_condition_none_pass_can_trigger_condition_returns_true_if_event_tags_is_empty() -> void:
	condition_none_pass.event_tags = PackedStringArray([])
	assert_true(condition_none_pass.can_trigger_condition(&"", false, {"test": true}))
