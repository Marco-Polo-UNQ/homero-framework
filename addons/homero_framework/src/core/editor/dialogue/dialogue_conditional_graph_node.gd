@tool
class_name HFDiagEditConditionalNode
extends GraphNode
## Graph node for editing dialogue conditionals in the dialogue editor.

## Emitted when a request to connect ports is made.
signal connect_ports_requested(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
)
## Emitted when a request to disconnect ports is made.
signal disconnect_ports_requested(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
)
## Emitted when this node requests deletion.
signal delete_called(condition_data: HFEventConditional)

## The conditional data resource represented by this node.
var condition_data: HFEventConditional

## The element this node is connected to.
var element_connected: GraphNode


## Sets up the node with the given conditional data.
func setup(p_condition_data: HFEventConditional) -> void:
	condition_data = p_condition_data
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	var script: Script = condition_data.get_script() as Script
	for class_data: Dictionary in global_class_list:
		if class_data.path == script.resource_path:
			title = class_data.class
			break


## Handles connecting this node to another element.
func handle_connect_to_element(element: GraphNode, to_port: int) -> void:
	element_connected = element
	connect_ports_requested.emit(
		name,
		0,
		element.name,
		to_port
	)


## Handles disconnecting this node from another element.
func handle_disconnect_to_element(element: GraphNode, to_port: int) -> void:
	disconnect_ports_requested.emit(
		name,
		0,
		element.name,
		to_port
	)
	element_connected = null


## Handles a connection from another node.
func handle_connection(
	from_port: int,
	to_node: GraphNode,
	to_port: int
) -> void:
	to_node.handle_condition_connection(self, true)


## Handles a disconnection from another node.
func handle_disconnection(
	_from_port: int,
	_to_node: GraphNode = null,
	_to_port: int = -1
) -> void:
	if element_connected != null:
		element_connected.handle_condition_disconnection(self)


## Handles the deletion call delegating to a signal call.
func handle_delete() -> void:
	delete_called.emit(condition_data)


func _ready() -> void:
	position_offset_changed.connect(_on_position_offset_changed)


func _init() -> void:
	node_selected.connect(_on_node_selected)


func _on_position_offset_changed() -> void:
	condition_data.graph_position = position_offset


func _on_node_selected() -> void:
	EditorInterface.edit_resource(condition_data)
