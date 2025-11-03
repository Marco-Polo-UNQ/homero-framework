extends GutTest

const DIALOGUE_STARTING_STEP_GRAPH_NODE_SCENE: PackedScene = \
	preload("res://addons/homero_framework/src/core/editor/dialogue/dialogue_starting_step_graph_node.tscn")

var dialogue_starting_step_graph_node: HFDiagEditStartingStepNode

var starter_step_data_stub: HFDialogueStarterStep
var condition_node_stub: HFDiagEditConditionalNode
var dialogue_step_node_stub: HFDiagEditDialogueStepNode


func before_each() -> void:
	dialogue_starting_step_graph_node = DIALOGUE_STARTING_STEP_GRAPH_NODE_SCENE.instantiate()
	starter_step_data_stub = double(HFDialogueStarterStep).new(
		0,
		[] as Array[HFEventConditional],
		Vector2.ZERO
	)

	condition_node_stub = double(HFDiagEditConditionalNode).new()
	condition_node_stub.condition_data = double(HFEventConditional).new(Vector2.ZERO)

	dialogue_step_node_stub = double(HFDiagEditDialogueStepNode).new()
	dialogue_step_node_stub.step_data = double(HFDialogueStep).new(
		0,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)

	add_child_autoqfree(dialogue_starting_step_graph_node)
	watch_signals(dialogue_starting_step_graph_node)


func test_dialogue_starting_step_graph_node_exists() -> void:
	assert_not_null(dialogue_starting_step_graph_node)


func test_dialogue_starting_step_graph_node_has_signal_connections_on_ready() -> void:
	assert_true(
		dialogue_starting_step_graph_node.position_offset_changed.is_connected(
			dialogue_starting_step_graph_node._on_position_offset_changed
		)
	)


func test_dialogue_starting_step_graph_node_can_setup_with_starter_step_data() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	assert_eq(
		dialogue_starting_step_graph_node.starter_step_data,
		starter_step_data_stub
	)


func test_dialogue_starting_step_graph_node_can_handle_position_offset_change() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	var new_position: Vector2 = Vector2(100, 200)
	assert_not_same(
		starter_step_data_stub.graph_position,
		new_position
	)
	dialogue_starting_step_graph_node.position_offset = new_position
	assert_eq(
		starter_step_data_stub.graph_position,
		new_position
	)


#region condition connection tests

func test_dialogue_starting_step_graph_node_can_handle_existing_condition_connection() -> void:
	starter_step_data_stub.enable_conditions.push_back(
		condition_node_stub.condition_data
	)
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_condition_connection(
		condition_node_stub
	)
	assert_true(
		condition_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_condition_removed
		)
	)
	assert_called_count(
		condition_node_stub.handle_connect_to_element.bind(
			dialogue_starting_step_graph_node,
			0
		),
		1
	)


func test_dialogue_starting_step_graph_node_can_handle_new_condition_connection() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	assert_false(
		starter_step_data_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	dialogue_starting_step_graph_node.handle_condition_connection(
		condition_node_stub,
		true
	)
	assert_true(
		starter_step_data_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	assert_true(
		condition_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_condition_removed
		)
	)
	assert_called_count(
		condition_node_stub.handle_connect_to_element.bind(
			dialogue_starting_step_graph_node,
			0
		),
		1
	)


func test_dialogue_starting_step_graph_node_can_handle_multiple_different_condition_connections() -> void:
	var another_condition_node_stub: HFDiagEditConditionalNode = double(
		HFDiagEditConditionalNode
	).new()
	another_condition_node_stub.condition_data = double(HFEventConditional).new(
		Vector2.ZERO
	)
	
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	
	dialogue_starting_step_graph_node.handle_condition_connection(
		condition_node_stub,
		true
	)
	assert_true(
		starter_step_data_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	assert_false(
		starter_step_data_stub.enable_conditions.has(
			another_condition_node_stub.condition_data
		)
	)
	assert_true(
		condition_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_condition_removed
		)
	)
	assert_false(
		another_condition_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_condition_removed
		)
	)

	dialogue_starting_step_graph_node.handle_condition_connection(
		another_condition_node_stub,
		true
	)
	assert_true(
		starter_step_data_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	assert_true(
		starter_step_data_stub.enable_conditions.has(
			another_condition_node_stub.condition_data
		)
	)
	assert_true(
		condition_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_condition_removed
		)
	)
	assert_true(
		another_condition_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_condition_removed
		)
	)


func test_dialogue_starting_step_graph_node_does_nothing_on_condition_connection_if_doesnt_have_condition_and_not_new() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_condition_connection(
		condition_node_stub
	)
	assert_false(
		condition_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_condition_removed
		)
	)
	assert_called_count(
		condition_node_stub.handle_connect_to_element.bind(
			dialogue_starting_step_graph_node,
			0
		),
		0
	)


func test_dialogue_starting_step_graph_node_can_handle_condition_disconnection() -> void:
	starter_step_data_stub.enable_conditions.push_back(
		condition_node_stub.condition_data
	)
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_condition_connection(
		condition_node_stub
	)
	assert_true(
		starter_step_data_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	dialogue_starting_step_graph_node.handle_condition_disconnection(
		condition_node_stub
	)
	assert_false(
		starter_step_data_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	assert_false(
		condition_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_condition_removed
		)
	)
	assert_called_count(
		condition_node_stub.handle_disconnect_to_element.bind(
			dialogue_starting_step_graph_node,
			0
		),
		1
	)


func test_dialogue_starting_step_graph_node_does_nothing_on_condition_disconnection_if_condition_not_connected() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_condition_disconnection(
		condition_node_stub
	)
	assert_false(
		condition_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_condition_removed
		)
	)
	assert_called_count(
		condition_node_stub.handle_disconnect_to_element.bind(
			dialogue_starting_step_graph_node,
			0
		),
		0
	)


func test_dialogue_starting_step_graph_node_can_handle_condition_removal_on_node_deletion() -> void:
	starter_step_data_stub.enable_conditions.push_back(
		condition_node_stub.condition_data
	)
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_condition_connection(
		condition_node_stub
	)
	assert_true(
		starter_step_data_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)
	condition_node_stub.delete_called.emit(
		condition_node_stub.condition_data
	)
	assert_false(
		starter_step_data_stub.enable_conditions.has(
			condition_node_stub.condition_data
		)
	)


#endregion

#region dialogue step connection tests

func test_dialogue_starting_step_graph_node_can_handle_existing_dialogue_step_connection() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_step_connection(
		dialogue_step_node_stub
	)
	assert_true(
		dialogue_step_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_dialogue_step_delete_called
		)
	)
	assert_signal_emit_count(
		dialogue_starting_step_graph_node.connect_ports_requested,
		1
	)
	assert_signal_emitted_with_parameters(
		dialogue_starting_step_graph_node.connect_ports_requested,
		[
			dialogue_starting_step_graph_node.name,
			0,
			dialogue_step_node_stub.name,
			0
		]
	)
	assert_eq(
		dialogue_starting_step_graph_node.dialogue_step,
		dialogue_step_node_stub
	)


func test_dialogue_starting_step_graph_node_can_handle_new_dialogue_step_connection() -> void:
	starter_step_data_stub.step_id = -1
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	assert_false(
		starter_step_data_stub.step_id ==
		dialogue_step_node_stub.step_data.unique_id
	)
	dialogue_starting_step_graph_node.handle_step_connection(
		dialogue_step_node_stub,
		true
	)
	assert_true(
		dialogue_step_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_dialogue_step_delete_called
		)
	)
	assert_signal_emit_count(
		dialogue_starting_step_graph_node.connect_ports_requested,
		1
	)
	assert_signal_emitted_with_parameters(
		dialogue_starting_step_graph_node.connect_ports_requested,
		[
			dialogue_starting_step_graph_node.name,
			0,
			dialogue_step_node_stub.name,
			0
		]
	)
	assert_eq(
		dialogue_starting_step_graph_node.dialogue_step,
		dialogue_step_node_stub
	)


func test_dialogue_starting_step_graph_node_does_nothing_on_dialogue_step_connection_if_doesnt_have_step_and_not_new() -> void:
	starter_step_data_stub.step_id = -1
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_step_connection(
		dialogue_step_node_stub
	)
	assert_false(
		dialogue_step_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_dialogue_step_delete_called	
		)
	)
	assert_signal_emit_count(
		dialogue_starting_step_graph_node.connect_ports_requested,
		0
	)
	assert_null(
		dialogue_starting_step_graph_node.dialogue_step
	)


func test_dialogue_starting_step_graph_node_can_handle_multiple_different_dialogue_step_connections() -> void:
	var another_dialogue_step_node_stub: HFDiagEditDialogueStepNode = double(
		HFDiagEditDialogueStepNode
	).new()
	another_dialogue_step_node_stub.step_data = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	
	dialogue_starting_step_graph_node.handle_step_connection(
		dialogue_step_node_stub
	)
	assert_eq(
		dialogue_starting_step_graph_node.dialogue_step,
		dialogue_step_node_stub
	)
	dialogue_starting_step_graph_node.handle_step_connection(
		another_dialogue_step_node_stub,
		true
	)
	assert_eq(
		dialogue_starting_step_graph_node.dialogue_step,
		another_dialogue_step_node_stub
	)
	assert_false(
		dialogue_step_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_dialogue_step_delete_called
		)
	)
	assert_true(
		another_dialogue_step_node_stub.delete_called.is_connected(
			dialogue_starting_step_graph_node._on_dialogue_step_delete_called
		)
	)


func test_dialogue_starting_step_graph_node_can_handle_dialogue_step_delete_called() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_step_connection(
		dialogue_step_node_stub
	)
	assert_eq(
		dialogue_starting_step_graph_node.dialogue_step,
		dialogue_step_node_stub
	)
	assert_eq(
		starter_step_data_stub.step_id,
		dialogue_step_node_stub.step_data.unique_id
	)
	
	dialogue_step_node_stub.delete_called.emit(
		dialogue_step_node_stub.step_data
	)
	
	assert_null(
		dialogue_starting_step_graph_node.dialogue_step
	)
	assert_eq(
		starter_step_data_stub.step_id,
		-1
	)

#endregion

#region generic connection and disconnection tests

func test_dialogue_starting_step_graph_node_can_handle_generic_connection_to_dialogue_step_node() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_connection(
		0,
		dialogue_step_node_stub,
		0
	)
	assert_eq(
		dialogue_starting_step_graph_node.dialogue_step,
		dialogue_step_node_stub
	)


func test_dialogue_starting_step_graph_node_ignores_multiple_calls_to_generic_connection_with_same_dialogue_step_node() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_connection(
		0,
		dialogue_step_node_stub,
		0
	)
	assert_eq(
		dialogue_starting_step_graph_node.dialogue_step,
		dialogue_step_node_stub
	)
	
	dialogue_starting_step_graph_node.handle_connection(
		0,
		dialogue_step_node_stub,
		0
	)
	assert_eq(
		dialogue_starting_step_graph_node.dialogue_step,
		dialogue_step_node_stub
	)
	assert_signal_emit_count(
		dialogue_starting_step_graph_node.connect_ports_requested,
		1
	)


func test_dialogue_starting_step_graph_node_can_handle_generic_disconnection_from_dialogue_step_node() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_connection(
		0,
		dialogue_step_node_stub,
		0
	)
	assert_eq(
		dialogue_starting_step_graph_node.dialogue_step,
		dialogue_step_node_stub
	)
	assert_signal_emit_count(
		dialogue_starting_step_graph_node.connect_ports_requested,
		1
	)
	dialogue_starting_step_graph_node.handle_disconnection(
		0,
		dialogue_step_node_stub,
		0
	)
	assert_null(
		dialogue_starting_step_graph_node.dialogue_step
	)
	assert_signal_emit_count(
		dialogue_starting_step_graph_node.disconnect_ports_requested,
		1
	)


func test_dialogue_starting_step_graph_node_can_handle_generic_disconnection_without_to_node() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_connection(
		0,
		dialogue_step_node_stub,
		0
	)
	assert_eq(
		dialogue_starting_step_graph_node.dialogue_step,
		dialogue_step_node_stub
	)
	assert_signal_emit_count(
		dialogue_starting_step_graph_node.connect_ports_requested,
		1
	)
	dialogue_starting_step_graph_node.handle_disconnection(
		0
	)
	assert_null(
		dialogue_starting_step_graph_node.dialogue_step
	)
	assert_signal_emit_count(
		dialogue_starting_step_graph_node.disconnect_ports_requested,
		1
	)

#endregion

#region deletion tests

func test_dialogue_starting_step_graph_node_can_handle_deletion() -> void:
	dialogue_starting_step_graph_node.setup(starter_step_data_stub)
	dialogue_starting_step_graph_node.handle_delete()
	assert_signal_emit_count(
		dialogue_starting_step_graph_node.delete_called,
		1
	)
	assert_signal_emitted_with_parameters(
		dialogue_starting_step_graph_node.delete_called,
		[
			starter_step_data_stub
		]
	)

#endregion
