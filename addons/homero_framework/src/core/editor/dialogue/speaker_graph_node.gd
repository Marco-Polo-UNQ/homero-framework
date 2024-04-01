@tool
class_name HFDiagEditSpeakerNode
extends GraphNode

signal connect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal disconnect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal delete_called(speaker_data: HFDialogueSpeaker)

var speaker_id_line_edit: LineEdit

var speaker_data: HFDialogueSpeaker


func _ready() -> void:
	position_offset_changed.connect(
		func():
			speaker_data.graph_position = position_offset
	)


func setup(speaker: HFDialogueSpeaker) -> void:
	speaker_data = speaker
	_cache_references()
	speaker_id_line_edit.text = speaker_data.speaker_name
	speaker_data.changed.connect(_on_speaker_resource_changed)


func _on_speaker_id_line_edit_text_changed(new_text: String) -> void:
	speaker_data.speaker_name = new_text


func _on_speaker_resource_changed() -> void:
	speaker_id_line_edit.text = speaker_data.speaker_name


func _cache_references() -> void:
	speaker_id_line_edit = %SpeakerIdLineEdit


func handle_delete() -> void:
	delete_called.emit(speaker_data)
