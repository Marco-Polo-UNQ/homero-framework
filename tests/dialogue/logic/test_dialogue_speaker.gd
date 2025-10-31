extends GutTest

var dialogue_speaker: HFDialogueSpeaker

var speaker_data_stub: HFDialogueSpeakerResource


func before_each() -> void:
	speaker_data_stub = double(HFDialogueSpeakerResource).new()
	
	dialogue_speaker = HFDialogueSpeaker.new(
		speaker_data_stub,
		Vector2.ZERO
	)


func test_dialogue_speaker_exists() -> void:
	assert_not_null(
		dialogue_speaker,
		"Dialogue Speaker should instantiate and not be null"
	)


func test_dialogue_speaker_has_starting_steps() -> void:
	assert_eq(
		dialogue_speaker.speaker_data,
		speaker_data_stub
	)


func test_dialogue_speaker_has_dialogue_steps() -> void:
	assert_eq(
		dialogue_speaker.graph_position,
		Vector2.ZERO
	)
