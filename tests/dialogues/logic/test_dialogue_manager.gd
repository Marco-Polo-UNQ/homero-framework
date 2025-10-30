extends GutTest

var dialogue_manager: HFDialogueManager

var dialogue_sequence_stub: HFDialogueSequence
var dialogue_display_scene_stub: PackedScene
var dialogue_display_stub_content: Node


class PackedSceneMock:
	extends PackedScene


class DisplayMockEmpty:
	extends Node


class DisplayMockContent:
	extends Node
	
	func set_dialogue_manager(_value: HFDialogueManager) -> void:
		pass
	
	func notify_exit() -> void:
		pass


func before_each() -> void:
	dialogue_manager = HFDialogueManager.new()
	
	dialogue_sequence_stub = double(HFDialogueSequence).new(
		false,
		[] as Array[HFDialogueStarterStep],
		[] as Array[HFDialogueStep]
	)
	
	stub(dialogue_sequence_stub.start_sequence).to_call(
		func():
			dialogue_sequence_stub.active = true
	)
	
	assert_false(dialogue_sequence_stub.dialogue_started.is_connected(dialogue_manager._on_dialogue_started))
	assert_false(dialogue_sequence_stub.dialogue_ended.is_connected(dialogue_manager._on_dialogue_ended))
	
	dialogue_manager.dialogue_sequence = dialogue_sequence_stub
	autofree(dialogue_sequence_stub)
	
	register_inner_classes(get_script())
	
	dialogue_display_stub_content = double(DisplayMockContent, DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	autoqfree(dialogue_display_stub_content)
	
	dialogue_display_scene_stub = double(PackedSceneMock, DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	dialogue_display_scene_stub.pack(dialogue_display_stub_content)
	dialogue_manager.dialogue_display_scene = dialogue_display_scene_stub
	autofree(dialogue_display_scene_stub)
	
	add_child_autoqfree(dialogue_manager)


#func after_each() -> void:
	#dialogue_manager = null


func test_dialogue_manager_exists() -> void:
	assert_not_null(
		dialogue_manager,
		"Dialogue Manager should instantiate and not be null"
	)


func test_dialogue_manager_has_dialogue_sequence() -> void:
	assert_eq(
		dialogue_manager.dialogue_sequence,
		dialogue_sequence_stub,
		"DialogueManager.dialogue_sequence should equal the stub"
	)


func test_dialogue_manager_has_dialogue_display_scene() -> void:
	assert_eq(
		dialogue_manager.dialogue_display_scene,
		dialogue_display_scene_stub,
		"DialogueManager.dialogue_display_scene should equal the stub"
	)


func test_dialogue_manager_connects_to_dialogue_sequence_on_ready() -> void:
	assert_true(dialogue_sequence_stub.dialogue_started.is_connected(dialogue_manager._on_dialogue_started))
	assert_true(dialogue_sequence_stub.dialogue_ended.is_connected(dialogue_manager._on_dialogue_ended))


func test_dialogue_manager_can_activate_dialogue_without_a_dialogue_display_scene() -> void:
	dialogue_manager.dialogue_display_scene = null
	assert_false(dialogue_sequence_stub.active)
	dialogue_manager.activate_dialogue()
	assert_called_count(dialogue_sequence_stub.start_sequence, 1)
	assert_null(dialogue_manager._dialogue_display_instance)
	assert_true(dialogue_sequence_stub.active)


func test_dialogue_manager_can_activate_dialogue_with_a_dialogue_display_scene_and_adds_it_as_dependency() -> void:
	var dialogue_display_stub_empty: Node = double(DisplayMockEmpty, DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	autoqfree(dialogue_display_stub_empty)
	dialogue_display_scene_stub.pack(dialogue_display_stub_empty)
	assert_false(dialogue_sequence_stub.active)
	dialogue_manager.activate_dialogue()
	assert_called_count(dialogue_sequence_stub.start_sequence, 1)
	assert_true(dialogue_manager._dialogue_display_instance is DisplayMockEmpty)
	assert_true(dialogue_manager.get_children().has(dialogue_manager._dialogue_display_instance))
	assert_true(dialogue_sequence_stub.active)


func test_dialogue_manager_can_setup_display_instance_on_activate_if_set_dialogue_manager_method_exists() -> void:
	assert_false(dialogue_sequence_stub.active)
	dialogue_manager.activate_dialogue()
	assert_called_count(dialogue_sequence_stub.start_sequence, 1)
	assert_true(dialogue_manager._dialogue_display_instance is DisplayMockContent)
	assert_true(dialogue_manager.get_children().has(dialogue_manager._dialogue_display_instance))
	assert_called_count(dialogue_manager._dialogue_display_instance.set_dialogue_manager.bind(dialogue_manager), 1)
	assert_true(dialogue_sequence_stub.active)


func test_dialogue_manager_cannot_activate_dialogue_if_dialogue_is_already_active() -> void:
	assert_false(dialogue_sequence_stub.active)
	dialogue_manager.activate_dialogue()
	assert_true(dialogue_sequence_stub.active)
	assert_push_warning_count(0, "No warning raised via push_warning")
	dialogue_manager.activate_dialogue()
	assert_true(dialogue_sequence_stub.active)
	assert_push_warning_count(1, "There was a warning raised about an already active dialogue")
	assert_called_count(dialogue_sequence_stub.start_sequence, 1)


func test_dialogue_manager_refreshes_dialogue_display_instance_on_secondary_activate_dialogue_if_dialogue_was_inactive() -> void:
	assert_false(dialogue_sequence_stub.active)
	stub(dialogue_sequence_stub.start_sequence).to_call(
		func():
			dialogue_sequence_stub.active = false
	)
	dialogue_manager.activate_dialogue()
	assert_false(dialogue_sequence_stub.active)
	
	var dialogue_display_instance: Node = dialogue_manager._dialogue_display_instance
	
	dialogue_manager.activate_dialogue()
	assert_false(dialogue_sequence_stub.active)
	assert_true(dialogue_display_instance.is_queued_for_deletion())
	
	assert_called_count(dialogue_sequence_stub.start_sequence, 2)
	assert_push_warning_count(0, "No warning raised via push_warning")


func test_dialogue_manager_can_handle_dialogue_started_signal_from_dialogue_sequence() -> void:
	watch_signals(dialogue_manager)
	dialogue_sequence_stub.dialogue_started.emit()
	assert_signal_emitted(dialogue_manager.sequence_activated)


func test_dialogue_manager_can_handle_dialogue_ended_signal_from_dialogue_sequence() -> void:
	watch_signals(dialogue_manager)
	dialogue_sequence_stub.dialogue_ended.emit()
	assert_signal_emitted(dialogue_manager.sequence_deactivated)


func test_dialogue_manager_removes_dialogue_display_after_dialogue_ended_signal_from_dialogue_sequence() -> void:
	var dialogue_display_stub_empty: Node = double(DisplayMockEmpty, DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	autoqfree(dialogue_display_stub_empty)
	dialogue_display_scene_stub.pack(dialogue_display_stub_empty)
	dialogue_manager.activate_dialogue()
	watch_signals(dialogue_manager)
	dialogue_sequence_stub.dialogue_ended.emit()
	assert_signal_emitted(dialogue_manager.sequence_deactivated)
	assert_null(dialogue_manager._dialogue_display_instance)
	assert_eq(dialogue_manager.get_child_count(), 0)


func test_dialogue_manager_removes_dialogue_display_calls_notify_exit_after_dialogue_ended_signal_from_dialogue_sequence() -> void:
	dialogue_manager.activate_dialogue()
	watch_signals(dialogue_manager)
	var dialogue_display_instance: Node = dialogue_manager._dialogue_display_instance
	dialogue_sequence_stub.dialogue_ended.emit()
	assert_signal_emitted(dialogue_manager.sequence_deactivated)
	assert_not_null(dialogue_manager._dialogue_display_instance)
	assert_eq(dialogue_manager.get_child_count(), 1)
	assert_called_count(dialogue_display_instance.notify_exit, 1)
