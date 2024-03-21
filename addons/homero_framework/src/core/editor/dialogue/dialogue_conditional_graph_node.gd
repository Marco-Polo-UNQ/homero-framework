@tool
class_name HFDiagEditConditionalNode
extends GraphNode

signal delete_called(condition_node: GraphNode)

var condition: HFEventConditional


func _init() -> void:
	node_selected.connect(_on_node_selected)


func _on_node_selected() -> void:
	EditorInterface.edit_resource(condition)


func setup(condition_data: HFEventConditional) -> void:
	condition = condition_data
	title = condition_data.get_resource_class()


func handle_connection(
	to_node: GraphNode,
	from_port: int,
	to_port: int
) -> bool:
	return false


func _on_delete_button_pressed() -> void:
	delete_called.emit(self)
