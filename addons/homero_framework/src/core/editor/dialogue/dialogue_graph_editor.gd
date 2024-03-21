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

var main_graph: GraphEdit
var resource_path_label: Label

var dialogue_sequence: HFDialogueSequence



func setup(p_dialogue_sequence: HFDialogueSequence) -> void:
	dialogue_sequence = p_dialogue_sequence
	_cache_references()
	resource_path_label.text = "Editing %s" % dialogue_sequence.resource_path
	
	for node: Node in main_graph.get_children():
		main_graph.remove_child(node)
		node.queue_free()
	
	var starting_steps: Array[GraphNode] = []
	
	for starting_step: HFDialogueStarterStep in dialogue_sequence.starting_steps:
		var starting_node: GraphNode = starting_step_node_scene.instantiate()
		main_graph.add_child(starting_node)
		starting_node.setup(starting_step)
		starting_steps.push_back(starting_node)
	
	var dialogue_steps: Array[GraphNode] = []
	var speakers: Array[GraphNode] = []
	
	for dialogue_step: HFDialogueStep in dialogue_sequence.dialogue_steps:
		var step_node: GraphNode = dialogue_step_node_scene.instantiate()
		main_graph.add_child(step_node)
		step_node.setup(dialogue_step)
		
		for starting_step_node: GraphNode in starting_steps:
			starting_step_node.handle_step_connection(step_node)
		
		for other_step_node: GraphNode in dialogue_steps:
			other_step_node.handle_step_connection(step_node)
			step_node.handle_step_connection(other_step_node)
		
		if dialogue_step.speaker != null:
			var speaker_node: GraphNode
			for existing_speaker: GraphNode in speakers:
				if existing_speaker.speaker_data == dialogue_step.speaker:
					speaker_node = existing_speaker
					break
			if speaker_node == null:
				speaker_node = speaker_node_scene.instantiate()
				main_graph.add_child(speaker_node)
				speaker_node.setup(dialogue_step.speaker)
				speakers.push_back(speaker_node)
			step_node.handle_speaker_connection(speaker_node)
		
		dialogue_steps.push_back(step_node)
	
	main_graph.arrange_nodes()


func _cache_references() -> void:
	main_graph = $MainGraph
	resource_path_label = $ResourcePathLabel


func _on_main_graph_connection_request(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
) -> void:
	print("_on_main_graph_connection_request from node %s port %s to node %s port %s" % [from_node, from_port, to_node, to_port])
	var from: GraphNode = main_graph.get_node(NodePath(from_node))
	var to: GraphNode = main_graph.get_node(NodePath(to_node))
	var can_connect: bool = from.handle_connection(to, from_port, to_port)
	if can_connect:
		_disconnect_port_from(from_node, from_port)
		main_graph.connect_node(
			from_node,
			from_port,
			to_node,
			to_port
		)


func _on_main_graph_disconnection_request(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
) -> void:
	print("_on_main_graph_disconnection_request from node %s port %s to node %s port %s" % [from_node, from_port, to_node, to_port])


func _on_main_graph_connection_to_empty(
	from_node: StringName,
	from_port: int,
	release_position: Vector2
) -> void:
	print("_on_main_graph_connection_to_empty from node %s port %s position %s" % [from_node, from_port, release_position])


func _on_main_graph_popup_request(popup_position: Vector2) -> void:
	print("_on_main_graph_popup_request position %s" % popup_position)


func _disconnect_port_from(node: String, port: int) -> void:
	var graph: GraphEdit = get_parent() as GraphEdit
	var connections: Array[Dictionary] = graph.get_connection_list()
	for connection: Dictionary in connections:
		if connection.from_node == node && connection.from_port == port:
			graph.disconnect_node(
				node,
				port,
				connection.to_node,
				connection.to_port
			)
