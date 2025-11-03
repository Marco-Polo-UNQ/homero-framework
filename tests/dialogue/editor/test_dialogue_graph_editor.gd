extends GutTest

const DIALOGUE_GRAPH_EDITOR_SCENE: PackedScene = \
	preload("res://addons/homero_framework/src/core/editor/dialogue/dialogue_graph_editor.tscn")

var dialogue_graph_editor: Control

var dialogue_sequence_stub: HFDialogueSequence


func before_each() -> void:
	dialogue_sequence_stub = double(HFDialogueSequence).new(
		[] as Array[HFDialogueStarterStep],
		[] as Array[HFDialogueStep],
		false
	)

	dialogue_graph_editor = DIALOGUE_GRAPH_EDITOR_SCENE.instantiate()
	add_child_autoqfree(dialogue_graph_editor)
	await gut.get_tree().physics_frame


#region Initialization Tests

func test_dialogue_graph_editor_exists() -> void:
	assert_not_null(dialogue_graph_editor)


func test_dialogue_graph_editor_initializes_correctly() -> void:
	assert_true(dialogue_graph_editor.is_visible_in_tree())
	assert_not_null(dialogue_graph_editor.new_graph_node_popup)
	assert_not_null(dialogue_graph_editor.main_graph)
	assert_not_null(dialogue_graph_editor.resource_path_label)


func test_dialogue_graph_editor_setups_empty_dialogue_sequence() -> void:
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	await gut.get_tree().physics_frame
	assert_eq(dialogue_graph_editor.dialogue_sequence, dialogue_sequence_stub)
	assert_eq(
		dialogue_graph_editor.resource_path_label.text,
		"Editing %s" % dialogue_sequence_stub.resource_path
	)
	assert_eq(
		dialogue_graph_editor.main_graph.get_child_count(),
		1,
		"Main graph should have only one node for connection layer."
	)


func test_dialogue_graph_editor_setups_dialogue_sequence_with_dialogue_steps() -> void:
	var option_conditional_stub: HFEventConditional = double(HFEventConditional).new(
		Vector2.ZERO
	)
	var option_events_stub: HFEventTriggerGroup = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)
	var dialogue_option_stub: HFDialogueOption = double(HFDialogueOption).new(
		&"",
		1,
		[option_conditional_stub] as Array[HFEventConditional],
		option_events_stub,
		Vector2.ZERO
	)
	var dialogue_speaker_stub: HFDialogueSpeaker = double(HFDialogueSpeaker).new(
		null,
		Vector2.ZERO
	)
	var dialogue_events_stub: HFEventTriggerGroup = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)
	var dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		-1,
		dialogue_speaker_stub,
		[dialogue_option_stub] as Array[HFDialogueOption],
		dialogue_events_stub,
		Vector2.ZERO
	)

	var another_option_conditional_stub: HFEventConditional = double(HFEventConditional).new(
		Vector2.ZERO
	)
	var another_option_events_stub: HFEventTriggerGroup = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)
	var another_dialogue_option_stub: HFDialogueOption = double(HFDialogueOption).new(
		&"",
		1,
		[another_option_conditional_stub] as Array[HFEventConditional],
		another_option_events_stub,
		Vector2.ZERO
	)
	var another_dialogue_speaker_stub: HFDialogueSpeaker = double(HFDialogueSpeaker).new(
		null,
		Vector2.ZERO
	)
	var another_dialogue_events_stub: HFEventTriggerGroup = double(HFEventTriggerGroup).new(
		PackedStringArray([]),
		PackedStringArray([]),
		Vector2.ZERO
	)
	var another_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		2,
		another_dialogue_speaker_stub,
		[another_dialogue_option_stub] as Array[HFDialogueOption],
		another_dialogue_events_stub,
		Vector2.ZERO
	)
	var once_another_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		2,
		&"",
		-1,
		dialogue_speaker_stub,
		[dialogue_option_stub] as Array[HFDialogueOption],
		dialogue_events_stub,
		Vector2.ZERO
	)

	dialogue_sequence_stub.dialogue_steps.push_back(dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(another_dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(once_another_dialogue_step_stub)

	dialogue_graph_editor.setup(dialogue_sequence_stub)
	await gut.get_tree().physics_frame
	assert_eq(dialogue_graph_editor.dialogue_sequence, dialogue_sequence_stub)
	assert_eq(
		dialogue_graph_editor.resource_path_label.text,
		"Editing %s" % dialogue_sequence_stub.resource_path
	)
	assert_eq(
		dialogue_graph_editor.main_graph.get_child_count(),
		14,
		"Main graph should have 14 nodes, one for connection layer, the other 13 for the components associated with the step."
	)
	for child in dialogue_graph_editor.main_graph.get_children():
		if child.name == "_connection_layer":
			continue
		assert_true(
			(
				child is HFDiagEditDialogueStepNode ||
				child is HFDiagEditSpeakerNode ||
				child is HFDiagEditDialogueOptionNode ||
				child is HFDiagEditConditionalNode ||
				child is HFDiagEditDialogueEventNode
			) && (
				"step_data" in child && child.step_data in [
					dialogue_step_stub,
					another_dialogue_step_stub,
					once_another_dialogue_step_stub
				] ||
				"speaker_data" in child && child.speaker_data in [
					dialogue_speaker_stub,
					another_dialogue_speaker_stub
				] ||
				"option_data" in child && child.option_data in [
					dialogue_option_stub,
					another_dialogue_option_stub
				] ||
				"condition_data" in child && child.condition_data in [
					option_conditional_stub,
					another_option_conditional_stub
				] ||
				"event_data" in child && child.event_data in [
					dialogue_events_stub,
					option_events_stub,
					another_dialogue_events_stub,
					another_option_events_stub
				]
			)
		)


func test_dialogue_graph_editor_setups_dialogue_starting_steps() -> void:
	var dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var starting_step_conditional_stub: HFEventConditional = double(HFEventConditional).new(
		Vector2.ZERO
	)
	var starting_step_stub: HFDialogueStarterStep = double(HFDialogueStarterStep).new(
		0,
		[starting_step_conditional_stub] as Array[HFEventConditional],
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(dialogue_step_stub)
	dialogue_sequence_stub.starting_steps.push_back(starting_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	assert_eq(
		dialogue_graph_editor.main_graph.get_child_count(),
		4,
		"Main graph should have 2 nodes, one for connection layer, the other 3 for the starting step, starting step conditional and dialogue step."
	)
	for child in dialogue_graph_editor.main_graph.get_children():
		if child.name == "_connection_layer":
			continue
		assert_true(
			(
				child is HFDiagEditStartingStepNode ||
				child is HFDiagEditDialogueStepNode ||
				child is HFDiagEditConditionalNode
			) && (
				"starter_step_data" in child && child.starter_step_data == starting_step_stub ||
				"step_data" in child && child.step_data == dialogue_step_stub ||
				"condition_data" in child && child.condition_data == starting_step_conditional_stub
			)
		)


func test_dialogue_graph_editor_clears_previous_graph_on_setup() -> void:
	var dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(dialogue_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	assert_eq(
		dialogue_graph_editor.main_graph.get_child_count(),
		2,
		"Main graph should have 2 nodes, one for connection layer, the other 1 for the dialogue step."
	)
	var old_dialogue_step_graph_node: HFDiagEditDialogueStepNode
	for child in dialogue_graph_editor.main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			old_dialogue_step_graph_node = child
			break
	assert_true(
		is_instance_valid(old_dialogue_step_graph_node),
		"Old dialogue step graph node should be valid before setup call."
	)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	await gut.get_tree().physics_frame
	assert_eq(
		dialogue_graph_editor.main_graph.get_child_count(),
		2,
		"Main graph should have 2 nodes, one for connection layer, the other 1 for the dialogue step."
	)
	assert_false(
		is_instance_valid(old_dialogue_step_graph_node),
		"Old dialogue step graph node should be freed on setup call."
	)
	var new_dialogue_step_graph_node: HFDiagEditDialogueStepNode
	for child in dialogue_graph_editor.main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			new_dialogue_step_graph_node = child
			break
	assert_not_same(
		old_dialogue_step_graph_node,
		new_dialogue_step_graph_node,
		"New dialogue step graph node should be a different instance after setup call."
	)
	assert_true(
		is_instance_valid(new_dialogue_step_graph_node),
		"New dialogue step graph node should be valid after setup call."
	)

#endregion

#region Connection and Disconnection Request Handling Tests

func test_dialogue_graph_editor_can_handle_main_graph_connection_request_between_nodes() -> void:
	var from_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var to_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(from_dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(to_dialogue_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var from_node: HFDiagEditDialogueStepNode
	var to_node: HFDiagEditDialogueStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			if child.step_data == from_dialogue_step_stub:
				from_node = child
			elif child.step_data == to_dialogue_step_stub:
				to_node = child
	main_graph.connection_request.emit(
		from_node.name,
		0,
		to_node.name,
		0
	)
	assert_true(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should be connected to to node after connection request."
	)


func test_dialogue_graph_editor_can_handle_main_graph_connection_request_on_an_empty_graph_or_inexistent_node() -> void:
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	main_graph.connection_request.emit(
		&"doesnt_exist",
		0,
		&"neither_exists",
		0
	)
	assert_push_error(
		"From Node doesnt_exist or To Node neither_exists do not exist in main graph."
	)


func test_dialogue_graph_editor_can_handle_main_graph_disconnection_request_between_nodes() -> void:
	var from_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var to_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(from_dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(to_dialogue_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var from_node: HFDiagEditDialogueStepNode
	var to_node: HFDiagEditDialogueStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			if child.step_data == from_dialogue_step_stub:
				from_node = child
			elif child.step_data == to_dialogue_step_stub:
				to_node = child
	assert_true(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should be connected to to node before disconnection request."
	)
	main_graph.disconnection_request.emit(
		from_node.name,
		0,
		to_node.name,
		0
	)
	assert_false(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should not be connected to to node after disconnection request."
	)


func test_dialogue_graph_editor_can_handle_main_graph_disconnection_request_on_an_empty_graph_or_inexistent_node() -> void:
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	main_graph.disconnection_request.emit(
		&"doesnt_exist",
		0,
		&"neither_exists",
		0
	)
	assert_push_error(
		"From Node doesnt_exist or To Node neither_exists do not exist in main graph."
	)


func test_dialogue_graph_editor_can_handle_main_graph_connection_to_empty_between_nodes() -> void:
	var from_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var to_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(from_dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(to_dialogue_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var from_node: HFDiagEditDialogueStepNode
	var to_node: HFDiagEditDialogueStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			if child.step_data == from_dialogue_step_stub:
				from_node = child
			elif child.step_data == to_dialogue_step_stub:
				to_node = child
	assert_true(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should be connected to to node before disconnection request."
	)
	main_graph.connection_to_empty.emit(
		from_node.name,
		0,
		Vector2.ZERO
	)
	var node_connections: Array[Dictionary] = main_graph.get_connection_list_from_node(from_node.name)
	assert_true(
		node_connections.is_empty(),
		"From node should not_have_any_connections."
	)


func test_dialogue_graph_editor_can_handle_main_graph_connection_to_empty_on_an_empty_graph() -> void:
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	main_graph.connection_to_empty.emit(
		&"doesnt_exist",
		0,
		Vector2.ZERO
	)
	assert_push_error(
		"From Node doesnt_exist do not exist in main graph."
	)


func test_dialogue_graph_editor_can_handle_node_connect_ports_request_between_nodes() -> void:
	var from_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var to_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(from_dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(to_dialogue_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var from_node: HFDiagEditDialogueStepNode
	var to_node: HFDiagEditDialogueStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			if child.step_data == from_dialogue_step_stub:
				from_node = child
			elif child.step_data == to_dialogue_step_stub:
				to_node = child
	from_node.connect_ports_requested.emit(
		from_node.name,
		0,
		to_node.name,
		0
	)
	assert_true(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should be connected to to node after connect ports request."
	)


func test_dialogue_graph_editor_can_handle_node_connect_ports_request_on_an_inexistent_from_or_to_node() -> void:
	var from_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(from_dialogue_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var from_node: HFDiagEditDialogueStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			if child.step_data == from_dialogue_step_stub:
				from_node = child
	from_node.connect_ports_requested.emit(
		&"inexistent",
		0,
		&"inexistent",
		0
	)
	assert_push_error(
		"From Node inexistent or To Node inexistent do not exist in main graph."
	)


func test_dialogue_graph_editor_can_handle_node_connect_ports_request_disconnecting_from_previous() -> void:
	var from_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var to_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var another_to_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		2,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(from_dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(to_dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(another_to_dialogue_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var from_node: HFDiagEditDialogueStepNode
	var to_node: HFDiagEditDialogueStepNode
	var another_to_node: HFDiagEditDialogueStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			if child.step_data == from_dialogue_step_stub:
				from_node = child
			elif child.step_data == to_dialogue_step_stub:
				to_node = child
			elif child.step_data == another_to_dialogue_step_stub:
				another_to_node = child
	assert_true(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should be connected to to node to start."
	)
	assert_false(
		main_graph.is_node_connected(
			from_node.name,
			0,
			another_to_node.name,
			0
		),
		"From node should not be connected to another to node to start."
	)
	from_node.connect_ports_requested.emit(
		from_node.name,
		0,
		another_to_node.name,
		0
	)
	assert_false(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should not be connected to to node after"
	)
	assert_true(
		main_graph.is_node_connected(
			from_node.name,
			0,
			another_to_node.name,
			0
		),
		"From node should be connected to another to node after"
	)


func test_dialogue_graph_editor_can_handle_node_disconnect_ports_request() -> void:
	var from_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var to_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(from_dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(to_dialogue_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var from_node: HFDiagEditDialogueStepNode
	var to_node: HFDiagEditDialogueStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			if child.step_data == from_dialogue_step_stub:
				from_node = child
			elif child.step_data == to_dialogue_step_stub:
				to_node = child
	assert_true(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should be connected to to node before disconnect ports request."
	)
	from_node.disconnect_ports_requested.emit(
		from_node.name,
		0,
		to_node.name,
		0
	)
	assert_false(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should not be connected to to node after disconnect ports request."
	)


func test_dialogue_graph_editor_can_handle_node_disconnect_ports_request_on_an_inexistent_from_node() -> void:
	var from_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(from_dialogue_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var from_node: HFDiagEditDialogueStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			if child.step_data == from_dialogue_step_stub:
				from_node = child
	from_node.disconnect_ports_requested.emit(
		&"inexistent",
		0,
		&"inexistent",
		0
	)
	assert_push_error(
		"From Node inexistent does not exist in main graph."
	)


func test_dialogue_graph_editor_can_handle_node_disconnect_ports_request_even_if_to_node_does_not_exist() -> void:
	var from_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var to_dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(from_dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(to_dialogue_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var from_node: HFDiagEditDialogueStepNode
	var to_node: HFDiagEditDialogueStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			if child.step_data == from_dialogue_step_stub:
				from_node = child
			elif child.step_data == to_dialogue_step_stub:
				to_node = child
	assert_true(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should be connected to to node before disconnect ports request."
	)
	from_node.disconnect_ports_requested.emit(
		from_node.name,
		0,
		&"neither_exists",
		0
	)
	assert_false(
		main_graph.is_node_connected(
			from_node.name,
			0,
			to_node.name,
			0
		),
		"From node should not be connected to to node after disconnect ports request."
	)

#endregion

#region Tests Graph Delete nodes

func test_dialogue_graph_editor_can_handle_main_graph_delete_nodes_request() -> void:
	var dialogue_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		0,
		&"",
		1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var another_step_stub: HFDialogueStep = double(HFDialogueStep).new(
		1,
		&"",
		-1,
		null,
		[] as Array[HFDialogueOption],
		null,
		Vector2.ZERO
	)
	var dialogue_starter_step_stub: HFDialogueStarterStep = double(HFDialogueStarterStep).new(
		0,
		[] as Array[HFEventConditional],
		Vector2.ZERO
	)
	dialogue_sequence_stub.dialogue_steps.push_back(dialogue_step_stub)
	dialogue_sequence_stub.dialogue_steps.push_back(another_step_stub)
	dialogue_sequence_stub.starting_steps.push_back(dialogue_starter_step_stub)
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var dialogue_step_node: HFDiagEditDialogueStepNode
	var another_step_node: HFDiagEditDialogueStepNode
	var dialogue_starter_step_node: HFDiagEditStartingStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			if child.step_data == dialogue_step_stub:
				dialogue_step_node = child
			elif child.step_data == another_step_stub:
				another_step_node = child
		elif child is HFDiagEditStartingStepNode:
			if child.starter_step_data == dialogue_starter_step_stub:
				dialogue_starter_step_node = child
	assert_true(
		is_instance_valid(dialogue_step_node),
		"Dialogue step node should be valid before delete node request."
	)
	assert_true(
		main_graph.is_node_connected(
			dialogue_step_node.name,
			0,
			another_step_node.name,
			0
		),
		"Dialogue step node should be connected to another step node before delete node request."
	)
	main_graph.delete_nodes_request.emit(
		[
			StringName(dialogue_step_node.name),
			StringName(dialogue_starter_step_node.name)
		] as Array[StringName]
	)
	assert_true(
		dialogue_step_node.is_queued_for_deletion(),
		"Dialogue step node should not be valid after delete node request."
	)
	assert_true(
		dialogue_starter_step_node.is_queued_for_deletion(),
		"Dialogue starter step node should not be valid after delete node request."
	)
	assert_true(
		is_instance_valid(another_step_node),
		"Another step node should still be valid after delete node request."
	)
	assert_false(
		main_graph.is_node_connected(
			dialogue_step_node.name,
			0,
			another_step_node.name,
			0
		),
		"Dialogue step node should not be connected to another step node after delete node request."
	)
	assert_false(
		dialogue_sequence_stub.dialogue_steps.has(dialogue_step_stub),
		"Dialogue step stub should be removed from dialogue sequence after delete node request."
	)
	assert_false(
		dialogue_sequence_stub.starting_steps.has(dialogue_starter_step_stub),
		"Dialogue starter step stub should be removed from dialogue sequence after delete node request."
	)

#endregion

#region Tests Popup Requests

func test_dialogue_graph_editor_can_handle_main_graph_popup_request() -> void:
	dialogue_graph_editor.main_graph.popup_request.emit(
		Vector2(100, 100)
	)
	await gut.get_tree().physics_frame
	assert_true(
		dialogue_graph_editor.new_graph_node_popup.is_visible_in_tree(),
		"New graph node popup should be visible after popup request."
	)
	assert_eq(
		dialogue_graph_editor.new_graph_node_popup.position,
		Vector2(100, 100),
		"New graph node popup should be at the requested position after popup request."
	)


func test_dialogue_graph_editor_can_handle_new_graph_node_popup_new_starting_step_requested() -> void:
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	await gut.get_tree().physics_frame
	dialogue_graph_editor.new_graph_node_popup.new_starting_step_requested.emit()
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var starting_step_node: HFDiagEditStartingStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditStartingStepNode:
			starting_step_node = child
			break
	assert_true(
		is_instance_valid(starting_step_node),
		"Starting step node should be valid after new starting step requested."
	)
	assert_eq(
		dialogue_sequence_stub.starting_steps.size(),
		1,
		"Dialogue sequence should have one starting step after new starting step requested."
	)
	assert_true(
		dialogue_sequence_stub.starting_steps.has(starting_step_node.starter_step_data),
		"Dialogue sequence should have the starting step stub after new starting step requested."
	)	


func test_dialogue_graph_editor_can_handle_new_graph_node_popup_new_dialogue_step_requested() -> void:
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	await gut.get_tree().physics_frame
	dialogue_graph_editor.new_graph_node_popup.new_dialogue_step_requested.emit()
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var dialogue_step_node: HFDiagEditDialogueStepNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			dialogue_step_node = child
			break
	assert_true(
		is_instance_valid(dialogue_step_node),
		"Dialogue step node should be valid after new dialogue step requested."
	)
	assert_eq(
		dialogue_sequence_stub.dialogue_steps.size(),
		1,
		"Dialogue sequence should have one dialogue step after new dialogue step requested."
	)
	assert_true(
		dialogue_sequence_stub.dialogue_steps.has(dialogue_step_node.step_data),
		"Dialogue sequence should have the dialogue step stub after new dialogue step requested."
	)
	assert_eq(
		dialogue_step_node.step_data.unique_id,
		0,
		"Dialogue step stub should have step ID 0 after new dialogue step requested."
	)


func test_dialogue_graph_editor_can_handle_new_graph_node_popup_new_dialogue_step_requested_multiple_times() -> void:
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	await gut.get_tree().physics_frame
	for i in range(3):
		dialogue_graph_editor.new_graph_node_popup.new_dialogue_step_requested.emit()
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var dialogue_step_nodes: Array[HFDiagEditDialogueStepNode] = []
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueStepNode:
			dialogue_step_nodes.append(child)
	assert_eq(
		dialogue_step_nodes.size(),
		3,
		"Main graph should have three dialogue step nodes after three new dialogue step requested."
	)
	assert_eq(
		dialogue_sequence_stub.dialogue_steps.size(),
		3,
		"Dialogue sequence should have three dialogue steps after three new dialogue step requested."
	)
	for i in range(3):
		assert_true(
			dialogue_sequence_stub.dialogue_steps.has(dialogue_step_nodes[i].step_data),
			"Dialogue sequence should have the dialogue step stub after new dialogue step requested."
		)
		assert_eq(
			dialogue_step_nodes[i].step_data.unique_id,
			i,
			"Dialogue step stub should have correct step ID after new dialogue step requested."
		)


func test_dialogue_graph_editor_can_handle_new_graph_node_popup_new_dialogue_speaker_requested() -> void:
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	await gut.get_tree().physics_frame
	dialogue_graph_editor.new_graph_node_popup.new_dialogue_speaker_requested.emit()
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var dialogue_speaker_node: HFDiagEditSpeakerNode
	for child in main_graph.get_children():
		if child is HFDiagEditSpeakerNode:
			dialogue_speaker_node = child
			break
	assert_true(
		is_instance_valid(dialogue_speaker_node),
		"Dialogue speaker node should be valid after new dialogue speaker requested."
	)


func test_dialogue_graph_editor_can_handle_new_graph_node_popup_new_dialogue_option_requested() -> void:
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	await gut.get_tree().physics_frame
	dialogue_graph_editor.new_graph_node_popup.new_dialogue_option_requested.emit()
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var dialogue_option_node: HFDiagEditDialogueOptionNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueOptionNode:
			dialogue_option_node = child
			break
	assert_true(
		is_instance_valid(dialogue_option_node),
		"Dialogue option node should be valid after new dialogue option requested."
	)


func test_dialogue_graph_editor_can_handle_new_graph_node_popup_new_dialogue_event_requested() -> void:
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	await gut.get_tree().physics_frame
	dialogue_graph_editor.new_graph_node_popup.new_dialogue_event_requested.emit()
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var dialogue_event_node: HFDiagEditDialogueEventNode
	for child in main_graph.get_children():
		if child is HFDiagEditDialogueEventNode:
			dialogue_event_node = child
			break
	assert_true(
		is_instance_valid(dialogue_event_node),
		"Dialogue event node should be valid after new dialogue event requested."
	)


func test_dialogue_graph_editor_can_handle_new_graph_node_popup_new_conditional_requested() -> void:
	dialogue_graph_editor.setup(dialogue_sequence_stub)
	await gut.get_tree().physics_frame
	var conditional_data_stub: HFEventConditional = double(HFEventConditional).new(
		Vector2.ZERO
	)
	dialogue_graph_editor.new_graph_node_popup.new_dialogue_conditional_requested.emit(conditional_data_stub)
	var main_graph: GraphEdit = dialogue_graph_editor.main_graph
	var conditional_node: HFDiagEditConditionalNode
	for child in main_graph.get_children():
		if child is HFDiagEditConditionalNode:
			conditional_node = child
			break
	assert_true(
		is_instance_valid(conditional_node),
		"Conditional node should be valid after new conditional requested."
	)
	assert_eq(
		conditional_node.condition_data,
		conditional_data_stub,
		"Conditional node should have the correct conditional data after new conditional requested."
	)

#endregion
