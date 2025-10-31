class_name HFDialogueSpeakerDefaultResource
extends HFDialogueSpeakerResource
## Default implementation of [HFDialogueSpeakerResource] with basic properties.

## Speaker name property to be used in dialogue UI systems.
@export var speaker_name: StringName

func _init(p_speaker_name: StringName = &"") -> void:
	speaker_name = p_speaker_name
