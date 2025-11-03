extends GutTest

const SPEAKER_GRAPH_NODE_SCENE: PackedScene = \
	preload("res://addons/homero_framework/src/core/editor/dialogue/speaker_graph_node.tscn")

var speaker_graph_node: HFDiagEditSpeakerNode
var speaker_resource: HFDialogueSpeaker

func before_each() -> void:
	speaker_resource = double(HFDialogueSpeaker).new(
		null,
		Vector2.ZERO
	)
	speaker_graph_node = SPEAKER_GRAPH_NODE_SCENE.instantiate()
	add_child_autoqfree(speaker_graph_node)
	watch_signals(speaker_graph_node)


func test_speaker_graph_node_exists() -> void:
	assert_not_null(speaker_graph_node)


func test_speaker_graph_node_node_selected_connected_in_init() -> void:
	assert_true(
		speaker_graph_node.node_selected.is_connected(
			speaker_graph_node._on_node_selected
		)
	)


func test_speaker_graph_node_position_offset_changed_connected_in_ready() -> void:
	assert_true(
		speaker_graph_node.position_offset_changed.is_connected(
			speaker_graph_node._on_position_offset_changed
		)
	)


func test_speaker_graph_node_setup_assigns_speaker_data() -> void:
	speaker_graph_node.setup(speaker_resource)
	assert_eq(speaker_graph_node.speaker_data, speaker_resource)


func test_speaker_graph_node_position_offset_changed_updates_speaker_data_graph_position() -> void:
	speaker_graph_node.setup(speaker_resource)
	var new_position: Vector2 = Vector2(30, 40)
	speaker_graph_node.position_offset = new_position
	assert_eq(speaker_resource.graph_position, new_position)


func test_speaker_graph_node_handle_delete_emits_delete_called_with_speaker_data() -> void:
	speaker_graph_node.setup(speaker_resource)
	speaker_graph_node.handle_delete()
	assert_signal_emit_count(speaker_graph_node.delete_called, 1)
	assert_signal_emitted_with_parameters(speaker_graph_node.delete_called, [speaker_resource])


func test_speaker_graph_node_on_node_selected_attempts_to_edit_speaker_data_resource_in_editor() -> void:
	speaker_graph_node.setup(speaker_resource)
	speaker_graph_node.node_selected.emit()
	assert_engine_error(
		"Invalid call. Nonexistent function 'edit_resource' in base 'EditorInterface'."
	)
