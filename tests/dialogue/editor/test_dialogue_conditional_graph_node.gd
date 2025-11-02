extends GutTest

const DIALOGUE_CONDITIONAL_GRAPH_NODE_SCENE: PackedScene = preload("res://addons/homero_framework/src/core/editor/dialogue/dialogue_conditional_graph_node.tscn")
const DIALOGUE_OPTION_GRAPH_NODE_SCENE: PackedScene = preload("res://addons/homero_framework/src/core/editor/dialogue/dialogue_option_graph_node.tscn")

var dialogue_conditional_graph_node: HFDiagEditConditionalNode

var condition_data_stub: HFEventConditional
var element_connected_stub: GraphNode


func before_all() -> void:
	register_inner_classes(get_script())


func before_each() -> void:
	condition_data_stub = double(HFEventConditional).new()
	element_connected_stub = double(DIALOGUE_OPTION_GRAPH_NODE_SCENE).instantiate()
	add_child_autoqfree(element_connected_stub)

	dialogue_conditional_graph_node = DIALOGUE_CONDITIONAL_GRAPH_NODE_SCENE.instantiate()
	add_child_autoqfree(dialogue_conditional_graph_node)
	watch_signals(dialogue_conditional_graph_node)


func test_dialogue_conditional_graph_node_exists() -> void:
	assert_not_null(dialogue_conditional_graph_node)


func test_dialogue_conditional_graph_node_init_connects_signal() -> void:
	assert_true(
		dialogue_conditional_graph_node.node_selected.is_connected(
			dialogue_conditional_graph_node._on_node_selected
		)
	)


func test_dialogue_conditional_graph_node_ready_connects_signal() -> void:
	assert_true(
		dialogue_conditional_graph_node.position_offset_changed.is_connected(
			dialogue_conditional_graph_node._on_position_offset_changed
		)
	)


func test_dialogue_conditional_graph_node_changes_graph_position_on_position_offset_changed() -> void:
	dialogue_conditional_graph_node.condition_data = condition_data_stub
	assert_eq(
		condition_data_stub.graph_position,
		Vector2.ZERO
	)
	dialogue_conditional_graph_node.position_offset = Vector2(100, 200)
	assert_eq(
		dialogue_conditional_graph_node.condition_data.graph_position,
		Vector2(100, 200)
	)
	assert_signal_emit_count(
		dialogue_conditional_graph_node.position_offset_changed,
		1
	)


func test_dialogue_conditional_graph_node_on_node_selected_edits_resource() -> void:
	dialogue_conditional_graph_node.condition_data = condition_data_stub
	dialogue_conditional_graph_node.node_selected.emit()
	# Because EditorInterface methods only exist in Editor.is_editor_hint() context.
	assert_engine_error(
		"Invalid call. Nonexistent function 'edit_resource' in base 'EditorInterface'."
	)
	assert_engine_error_count(1)


func test_dialogue_conditional_graph_node_can_setup() -> void:
	condition_data_stub = HFConditionAllPass.new()
	dialogue_conditional_graph_node.setup(condition_data_stub)
	assert_eq(
		dialogue_conditional_graph_node.condition_data,
		condition_data_stub
	)
	assert_eq(
		dialogue_conditional_graph_node.title,
		"HFConditionAllPass"
	)


func test_dialogue_conditional_graph_node_handle_connect_to_element() -> void:
	dialogue_conditional_graph_node.handle_connect_to_element(
		element_connected_stub,
		1
	)
	assert_eq(
		dialogue_conditional_graph_node.element_connected,
		element_connected_stub
	)
	assert_signal_emit_count(
		dialogue_conditional_graph_node.connect_ports_requested,
		1
	)
	assert_signal_emitted_with_parameters(
		dialogue_conditional_graph_node.connect_ports_requested,
		[
			dialogue_conditional_graph_node.name,
			0,
			element_connected_stub.name,
			1
		]
	)


func test_dialogue_conditional_graph_node_handle_disconnect_to_element() -> void:
	dialogue_conditional_graph_node.element_connected = element_connected_stub
	dialogue_conditional_graph_node.handle_disconnect_to_element(
		element_connected_stub,
		1
	)
	assert_null(dialogue_conditional_graph_node.element_connected)
	assert_signal_emit_count(
		dialogue_conditional_graph_node.disconnect_ports_requested,
		1
	)
	assert_signal_emitted_with_parameters(
		dialogue_conditional_graph_node.disconnect_ports_requested,
		[
			dialogue_conditional_graph_node.name,
			0,
			element_connected_stub.name,
			1
		]
	)


func test_dialogue_conditional_graph_node_handle_connection() -> void:
	dialogue_conditional_graph_node.handle_connection(
		0,
		element_connected_stub,
		1
	)
	assert_called_count(
		element_connected_stub.handle_condition_connection.bind(
			dialogue_conditional_graph_node,
			true
		),
		1
	)


func test_dialogue_conditional_graph_node_handle_disconnection() -> void:
	dialogue_conditional_graph_node.element_connected = element_connected_stub
	dialogue_conditional_graph_node.handle_disconnection(0)
	assert_called_count(
		element_connected_stub.handle_condition_disconnection.bind(
			dialogue_conditional_graph_node
		),
		1
	)


func test_dialogue_conditional_graph_node_handle_delete() -> void:
	dialogue_conditional_graph_node.condition_data = condition_data_stub
	dialogue_conditional_graph_node.handle_delete()
	assert_signal_emit_count(
		dialogue_conditional_graph_node.delete_called,
		1
	)
	assert_signal_emitted_with_parameters(
		dialogue_conditional_graph_node.delete_called,
		[condition_data_stub]
	)
