extends GutTest

var dialogue_speaker_resource: HFDialogueSpeakerResource


func before_each() -> void:
	dialogue_speaker_resource = HFDialogueSpeakerDefaultResource.new(&"test")


func test_dialogue_speaker_resource_exists() -> void:
	assert_not_null(
		dialogue_speaker_resource,
		"Dialogue Speaker Resource should instantiate and not be null"
	)


func test_dialogue_speaker_resource_default_has_starting_steps() -> void:
	assert_eq(
		dialogue_speaker_resource.speaker_name,
		&"test"
	)
