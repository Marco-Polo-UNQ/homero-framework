@tool
class_name HFDiagEditDialogueEventNode
extends GraphNode

signal connect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal disconnect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal delete_called(event_data: HFEventTriggerGroup)

var event_data: HFEventTriggerGroup


func _ready() -> void:
	position_offset_changed.connect(
		func():
			event_data.graph_position = position_offset
	)


func _init() -> void:
	node_selected.connect(_on_node_selected)


func _on_node_selected() -> void:
	EditorInterface.edit_resource(event_data)


func setup(event_info: HFEventTriggerGroup) -> void:
	event_data = event_info


func handle_delete() -> void:
	delete_called.emit(event_data)
