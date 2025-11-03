@tool
class_name HFDiagEditSpeakerNode
extends GraphNode
## Graph node for editing dialogue speakers in the dialogue editor.

## Emitted when a request to connect ports is made.
signal connect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
## Emitted when a request to disconnect ports is made.
signal disconnect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
## Emitted when this node is deleted.
signal delete_called(speaker_data: HFDialogueSpeaker)

## The speaker data resource represented by this node.
var speaker_data: HFDialogueSpeaker


## Sets up the node with the given speaker data.
func setup(speaker: HFDialogueSpeaker) -> void:
	speaker_data = speaker


## Handles deletion of this node.
func handle_delete() -> void:
	delete_called.emit(speaker_data)


func _ready() -> void:
	position_offset_changed.connect(_on_position_offset_changed)


func _on_position_offset_changed() -> void:
	speaker_data.graph_position = position_offset


func _init() -> void:
	node_selected.connect(_on_node_selected)


func _on_node_selected() -> void:
	EditorInterface.edit_resource(speaker_data)
