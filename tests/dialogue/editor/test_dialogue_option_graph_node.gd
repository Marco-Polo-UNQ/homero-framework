extends GutTest

const DIALOGUE_OPTION_GRAPH_NODE_SCENE: PackedScene = preload("res://addons/homero_framework/src/core/editor/dialogue/dialogue_option_graph_node.tscn")

var dialogue_option_graph_node: HFDiagEditDialogueOptionNode

var dialogue_option_stub: HFDialogueOption
var step_node_stub: HFDiagEditDialogueStepNode
var condition_node_stub: HFDiagEditConditionalNode
var event_node_stub: HFDiagEditDialogueEventNode


func before_each() -> void:
	dialogue_option_stub = double(HFDialogueOption).new(
		&"initial_id",
		0,
		[] as Array[HFEventConditional],
		null,
		Vector2(0, 0)
	)

	step_node_stub = double(HFDiagEditDialogueStepNode).new()
	step_node_stub.step_data = double(HFDialogueStep).new(
		0,
		&"step_1",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)

	condition_node_stub = double(HFDiagEditConditionalNode).new()
	condition_node_stub.condition_data = double(HFEventConditional).new(Vector2.ZERO)

	event_node_stub = double(HFDiagEditDialogueEventNode).new()
	event_node_stub.event_data = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)

	dialogue_option_graph_node = DIALOGUE_OPTION_GRAPH_NODE_SCENE.instantiate()
	add_child_autoqfree(dialogue_option_graph_node)
	watch_signals(dialogue_option_graph_node)


func test_dialogue_option_graph_node_exists() -> void:
	assert_not_null(dialogue_option_graph_node)


func test_dialogue_option_graph_node_connects_signal_on_ready() -> void:
	assert_true(
		dialogue_option_graph_node.position_offset_changed.is_connected(
			dialogue_option_graph_node._on_position_offset_changed
		)
	)


func test_dialogue_option_graph_node_updates_option_data_graph_position_on_position_offset_changed() -> void:
	var initial_position: Vector2 = dialogue_option_graph_node.position_offset
	var new_position: Vector2 = initial_position + Vector2(100, 50)
	dialogue_option_graph_node.option_data = dialogue_option_stub
	dialogue_option_graph_node.position_offset = new_position
	dialogue_option_graph_node._on_position_offset_changed()
	assert_eq(
		dialogue_option_graph_node.option_data.graph_position,
		new_position
	)


func test_dialogue_option_graph_node_can_setup_option_data() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_eq(dialogue_option_graph_node.option_data, dialogue_option_stub)
	assert_eq(
		dialogue_option_graph_node.id_line_edit.text,
		dialogue_option_stub.dialogue_key
	)


func test_dialogue_option_graph_node_updates_option_data_on_id_line_edit_text_changed() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	var new_id: String = "updated_id"
	dialogue_option_graph_node.id_line_edit.text_changed.emit(new_id)
	assert_eq(
		dialogue_option_stub.dialogue_key,
		new_id
	)


#region step connection tests

func test_dialogue_option_graph_node_can_handle_step_connection_with_matching_step_id() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_eq(
		dialogue_option_stub.next_step_id,
		step_node_stub.step_data.unique_id
	)
	dialogue_option_graph_node.handle_step_connection(step_node_stub)
	assert_signal_emitted_with_parameters(
		dialogue_option_graph_node.connect_ports_requested,
		[
			dialogue_option_graph_node.name,
			0,
			step_node_stub.name,
			0
		]
	)
	assert_eq(
		dialogue_option_graph_node.next_step_node,
		step_node_stub
	)
	assert_true(
		step_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_next_step_node_deleted
		)
	)


func test_dialogue_option_graph_node_can_handle_step_connection_with_different_step_id() -> void:
	step_node_stub.step_data = double(HFDialogueStep).new(
		999,
		&"step_1",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_step_connection(step_node_stub, true)
	assert_eq(
		dialogue_option_stub.next_step_id,
		step_node_stub.step_data.unique_id
	)
	assert_signal_emitted_with_parameters(
		dialogue_option_graph_node.connect_ports_requested,
		[
			dialogue_option_graph_node.name,
			0,
			step_node_stub.name,
			0
		]
	)
	assert_eq(
		dialogue_option_graph_node.next_step_node,
		step_node_stub
	)
	assert_eq(
		dialogue_option_stub.next_step_id,
		999
	)
	assert_true(
		step_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_next_step_node_deleted
		)
	)


func test_dialogue_option_graph_node_can_handle_step_connection_replacing_a_previous_connection() -> void:
	var first_step_node: HFDiagEditDialogueStepNode = double(HFDiagEditDialogueStepNode).new()
	first_step_node.step_data = double(HFDialogueStep).new(
		1,
		&"step_1",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var second_step_node: HFDiagEditDialogueStepNode = double(HFDiagEditDialogueStepNode).new()
	second_step_node.step_data = double(HFDialogueStep).new(
		2,
		&"step_2",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_step_connection(first_step_node, true)
	assert_eq(
		dialogue_option_stub.next_step_id,
		first_step_node.step_data.unique_id
	)
	assert_not_same(
		dialogue_option_graph_node.next_step_node,
		second_step_node
	)
	dialogue_option_graph_node.handle_step_connection(second_step_node, true)
	assert_eq(
		dialogue_option_stub.next_step_id,
		second_step_node.step_data.unique_id
	)
	assert_not_same(
		dialogue_option_graph_node.next_step_node,
		first_step_node
	)
	assert_signal_emitted_with_parameters(
		dialogue_option_graph_node.connect_ports_requested,
		[
			dialogue_option_graph_node.name,
			0,
			second_step_node.name,
			0
		]
	)
	assert_eq(
		dialogue_option_graph_node.next_step_node,
		second_step_node
	)
	assert_false(
		first_step_node.delete_called.is_connected(
			dialogue_option_graph_node._on_next_step_node_deleted
		)
	)
	assert_true(
		second_step_node.delete_called.is_connected(
			dialogue_option_graph_node._on_next_step_node_deleted
		)
	)


func test_dialogue_option_graph_node_cant_handle_step_connection_if_ids_dont_match_and_not_new() -> void:
	step_node_stub.step_data = double(HFDialogueStep).new(
		999,
		&"step_1",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_step_connection(step_node_stub)
	assert_not_same(
		dialogue_option_stub.next_step_id,
		step_node_stub.step_data.unique_id
	)
	assert_null(
		dialogue_option_graph_node.next_step_node
	)
	assert_false(
		step_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_next_step_node_deleted
		)
	)
	assert_signal_not_emitted(
		dialogue_option_graph_node.connect_ports_requested
	)


func test_dialogue_option_graph_node_can_handle_step_disconnection() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_step_connection(step_node_stub)
	assert_eq(
		dialogue_option_stub.next_step_id,
		step_node_stub.step_data.unique_id
	)
	step_node_stub.delete_called.emit(step_node_stub.step_data)
	assert_eq(
		dialogue_option_stub.next_step_id,
		-1
	)

#endregion

#region condition connection tests

func test_dialogue_option_graph_node_can_handle_condition_connection_with_existing_condition() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_stub.enable_conditions.push_back(condition_node_stub.condition_data)
	dialogue_option_graph_node.handle_condition_connection(condition_node_stub)
	assert_eq(
		dialogue_option_stub.enable_conditions.size(),
		1
	)
	assert_true(
		condition_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_condition_removed
		)
	)
	assert_called_count(
		condition_node_stub.handle_connect_to_element.bind(dialogue_option_graph_node, 1),
		1
	)


func test_dialogue_option_graph_node_can_handle_condition_connection_with_new_condition() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_false(
		dialogue_option_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	dialogue_option_graph_node.handle_condition_connection(condition_node_stub, true)
	assert_true(
		dialogue_option_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	assert_true(
		condition_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_condition_removed
		)
	)
	assert_called_count(
		condition_node_stub.handle_connect_to_element.bind(dialogue_option_graph_node, 1),
		1
	)


func test_dialogue_option_graph_node_does_nothing_on_condition_connection_if_not_new_and_condition_not_existing() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_false(
		dialogue_option_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	dialogue_option_graph_node.handle_condition_connection(condition_node_stub)
	assert_false(
		dialogue_option_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	assert_false(
		condition_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_condition_removed
		)
	)
	assert_called_count(
		condition_node_stub.handle_connect_to_element,
		0
	)


func test_dialogue_option_graph_node_can_handle_condition_delete_called() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_stub.enable_conditions.push_back(condition_node_stub.condition_data)
	dialogue_option_graph_node.handle_condition_connection(condition_node_stub)
	assert_true(
		dialogue_option_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	condition_node_stub.delete_called.emit(condition_node_stub.condition_data)
	assert_false(
		dialogue_option_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)


func test_dialogue_option_graph_node_can_handle_condition_disconnection() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_stub.enable_conditions.push_back(condition_node_stub.condition_data)
	dialogue_option_graph_node.handle_condition_connection(condition_node_stub)
	assert_true(
		dialogue_option_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	dialogue_option_graph_node.handle_condition_disconnection(condition_node_stub)
	assert_false(
		dialogue_option_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	assert_false(
		condition_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_condition_removed
		)
	)


func test_dialogue_option_graph_node_does_nothing_on_condition_disconnection_if_condition_not_existing() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_false(
		dialogue_option_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	dialogue_option_graph_node.handle_condition_disconnection(condition_node_stub)
	assert_false(
		dialogue_option_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	assert_false(
		condition_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_condition_removed
		)
	)

#endregion

#region event connection tests

func test_dialogue_option_graph_node_can_handle_event_connection_with_existing_event() -> void:
	dialogue_option_stub.option_events = event_node_stub.event_data
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_event_connection(event_node_stub)
	assert_eq(
		dialogue_option_stub.option_events,
		event_node_stub.event_data
	)
	assert_true(
		event_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_dialogue_event_deleted
		)
	)
	assert_signal_emitted_with_parameters(
		dialogue_option_graph_node.connect_ports_requested,
		[
			dialogue_option_graph_node.name,
			1,
			event_node_stub.name,
			0
		]
	)
	assert_eq(
		dialogue_option_graph_node.dialogue_event,
		event_node_stub
	)


func test_dialogue_option_graph_node_can_handle_event_connection_with_new_event() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_not_same(
		dialogue_option_stub.option_events,
		event_node_stub.event_data
	)
	dialogue_option_graph_node.handle_event_connection(event_node_stub, true)
	assert_eq(
		dialogue_option_stub.option_events,
		event_node_stub.event_data
	)
	assert_true(
		event_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_dialogue_event_deleted
		)
	)
	assert_signal_emitted_with_parameters(
		dialogue_option_graph_node.connect_ports_requested,
		[
			dialogue_option_graph_node.name,
			1,
			event_node_stub.name,
			0
		]
	)
	assert_eq(
		dialogue_option_graph_node.dialogue_event,
		event_node_stub
	)


func test_dialogue_option_graph_node_can_handle_event_connection_replacing_a_previous_connection() -> void:
	var first_event_node: HFDiagEditDialogueEventNode = double(HFDiagEditDialogueEventNode).new()
	first_event_node.event_data = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)
	var second_event_node: HFDiagEditDialogueEventNode = double(HFDiagEditDialogueEventNode).new()
	second_event_node.event_data = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_event_connection(first_event_node, true)
	assert_eq(
		dialogue_option_stub.option_events,
		first_event_node.event_data
	)
	assert_not_same(
		dialogue_option_graph_node.dialogue_event,
		second_event_node
	)
	dialogue_option_graph_node.handle_event_connection(second_event_node, true)
	assert_eq(
		dialogue_option_stub.option_events,
		second_event_node.event_data
	)
	assert_not_same(
		dialogue_option_graph_node.dialogue_event,
		first_event_node
	)
	assert_signal_emitted_with_parameters(
		dialogue_option_graph_node.connect_ports_requested,
		[
			dialogue_option_graph_node.name,
			1,
			second_event_node.name,
			0
		]
	)
	assert_eq(
		dialogue_option_graph_node.dialogue_event,
		second_event_node
	)
	assert_false(
		first_event_node.delete_called.is_connected(
			dialogue_option_graph_node._on_dialogue_event_deleted
		)
	)
	assert_true(
		second_event_node.delete_called.is_connected(
			dialogue_option_graph_node._on_dialogue_event_deleted
		)
	)


func test_dialogue_option_graph_node_does_nothing_on_event_connection_if_event_not_existing_and_not_new() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_not_same(
		dialogue_option_stub.option_events,
		event_node_stub.event_data
	)
	dialogue_option_graph_node.handle_event_connection(event_node_stub)
	assert_not_same(
		dialogue_option_stub.option_events,
		event_node_stub.event_data
	)
	assert_false(
		event_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_dialogue_event_deleted
		)
	)


func test_dialogue_option_graph_node_can_handle_event_delete_called() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_event_connection(event_node_stub, true)
	assert_eq(
		dialogue_option_stub.option_events,
		event_node_stub.event_data
	)
	event_node_stub.delete_called.emit(event_node_stub.event_data)
	assert_not_same(
		dialogue_option_stub.option_events,
		event_node_stub.event_data
	)

#endregion

#region generic node connection and disconnection tests

func test_dialogue_option_graph_node_can_handle_generic_node_connection_with_new_dialogue_step_node() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_not_same(
		dialogue_option_graph_node.next_step_node,
		step_node_stub
	)
	dialogue_option_graph_node.handle_connection(
		0,
		step_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.next_step_node,
		step_node_stub
	)


func test_dialogue_option_graph_node_ignores_generic_handle_connection_with_existing_dialogue_step_node() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_connection(
		0,
		step_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.next_step_node,
		step_node_stub
	)
	dialogue_option_graph_node.handle_connection(
		0,
		step_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.next_step_node,
		step_node_stub
	)
	assert_signal_emit_count(
		dialogue_option_graph_node.connect_ports_requested,
		1
	)


func test_dialogue_option_graph_node_can_handle_generic_node_connection_with_new_dialogue_event_node() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_not_same(
		dialogue_option_graph_node.dialogue_event,
		event_node_stub
	)
	dialogue_option_graph_node.handle_connection(
		1,
		event_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.dialogue_event,
		event_node_stub
	)


func test_dialogue_option_graph_node_ignores_generic_handle_connection_with_existing_dialogue_event_node() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_connection(
		1,
		event_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.dialogue_event,
		event_node_stub
	)
	dialogue_option_graph_node.handle_connection(
		1,
		event_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.dialogue_event,
		event_node_stub
	)
	assert_signal_emit_count(
		dialogue_option_graph_node.connect_ports_requested,
		1
	)


func test_dialogue_option_graph_node_can_handle_generic_node_disconnection_from_dialogue_step_node() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_connection(
		0,
		step_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.next_step_node,
		step_node_stub
	)
	dialogue_option_graph_node.handle_disconnection(
		0,
		step_node_stub,
		0
	)
	assert_null(
		dialogue_option_graph_node.next_step_node
	)
	assert_false(
		step_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_next_step_node_deleted
		)
	)


func test_dialogue_option_graph_node_can_handle_generic_node_disconnection_from_dialogue_event_node() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_connection(
		1,
		event_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.dialogue_event,	
		event_node_stub
	)
	dialogue_option_graph_node.handle_disconnection(
		1,
		event_node_stub,
		0
	)
	assert_null(
		dialogue_option_graph_node.dialogue_event
	)
	assert_false(
		event_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_dialogue_event_deleted
		)
	)


func test_dialogue_option_graph_node_ignores_generic_node_disconnection_if_no_existing_connection() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_null(
		dialogue_option_graph_node.next_step_node
	)
	dialogue_option_graph_node.handle_disconnection(
		0,
		step_node_stub,
		0
	)
	assert_null(
		dialogue_option_graph_node.next_step_node
	)
	assert_false(
		step_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_next_step_node_deleted
		)
	)
	assert_null(
		dialogue_option_graph_node.dialogue_event
	)
	dialogue_option_graph_node.handle_disconnection(
		1,
		event_node_stub,
		0
	)
	assert_null(
		dialogue_option_graph_node.dialogue_event
	)
	assert_false(
		event_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_dialogue_event_deleted
		)
	)


func test_dialogue_option_graph_node_ignores_generic_node_disconnection_if_wrong_port() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	dialogue_option_graph_node.handle_connection(
		0,
		step_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.next_step_node,
		step_node_stub
	)
	dialogue_option_graph_node.handle_disconnection(
		3,
		step_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.next_step_node,
		step_node_stub
	)
	assert_true(
		step_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_next_step_node_deleted
		)
	)
	dialogue_option_graph_node.handle_connection(
		1,
		event_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.dialogue_event,	
		event_node_stub
	)
	dialogue_option_graph_node.handle_disconnection(
		3,
		event_node_stub,
		0
	)
	assert_eq(
		dialogue_option_graph_node.dialogue_event,	
		event_node_stub
	)
	assert_true(
		event_node_stub.delete_called.is_connected(
			dialogue_option_graph_node._on_dialogue_event_deleted
		)
	)

#endregion

func test_dialogue_option_graph_node_can_handle_delete_call_emitting_a_delete_called_signal() -> void:
	dialogue_option_graph_node.setup(dialogue_option_stub)
	assert_signal_not_emitted(
		dialogue_option_graph_node.delete_called
	)
	dialogue_option_graph_node.handle_delete()
	assert_signal_emitted_with_parameters(
		dialogue_option_graph_node.delete_called,
		[
			dialogue_option_stub
		]
	)
