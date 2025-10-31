extends GutTest

var dialogue_sequence: HFDialogueSequence

var dialogue_starter_step_stub: HFDialogueStarterStep
var dialogue_step_stub: HFDialogueStep


func before_each() -> void:
	dialogue_starter_step_stub = double(HFDialogueStarterStep).new(
		0,
		[] as Array[HFEventConditional]
	)
	
	dialogue_step_stub = double(HFDialogueStep).new(
		0,
		&"",
		1,
		[] as Array[HFDialogueOption]
	)
	
	dialogue_sequence = HFDialogueSequence.new(
		[dialogue_starter_step_stub],
		[dialogue_step_stub]
	)
	
	assert_false(dialogue_sequence.active)
	stub(dialogue_starter_step_stub.is_enabled).to_return(true)
	stub(dialogue_step_stub.advance_step).to_call(func(): dialogue_step_stub.step_advanced.emit(dialogue_step_stub.next_step_id))


func test_dialogue_sequence_exists() -> void:
	assert_not_null(
		dialogue_sequence,
		"Dialogue Sequence should instantiate and not be null"
	)


func test_dialogue_sequence_has_starting_steps() -> void:
	assert_eq_deep(
		dialogue_sequence.starting_steps,
		[dialogue_starter_step_stub]
	)


func test_dialogue_sequence_has_dialogue_steps() -> void:
	assert_eq_deep(
		dialogue_sequence.dialogue_steps,
		[dialogue_step_stub]
	)

func test_dialogue_sequence_can_start_a_sequence_with_a_valid_starting_step_and_dialogue_step() -> void:
	assert_false(dialogue_step_stub.step_advanced.is_connected(dialogue_sequence._set_step_as_current))
	watch_signals(dialogue_sequence)
	dialogue_sequence.start_sequence()
	assert_true(dialogue_sequence.active)
	assert_true(dialogue_sequence._dialogues_map.has(dialogue_step_stub.unique_id))
	assert_signal_emitted(dialogue_sequence.dialogue_started)
	assert_signal_emitted_with_parameters(dialogue_sequence.step_changed, [dialogue_step_stub])
	assert_called_count(dialogue_starter_step_stub.is_enabled, 1)
	assert_eq(dialogue_sequence.current_step, dialogue_step_stub)
	assert_true(dialogue_step_stub.step_advanced.is_connected(dialogue_sequence._set_step_as_current))
	assert_called_count(dialogue_step_stub.on_step_is_current, 1)


func test_dialogue_sequence_starts_with_the_first_available_valid_sequence() -> void:
	var another_starter_step_stub: HFDialogueStarterStep = double(HFDialogueStarterStep).new(
		0,
		[] as Array[HFEventConditional]
	)
	dialogue_sequence.starting_steps.push_back(another_starter_step_stub)
	stub(another_starter_step_stub.is_enabled).to_return(true)
	watch_signals(dialogue_sequence)
	dialogue_sequence.start_sequence()
	assert_called_count(dialogue_starter_step_stub.is_enabled, 1)
	assert_called_count(another_starter_step_stub.is_enabled, 0)


func test_dialogue_sequence_can_change_current_step_to_next_step_from_handling_step_advanced_signal() -> void:
	watch_signals(dialogue_sequence)
	watch_signals(dialogue_step_stub)
	
	var another_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		[] as Array[HFDialogueOption]
	)
	
	dialogue_sequence.dialogue_steps.push_back(another_dialogue_step_stub)
	
	dialogue_sequence.start_sequence()
	dialogue_sequence.advance_step()
	assert_called_count(dialogue_step_stub.advance_step, 1)
	assert_signal_emitted_with_parameters(dialogue_step_stub.step_advanced, [1])
	assert_eq(dialogue_sequence.current_step, another_dialogue_step_stub)
	assert_true(another_dialogue_step_stub.step_advanced.is_connected(dialogue_sequence._set_step_as_current))
	assert_false(dialogue_step_stub.step_advanced.is_connected(dialogue_sequence._set_step_as_current))


func test_dialogue_sequence_finishes_dialogue_sequence_if_no_next_step_exists() -> void:
	watch_signals(dialogue_sequence)
	watch_signals(dialogue_step_stub)
	dialogue_sequence.start_sequence()
	dialogue_sequence.advance_step()
	assert_called_count(dialogue_step_stub.advance_step, 1)
	assert_signal_emitted_with_parameters(dialogue_step_stub.step_advanced, [1])
	assert_false(dialogue_sequence.active)
	assert_signal_emitted(dialogue_sequence.dialogue_ended)


func test_dialogue_sequence_cant_advance_step_if_current_step_has_options() -> void:
	watch_signals(dialogue_sequence)
	dialogue_sequence.start_sequence()
	var dialogue_option_stub: HFDialogueOption = double(HFDialogueOption).new(
		"",
		0,
		[] as Array[HFEventConditional],
		null,
		Vector2.ZERO
	)
	dialogue_step_stub.options = [dialogue_option_stub]
	dialogue_sequence.advance_step()
	assert_called_count(dialogue_step_stub.advance_step, 0)


func test_dialogue_sequence_cannot_start_a_sequence_without_valid_starting_steps_and_dialogue_steps() -> void:
	# The starter step returns false on is_enabled()
	watch_signals(dialogue_sequence)
	stub(dialogue_starter_step_stub.is_enabled).to_return(false)
	dialogue_sequence.start_sequence()
	assert_false(dialogue_sequence.active)
	assert_signal_emitted(dialogue_sequence.dialogue_ended)
	
	# There are no valid dialogue steps
	dialogue_sequence.dialogue_steps = []
	dialogue_sequence.start_sequence()
	assert_false(dialogue_sequence.active)
	assert_signal_emitted(dialogue_sequence.dialogue_ended)
	
	# There are no valid dialogue steps and starting steps
	dialogue_sequence.starting_steps = []
	dialogue_sequence.start_sequence()
	assert_false(dialogue_sequence.active)
	assert_signal_emitted(dialogue_sequence.dialogue_ended)
	
	# There are no valid starting steps
	dialogue_sequence.dialogue_steps = [dialogue_step_stub]
	dialogue_sequence.start_sequence()
	assert_false(dialogue_sequence.active)
	assert_signal_emitted(dialogue_sequence.dialogue_ended)
