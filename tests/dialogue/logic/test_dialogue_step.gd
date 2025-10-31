extends GutTest

var dialogue_step: HFDialogueStep

var dialogue_speaker_stub: HFDialogueSpeaker
var dialogue_option_stub: HFDialogueOption
var dialogue_events_stub: HFEventTriggerGroup


func before_each() -> void:
	dialogue_speaker_stub = double(HFDialogueSpeaker).new(null, Vector2.ZERO)
	dialogue_option_stub = double(HFDialogueOption).new(
		&"",
		0,
		[] as Array[HFEventConditional],
		null,
		Vector2.ZERO
	)
	dialogue_events_stub = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)
	
	dialogue_step = HFDialogueStep.new(
		0,
		&"test",
		1,
		dialogue_speaker_stub,
		[dialogue_option_stub] as Array[HFDialogueOption],
		dialogue_events_stub,
		Vector2.ZERO
	)


func test_dialogue_step_exists() -> void:
	assert_not_null(
		dialogue_step,
		"Dialogue Starter Step should instantiate and not be null"
	)


func test_dialogue_step_has_a_unique_id() -> void:
	assert_eq(
		dialogue_step.unique_id,
		0
	)


func test_dialogue_step_has_a_dialogue_key() -> void:
	assert_eq(
		dialogue_step.dialogue_key,
		&"test"
	)


func test_dialogue_step_has_a_next_step_id() -> void:
	assert_eq(
		dialogue_step.next_step_id,
		1
	)


func test_dialogue_step_has_a_speaker() -> void:
	assert_eq(
		dialogue_step.speaker,
		dialogue_speaker_stub
	)


func test_dialogue_step_has_dialogue_options() -> void:
	assert_eq_deep(
		dialogue_step.options,
		[dialogue_option_stub]
	)
	assert_true(dialogue_option_stub.option_selected.is_connected(dialogue_step._on_option_selected))


func test_dialogue_step_has_dialogue_events() -> void:
	assert_eq(
		dialogue_step.dialogue_events,
		dialogue_events_stub
	)


func test_dialogue_step_has_a_graph_position() -> void:
	assert_eq(
		dialogue_step.graph_position,
		Vector2.ZERO
	)


func test_dialogue_step_on_step_is_current_calls_trigger_events_on_dialogue_events() -> void:
	dialogue_step.on_step_is_current()
	assert_called_count(dialogue_events_stub.trigger_events, 1)


func test_dialogue_step_advance_step_emits_the_step_advanced_signal() -> void:
	watch_signals(dialogue_step)
	dialogue_step.advance_step()
	assert_signal_emitted_with_parameters(dialogue_step.step_advanced, [1])


func test_dialogue_step_emits_step_advanced_signal_on_option_selected() -> void:
	watch_signals(dialogue_step)
	dialogue_option_stub.option_selected.emit(&"option", 2)
	assert_signal_emitted_with_parameters(dialogue_step.step_advanced, [2])
