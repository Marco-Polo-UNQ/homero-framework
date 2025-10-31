class_name HFDialogueSpeaker
extends Resource
## Wrapper of [HFDialogueSpeakerResource] for Dialogue Editor handling.

## The actual editable speaker data resource for this speaker.
@export var speaker_data: HFDialogueSpeakerResource

## Dialogue editor graph position metadata, not visible in editor inspector.
@export_storage var graph_position: Vector2


func _init(
	p_speaker_data: HFDialogueSpeakerResource = null,
	p_graph_position: Vector2 = Vector2.ZERO
) -> void:
	speaker_data = p_speaker_data
	graph_position = p_graph_position
