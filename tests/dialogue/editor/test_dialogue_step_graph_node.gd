extends GutTest

const DIALOGUE_STEP_GRAPH_NODE_SCENE: PackedScene = \
	preload("res://addons/homero_framework/src/core/editor/dialogue/dialogue_step_graph_node.tscn")

var dialogue_step_graph_node: HFDiagEditDialogueStepNode

var step_data_stub: HFDialogueStep
var other_dialogue_step_node: HFDiagEditDialogueStepNode
var speaker_node_stub: HFDiagEditSpeakerNode
var option_node_stub: HFDiagEditDialogueOptionNode
var event_node_stub: HFDiagEditDialogueEventNode


func before_each() -> void:
	dialogue_step_graph_node = DIALOGUE_STEP_GRAPH_NODE_SCENE.instantiate()
	step_data_stub = double(HFDialogueStep).new(
		0,
		&"test",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)

	other_dialogue_step_node = DIALOGUE_STEP_GRAPH_NODE_SCENE.instantiate()
	other_dialogue_step_node.step_data = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	add_child_autoqfree(other_dialogue_step_node)

	speaker_node_stub = double(HFDiagEditSpeakerNode).new()
	speaker_node_stub.speaker_data = double(HFDialogueSpeaker).new(
		null,
		Vector2.ZERO
	)

	option_node_stub = double(HFDiagEditDialogueOptionNode).new()
	option_node_stub.option_data = double(HFDialogueOption).new(
		&"",
		0,
		[] as Array[HFEventConditional],
		null,
		Vector2.ZERO
	)

	event_node_stub = double(HFDiagEditDialogueEventNode).new()
	event_node_stub.event_data = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)

	add_child_autoqfree(dialogue_step_graph_node)
	watch_signals(dialogue_step_graph_node)


func test_dialogue_step_graph_node_exists() -> void:
	assert_not_null(dialogue_step_graph_node)


func test_dialogue_step_graph_node_ready_connects_position_offset_changed() -> void:
	assert_true(
		dialogue_step_graph_node.position_offset_changed.is_connected(
			dialogue_step_graph_node._on_position_offset_changed
		)
	)


func test_dialogue_step_graph_node_setup_assigns_step_data_and_updates_line_edit_text() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	assert_eq(dialogue_step_graph_node.step_data, step_data_stub)
	assert_eq(dialogue_step_graph_node.step_id_line_edit.text, step_data_stub.dialogue_key)


func test_dialogue_step_graph_node_position_offset_changes_updates_step_graph_position() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	var new_pos: Vector2 = Vector2(10, 20)
	dialogue_step_graph_node.position_offset = new_pos
	assert_eq(step_data_stub.graph_position, new_pos)


func test_dialogue_step_graph_node_step_id_line_edit_text_changed_updates_step_key() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node._on_step_id_line_edit_text_changed("new_key")
	assert_eq(step_data_stub.dialogue_key, "new_key")


#region Step Connection Tests

func test_dialogue_step_graph_node_step_connection_existing_and_new_behaviour() -> void:
	# existing connection (step_data.next_step_id already set)
	step_data_stub.next_step_id = other_dialogue_step_node.step_data.unique_id
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_step_connection(other_dialogue_step_node)
	assert_eq(dialogue_step_graph_node.next_step, other_dialogue_step_node)
	assert_true(
		other_dialogue_step_node.delete_called.is_connected(
			dialogue_step_graph_node._on_next_step_deleted
		)
	)
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 1)
	assert_signal_emitted_with_parameters(
		dialogue_step_graph_node.connect_ports_requested,
		[
			dialogue_step_graph_node.name,
			0,
			other_dialogue_step_node.name,
			0
		]
	)

	# new connection replaces previous
	var another_step: HFDiagEditDialogueStepNode = DIALOGUE_STEP_GRAPH_NODE_SCENE.instantiate()
	another_step.step_data = double(HFDialogueStep).new(
		2,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	add_child_autoqfree(another_step)
	dialogue_step_graph_node.handle_step_connection(another_step, true)
	assert_eq(dialogue_step_graph_node.next_step, another_step)
	assert_false(
		other_dialogue_step_node.delete_called.is_connected(
			dialogue_step_graph_node._on_next_step_deleted
		)
	)
	assert_true(
		another_step.delete_called.is_connected(
			dialogue_step_graph_node._on_next_step_deleted
		)
	)


func test_dialogue_step_graph_node_handle_step_connection_does_nothing_if_ids_do_not_match_and_not_new() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_step_connection(other_dialogue_step_node)
	assert_null(dialogue_step_graph_node.next_step)
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 0)


func test_dialogue_step_graph_node_can_handle_next_step_deleted() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_step_connection(other_dialogue_step_node, true)
	assert_eq(dialogue_step_graph_node.next_step, other_dialogue_step_node)
	other_dialogue_step_node.handle_delete()
	assert_null(dialogue_step_graph_node.next_step)
	assert_eq(step_data_stub.next_step_id, -1)

#endregion

#region Speaker Connection Tests

func test_dialogue_step_graph_node_handle_speaker_connection_connects_to_existing_speaker() -> void:
	step_data_stub.speaker = speaker_node_stub.speaker_data
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_speaker_connection(speaker_node_stub)
	assert_eq(dialogue_step_graph_node.speaker, speaker_node_stub)
	assert_true(
		speaker_node_stub.delete_called.is_connected(
			dialogue_step_graph_node._on_speaker_deleted
		)
	)
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 1)


func test_dialogue_step_graph_node_handle_speaker_connection_new_connection_updates_speaker() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_speaker_connection(speaker_node_stub, true)
	assert_eq(dialogue_step_graph_node.speaker, speaker_node_stub)
	assert_true(
		speaker_node_stub.delete_called.is_connected(
			dialogue_step_graph_node._on_speaker_deleted
		)
	)
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 1)


func test_dialogue_step_graph_node_handle_speaker_connection_replaces_previous_speaker() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_speaker_connection(speaker_node_stub, true)
	assert_eq(dialogue_step_graph_node.speaker, speaker_node_stub)

	var another_speaker_node: HFDiagEditSpeakerNode = double(HFDiagEditSpeakerNode).new()
	another_speaker_node.speaker_data = double(HFDialogueSpeaker).new(
		null,
		Vector2.ZERO
	)

	dialogue_step_graph_node.handle_speaker_connection(another_speaker_node, true)
	assert_eq(dialogue_step_graph_node.speaker, another_speaker_node)
	assert_false(
		speaker_node_stub.delete_called.is_connected(
			dialogue_step_graph_node._on_speaker_deleted
		)
	)
	assert_true(
		another_speaker_node.delete_called.is_connected(
			dialogue_step_graph_node._on_speaker_deleted
		)
	)


func test_dialogue_step_graph_node_handle_speaker_connection_does_nothing_if_ids_do_not_match_and_not_new() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_speaker_connection(speaker_node_stub)
	assert_null(dialogue_step_graph_node.speaker)
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 0)


func test_dialogue_step_graph_node_can_handle_speaker_deleted() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_speaker_connection(speaker_node_stub, true)
	assert_eq(dialogue_step_graph_node.speaker, speaker_node_stub)
	speaker_node_stub.delete_called.emit(speaker_node_stub.speaker_data)
	assert_null(dialogue_step_graph_node.speaker)
	assert_null(step_data_stub.speaker)

#endregion

#region Option Connection Tests

func test_dialogue_step_graph_node_option_connection_connects_to_existing_option() -> void:
	step_data_stub.options.push_back(option_node_stub.option_data)
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_option_connection(option_node_stub)
	assert_true(step_data_stub.options.has(option_node_stub.option_data))
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 1)


func test_dialogue_step_graph_node_option_connection_new_connection_adds_new_option() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	assert_false(step_data_stub.options.has(option_node_stub.option_data))
	dialogue_step_graph_node.handle_option_connection(option_node_stub, true)
	assert_true(step_data_stub.options.has(option_node_stub.option_data))
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 1)


func test_dialogue_step_graph_node_option_connection_does_nothing_if_option_already_exists_and_not_new() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	assert_false(step_data_stub.options.has(option_node_stub.option_data))
	dialogue_step_graph_node.handle_option_connection(option_node_stub)
	dialogue_step_graph_node.handle_option_connection(option_node_stub, true)
	assert_true(step_data_stub.options.has(option_node_stub.option_data))
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 1)


func test_dialogue_step_graph_node_handle_option_deleted_removes_option_from_step_data() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_option_connection(option_node_stub, true)
	assert_true(step_data_stub.options.has(option_node_stub.option_data))
	option_node_stub.delete_called.emit(option_node_stub.option_data)
	assert_false(step_data_stub.options.has(option_node_stub.option_data))

#endregion

#region Event Connection Tests

func test_dialogue_step_graph_node_handle_event_connection_connects_to_existing_event() -> void:
	step_data_stub.dialogue_events = event_node_stub.event_data
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_event_connection(event_node_stub)
	assert_eq(dialogue_step_graph_node.dialogue_event_node, event_node_stub)
	assert_true(
		event_node_stub.delete_called.is_connected(
			dialogue_step_graph_node._on_dialogue_event_deleted
		)
	)
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 1)


func test_dialogue_step_graph_node_handle_event_connection_new_connection_updates_event() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_event_connection(event_node_stub, true)
	assert_eq(dialogue_step_graph_node.dialogue_event_node, event_node_stub)
	assert_true(
		event_node_stub.delete_called.is_connected(
			dialogue_step_graph_node._on_dialogue_event_deleted
		)
	)
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 1)


func test_dialogue_step_graph_node_handle_event_connection_replaces_previous_event() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_event_connection(event_node_stub, true)
	assert_eq(dialogue_step_graph_node.dialogue_event_node, event_node_stub)

	var another_event_node: HFDiagEditDialogueEventNode = double(HFDiagEditDialogueEventNode).new()
	another_event_node.event_data = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)

	dialogue_step_graph_node.handle_event_connection(another_event_node, true)
	assert_eq(dialogue_step_graph_node.dialogue_event_node, another_event_node)
	assert_false(
		event_node_stub.delete_called.is_connected(
			dialogue_step_graph_node._on_dialogue_event_deleted
		)
	)
	assert_true(
		another_event_node.delete_called.is_connected(
			dialogue_step_graph_node._on_dialogue_event_deleted
		)
	)


func test_dialogue_step_graph_node_handle_event_connection_does_nothing_if_ids_do_not_match_and_not_new() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_event_connection(event_node_stub)
	assert_null(dialogue_step_graph_node.dialogue_event_node)
	assert_signal_emit_count(dialogue_step_graph_node.connect_ports_requested, 0)


func test_dialogue_step_graph_node_can_handle_event_deleted() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_event_connection(event_node_stub, true)
	assert_eq(dialogue_step_graph_node.dialogue_event_node, event_node_stub)
	event_node_stub.delete_called.emit(event_node_stub.event_data)
	assert_null(dialogue_step_graph_node.dialogue_event_node)
	assert_null(step_data_stub.dialogue_events)

#endregion

#region Generic Connection Tests

func test_dialogue_step_graph_node_generic_handle_connection_routes_to_specific_handlers() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_connection(0, other_dialogue_step_node, 0)
	assert_eq(dialogue_step_graph_node.next_step, other_dialogue_step_node)
	dialogue_step_graph_node.handle_connection(1, speaker_node_stub, 0)
	assert_eq(dialogue_step_graph_node.speaker, speaker_node_stub)
	dialogue_step_graph_node.handle_connection(2, option_node_stub, 0)
	assert_true(step_data_stub.options.has(option_node_stub.option_data))
	dialogue_step_graph_node.handle_connection(3, event_node_stub, 0)
	assert_eq(dialogue_step_graph_node.dialogue_event_node, event_node_stub)


func test_dialogue_step_graph_node_handle_disconnection_resets_fields_and_emits_disconnect() -> void:
	# prepare connections
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_step_connection(other_dialogue_step_node, true)
	dialogue_step_graph_node.handle_speaker_connection(speaker_node_stub, true)
	dialogue_step_graph_node.handle_option_connection(option_node_stub, true)
	dialogue_step_graph_node.handle_event_connection(event_node_stub, true)

	# disconnect next step (port 0)
	dialogue_step_graph_node.handle_disconnection(0, other_dialogue_step_node, 0)
	assert_null(dialogue_step_graph_node.next_step)
	assert_signal_emit_count(dialogue_step_graph_node.disconnect_ports_requested, 1)

	# disconnect speaker (port 1)
	dialogue_step_graph_node.handle_disconnection(1, speaker_node_stub, 0)
	assert_null(dialogue_step_graph_node.speaker)
	assert_signal_emit_count(dialogue_step_graph_node.disconnect_ports_requested, 2)

	# disconnect option (port 2)
	# re-add option to test erase behaviour
	dialogue_step_graph_node.handle_option_connection(option_node_stub, true)
	assert_true(step_data_stub.options.has(option_node_stub.option_data))
	dialogue_step_graph_node.handle_disconnection(2, option_node_stub, 0)
	assert_false(step_data_stub.options.has(option_node_stub.option_data))
	assert_signal_emit_count(dialogue_step_graph_node.disconnect_ports_requested, 3)

	# disconnect event (port 3)
	dialogue_step_graph_node.handle_event_connection(event_node_stub, true)
	assert_eq(dialogue_step_graph_node.dialogue_event_node, event_node_stub)
	dialogue_step_graph_node.handle_disconnection(3, event_node_stub, 0)
	assert_null(dialogue_step_graph_node.dialogue_event_node)
	assert_signal_emit_count(dialogue_step_graph_node.disconnect_ports_requested, 4)

#endregion


func test_dialogue_step_graph_node_handle_delete_emits_delete_called_with_step_data() -> void:
	dialogue_step_graph_node.setup(step_data_stub)
	dialogue_step_graph_node.handle_delete()
	assert_signal_emit_count(dialogue_step_graph_node.delete_called, 1)
	assert_signal_emitted_with_parameters(
		dialogue_step_graph_node.delete_called,
		[
			step_data_stub
		]
	)
