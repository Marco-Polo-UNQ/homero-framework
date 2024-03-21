@tool
class_name HFDiagEditSpeakerNode
extends GraphNode

var speaker_id_line_edit: LineEdit

var speaker_data: HFDialogueSpeaker


func _init() -> void:
	node_selected.connect(_on_node_selected)


func _on_node_selected() -> void:
	EditorInterface.edit_resource(speaker_data)


func setup(speaker: HFDialogueSpeaker) -> void:
	speaker_data = speaker
	_cache_references()
	speaker_id_line_edit.text = speaker.speaker_name


func _on_speaker_id_line_edit_text_changed(new_text: String) -> void:
	speaker_data.speaker_name = new_text


func _cache_references() -> void:
	speaker_id_line_edit = %SpeakerIdLineEdit
