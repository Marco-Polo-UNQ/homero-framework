extends GutTest

const DIALOGUE_EVENT_GRAPH_NODE_SCENE: PackedScene = \
	preload("res://addons/homero_framework/src/core/editor/dialogue/dialogue_event_graph_node.tscn")

var dialogue_event_graph_node: HFDiagEditDialogueEventNode

var event_data_stub: HFEventTriggerGroup


func before_each() -> void:
	event_data_stub = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)

	dialogue_event_graph_node = DIALOGUE_EVENT_GRAPH_NODE_SCENE.instantiate() as HFDiagEditDialogueEventNode
	add_child_autoqfree(dialogue_event_graph_node)
	watch_signals(dialogue_event_graph_node)


func test_dialogue_event_graph_node_exists() -> void:
	assert_not_null(dialogue_event_graph_node)


func test_dialogue_event_graph_node_init_connects_signal() -> void:
	assert_true(
		dialogue_event_graph_node.node_selected.is_connected(
			dialogue_event_graph_node._on_node_selected
		)
	)


func test_dialogue_event_graph_node_ready_connects_signal() -> void:
	assert_true(
		dialogue_event_graph_node.position_offset_changed.is_connected(
			dialogue_event_graph_node._on_position_offset_changed
		)
	)


func test_dialogue_event_graph_node_setup_sets_event_data() -> void:
	dialogue_event_graph_node.setup(event_data_stub)
	assert_eq(dialogue_event_graph_node.event_data, event_data_stub)


func test_dialogue_event_graph_node_handle_delete_emits_signal() -> void:
	dialogue_event_graph_node.setup(event_data_stub)
	dialogue_event_graph_node.handle_delete()
	assert_signal_emit_count(
		dialogue_event_graph_node.delete_called,
		1
	)
	assert_signal_emitted_with_parameters(
		dialogue_event_graph_node.delete_called,
		[event_data_stub]
	)


func test_dialogue_event_graph_node_position_offset_changed_updates_event_data() -> void:
	assert_true(
		dialogue_event_graph_node.position_offset_changed.is_connected(
			dialogue_event_graph_node._on_position_offset_changed
		)
	)
	dialogue_event_graph_node.setup(event_data_stub)
	assert_eq(
		event_data_stub.graph_position,
		Vector2.ZERO
	)
	var new_position: Vector2 = Vector2(100, 200)
	dialogue_event_graph_node.position_offset = new_position
	assert_eq(
		dialogue_event_graph_node.event_data.graph_position,
		new_position
	)
	assert_signal_emitted(
		dialogue_event_graph_node.position_offset_changed
	)


func test_dialogue_conditional_graph_node_on_node_selected_edits_resource() -> void:
	dialogue_event_graph_node.setup(event_data_stub)
	dialogue_event_graph_node.node_selected.emit()
	# Because EditorInterface methods only exist in Editor.is_editor_hint() context.
	assert_engine_error(
		"Invalid call. Nonexistent function 'edit_resource' in base 'EditorInterface'."
	)
	assert_engine_error_count(1)
