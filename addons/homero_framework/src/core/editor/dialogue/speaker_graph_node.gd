@tool
class_name HFDiagEditSpeakerNode
extends GraphNode

signal connect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal disconnect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal delete_called(speaker_data: HFDialogueSpeaker)

var speaker_data: HFDialogueSpeaker


func _ready() -> void:
	position_offset_changed.connect(
		func():
			speaker_data.graph_position = position_offset
	)


func _init() -> void:
	node_selected.connect(_on_node_selected)


func _on_node_selected() -> void:
	EditorInterface.edit_resource(speaker_data)


func setup(speaker: HFDialogueSpeaker) -> void:
	speaker_data = speaker


func handle_delete() -> void:
	delete_called.emit(speaker_data)
