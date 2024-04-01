@tool
class_name HFDiagEditConditionalNode
extends GraphNode

signal connect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal disconnect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal delete_called(condition_data: HFEventConditional)

var condition_data: HFEventConditional


func _ready() -> void:
	position_offset_changed.connect(
		func():
			condition_data.graph_position = position_offset
	)


func _init() -> void:
	node_selected.connect(_on_node_selected)


func _on_node_selected() -> void:
	EditorInterface.edit_resource(condition_data)


func setup(p_condition_data: HFEventConditional) -> void:
	condition_data = p_condition_data
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	var script: Script = condition_data.get_script() as Script
	for class_data: Dictionary in global_class_list:
		if class_data.path == script.resource_path:
			title = class_data.class
			break


var element_connected: GraphNode

func handle_connect_to_element(element: GraphNode, to_port: int) -> void:
	element_connected = element
	connect_ports_requested.emit(
		name,
		0,
		element.name,
		to_port
	)


func handle_disconnect_to_element(element: GraphNode, to_port: int) -> void:
	disconnect_ports_requested.emit(
		name,
		0,
		element.name,
		to_port
	)
	element_connected = null


func handle_connection(
	from_port: int,
	to_node: GraphNode,
	to_port: int
) -> void:
	to_node.handle_condition_connection(self, true)


func handle_disconnection(
	from_port: int,
	to_node: GraphNode = null,
	to_port: int = -1
) -> void:
	if element_connected != null:
		element_connected.handle_condition_disconnection(self)


func handle_delete() -> void:
	delete_called.emit(condition_data)
