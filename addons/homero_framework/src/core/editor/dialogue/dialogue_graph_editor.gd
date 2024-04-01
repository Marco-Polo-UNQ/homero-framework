@tool
extends Control

const starting_step_node_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_starting_step_graph_node.tscn"
)
const dialogue_step_node_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_step_graph_node.tscn"
)
const speaker_node_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/speaker_graph_node.tscn"
)
const option_node_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_option_graph_node.tscn"
)
const event_node_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_event_graph_node.tscn"
)
const conditional_node_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_conditional_graph_node.tscn"
)

@onready var new_graph_node_popup: Control = %NewGraphNodePopup
@onready var main_graph: GraphEdit = %MainGraph
@onready var resource_path_label: Label = %ResourcePathLabel

var dialogue_sequence: HFDialogueSequence


func setup(p_dialogue_sequence: HFDialogueSequence) -> void:
	dialogue_sequence = p_dialogue_sequence
	_cache_references()
	resource_path_label.text = "Editing %s" % dialogue_sequence.resource_path
	
	main_graph.clear_connections()
	for node: Node in main_graph.get_children():
		main_graph.remove_child(node)
		node.queue_free()
	
	var starting_steps: Array[HFDiagEditStartingStepNode] = []
	var dialogue_steps: Array[HFDiagEditDialogueStepNode] = []
	var speakers: Array[HFDiagEditSpeakerNode] = []
	var options: Array[HFDiagEditDialogueOptionNode] = []
	var events: Array[HFDiagEditDialogueEventNode] = []
	
	for dialogue_step: HFDialogueStep in dialogue_sequence.dialogue_steps:
		var step_node: HFDiagEditDialogueStepNode = _add_new_graph_node(
			dialogue_step_node_scene, dialogue_step
		) as HFDiagEditDialogueStepNode
		dialogue_steps.push_back(step_node)
		_initialize_dialogue_step(
			step_node,
			dialogue_steps,
			options,
			speakers,
			events
		)
	
	for starting_step: HFDialogueStarterStep in dialogue_sequence.starting_steps:
		var starting_node: HFDiagEditStartingStepNode = _add_new_graph_node(
			starting_step_node_scene, starting_step
		) as HFDiagEditStartingStepNode
		starting_steps.push_back(starting_node)
		
		for enable_condition: HFEventConditional in starting_step.enable_conditions:
			var condition_node: HFDiagEditConditionalNode = _add_new_graph_node(
				conditional_node_scene, enable_condition
			) as HFDiagEditConditionalNode
			starting_node.handle_condition_connection(condition_node)
		
		for step_node: HFDiagEditDialogueStepNode in dialogue_steps:
			starting_node.handle_step_connection(step_node)


func _initialize_dialogue_step(
	step_node: HFDiagEditDialogueStepNode,
	dialogue_steps: Array[HFDiagEditDialogueStepNode],
	options: Array[HFDiagEditDialogueOptionNode],
	speakers: Array[HFDiagEditSpeakerNode],
	events: Array[HFDiagEditDialogueEventNode]
) -> void:
	for option_data: HFDialogueOption in step_node.step_data.options:
		var option_node: HFDiagEditDialogueOptionNode = _get_existing_node(
			option_data,
			options,
			StringName("option_data")
		) as HFDiagEditDialogueOptionNode
		if option_node == null:
			option_node = _add_new_graph_node(
				option_node_scene, option_data
			) as HFDiagEditDialogueOptionNode
			options.push_back(option_node)
			
			for enable_condition: HFEventConditional in option_data.enable_conditions:
				var condition_node: HFDiagEditConditionalNode = _add_new_graph_node(
					conditional_node_scene, enable_condition
				) as HFDiagEditConditionalNode
				option_node.handle_condition_connection(condition_node)
			
			if option_data.option_events != null:
				_verify_link_and_connect(
					option_node,
					event_node_scene,
					option_data.option_events,
					events,
					StringName("event_data"),
					StringName("handle_event_connection")
				)
		
		step_node.handle_option_connection(option_node)
	
	if step_node.step_data.speaker != null:
		_verify_link_and_connect(
			step_node,
			speaker_node_scene,
			step_node.step_data.speaker,
			speakers,
			StringName("speaker_data"),
			StringName("handle_speaker_connection")
		)
	
	if step_node.step_data.dialogue_events != null:
		_verify_link_and_connect(
			step_node,
			event_node_scene,
			step_node.step_data.dialogue_events,
			events,
			StringName("event_data"),
			StringName("handle_event_connection")
		)
	
	for other_step: HFDiagEditDialogueStepNode in dialogue_steps:
		step_node.handle_step_connection(other_step)
		other_step.handle_step_connection(step_node)
		for option_node: HFDiagEditDialogueOptionNode in options:
			option_node.handle_step_connection(step_node)


func _verify_link_and_connect(
	base_node: GraphNode,
	node_scene: PackedScene,
	value_to_check,
	original_list: Array,
	property_to_check: StringName,
	connection_method: StringName
) -> void:
	var node_to_connect: GraphNode
	for existing_node: GraphNode in original_list:
		if existing_node.get(property_to_check) == value_to_check:
			node_to_connect = existing_node
			break
	if node_to_connect == null:
		node_to_connect = _add_new_graph_node(
			node_scene, value_to_check
		) as GraphNode
		original_list.push_back(node_to_connect)
	base_node.call(connection_method, node_to_connect)


func _get_existing_node(
	value_to_check,
	nodes_list: Array,
	property_to_check: StringName
) -> GraphNode:
	for existing_node: GraphNode in nodes_list:
		if existing_node.get(property_to_check) == value_to_check:
			return existing_node
	return null


func _cache_references() -> void:
	main_graph = %MainGraph
	resource_path_label = %ResourcePathLabel
	new_graph_node_popup = %NewGraphNodePopup


func _on_main_graph_connection_request(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
) -> void:
	print("_on_main_graph_connection_request from node %s port %s to node %s port %s" % [from_node, from_port, to_node, to_port])
	var from: GraphNode = main_graph.get_node(NodePath(from_node))
	var to: GraphNode = main_graph.get_node(NodePath(to_node))
	from.handle_connection(from_port, to, to_port)


func _on_main_graph_disconnection_request(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
) -> void:
	print("_on_main_graph_disconnection_request from node %s port %s to node %s port %s" % [from_node, from_port, to_node, to_port])
	var from: GraphNode = main_graph.get_node(NodePath(from_node))
	var to: GraphNode = main_graph.get_node(NodePath(to_node))
	from.handle_disconnection(from_port, to, to_port)
	main_graph.disconnect_node(
		from_node,
		from_port,
		to_node,
		to_port
	)


func _on_main_graph_connection_to_empty(
	from_node: StringName,
	from_port: int,
	release_position: Vector2
) -> void:
	print("_on_main_graph_connection_to_empty from node %s port %s position %s" % [from_node, from_port, release_position])
	var from: GraphNode = main_graph.get_node(NodePath(from_node))
	from.handle_disconnection(from_port)


func _on_connect_ports_requested(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int,
	disconnect_previous: bool = true
) -> void:
	if disconnect_previous:
		_disconnect_port_from(from_node, from_port)
	main_graph.connect_node(
		from_node,
		from_port,
		to_node,
		to_port
	)


func _on_disconnect_ports_requested(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
) -> void:
	if to_node.is_empty():
		_disconnect_port_from(from_node, from_port)
	else:
		main_graph.disconnect_node(
			from_node,
			from_port,
			to_node,
			to_port
	)


func _disconnect_port_from(node: String, port: int) -> void:
	var connections: Array[Dictionary] = main_graph.get_connection_list()
	for connection: Dictionary in connections:
		if connection.from_node == node && connection.from_port == port:
			main_graph.disconnect_node(
				node,
				port,
				connection.to_node,
				connection.to_port
			)


func _on_main_graph_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name: StringName in nodes:
		var node: GraphNode = main_graph.get_node(NodePath(node_name))
		node.handle_delete()
		
		var connections: Array[Dictionary] = main_graph.get_connection_list()
		for connection: Dictionary in connections:
			if connection.from_node == node_name:
				main_graph.disconnect_node(
					node_name,
					connection.from_port,
					connection.to_node,
					connection.to_port
				)
			elif connection.to_node == node_name:
				main_graph.disconnect_node(
					connection.to_node,
					connection.from_port,
					node_name,
					connection.to_port
				)
		
		if node is HFDiagEditStartingStepNode:
			dialogue_sequence.starting_steps.erase(node.starter_step_data)
		elif node is HFDiagEditDialogueStepNode:
			dialogue_sequence.dialogue_steps.erase(node.step_data)
		
		main_graph.remove_child(node)
		node.queue_free()


func _on_main_graph_popup_request(popup_position: Vector2) -> void:
	print("_on_main_graph_popup_request position %s" % popup_position)
	new_graph_node_popup.setup(popup_position)


func _on_new_graph_node_popup_new_starting_step_requested() -> void:
	var new_starting_step: HFDialogueStarterStep = HFDialogueStarterStep.new()
	_add_new_graph_node(
		starting_step_node_scene, new_starting_step, _get_graph_local_mouse_position()
	)
	dialogue_sequence.starting_steps.push_back(new_starting_step)


func _on_new_graph_node_popup_new_dialogue_step_requested() -> void:
	var new_step: HFDialogueStep = HFDialogueStep.new()
	_add_new_graph_node(
		dialogue_step_node_scene, new_step, _get_graph_local_mouse_position()
	)
	var index: int = -1
	var exists: bool = true
	while exists:
		index += 1
		exists = false
		for other_step: HFDialogueStep in dialogue_sequence.dialogue_steps:
			exists = exists || other_step.unique_id == index
	new_step.unique_id = index
	dialogue_sequence.dialogue_steps.push_back(new_step)


func _on_new_graph_node_popup_new_dialogue_speaker_requested() -> void:
	_add_new_graph_node(
		speaker_node_scene, HFDialogueSpeaker.new(), _get_graph_local_mouse_position()
	)


func _on_new_graph_node_popup_new_dialogue_option_requested() -> void:
	_add_new_graph_node(
		option_node_scene, HFDialogueOption.new(), _get_graph_local_mouse_position()
	)


func _on_new_graph_node_popup_new_dialogue_event_requested() -> void:
	_add_new_graph_node(
		event_node_scene, HFEventTriggerGroup.new(), _get_graph_local_mouse_position()
	)


func _on_new_graph_node_popup_new_dialogue_conditional_requested(conditional: HFEventConditional) -> void:
	_add_new_graph_node(
		conditional_node_scene, conditional, _get_graph_local_mouse_position()
	)


func _get_graph_local_mouse_position() -> Vector2:
	return (main_graph.get_local_mouse_position() + main_graph.scroll_offset) / main_graph.zoom


func _add_new_graph_node(
	node_scene: PackedScene,
	setup_data,
	starting_position = null
) -> GraphNode:
	var new_node: GraphNode = node_scene.instantiate() as GraphNode
	main_graph.add_child(new_node)
	new_node.setup(setup_data)
	new_node.connect_ports_requested.connect(_on_connect_ports_requested)
	new_node.disconnect_ports_requested.connect(_on_disconnect_ports_requested)
	if starting_position == null:
		starting_position = setup_data.graph_position
	new_node.position_offset = starting_position
	setup_data.graph_position = starting_position
	return new_node
