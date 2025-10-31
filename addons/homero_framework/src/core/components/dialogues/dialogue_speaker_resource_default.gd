class_name HFDialogueSpeakerDefaultResource
extends HFDialogueSpeakerResource

@export var speaker_name: StringName

func _init(p_speaker_name: StringName = &"") -> void:
	speaker_name = p_speaker_name
