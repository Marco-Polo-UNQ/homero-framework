@tool
class_name HFDiagEditDialogueEventNode
extends GraphNode
## Graph node for editing dialogue event trigger groups in the dialogue editor.

## Emitted when a request to connect ports is made.
signal connect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
## Emitted when a request to disconnect ports is made.
signal disconnect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
## Emitted when this node requests deletion.
signal delete_called(event_data: HFEventTriggerGroup)

## The event trigger group data represented by this node.
var event_data: HFEventTriggerGroup


## Sets up the node with the given event trigger group data.
func setup(event_info: HFEventTriggerGroup) -> void:
	event_data = event_info


## Handles deletion of this node.
func handle_delete() -> void:
	delete_called.emit(event_data)


# Called when the node is added to the scene tree.
func _ready() -> void:
	position_offset_changed.connect(_on_position_offset_changed)


# Called when the node is initialized.
func _init() -> void:
	node_selected.connect(_on_node_selected)


func _on_position_offset_changed() -> void:
	event_data.graph_position = position_offset


func _on_node_selected() -> void:
	EditorInterface.edit_resource(event_data)
