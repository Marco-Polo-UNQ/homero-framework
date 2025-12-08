extends Node

@onready var container: Control = %Container
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var speaker_name_label: Label = %SpeakerNameLabel
@onready var dialogue_text: Label = %DialogueText
@onready var dialogue_timer: Timer = %DialogueTimer
@onready var options_container: Node = %OptionsContainer
@onready var option_button_prototype: Button

var dialogue_manager: HFDialogueManager


func _ready() -> void:
	option_button_prototype = options_container.get_child(0)
	options_container.remove_child(option_button_prototype)


func set_dialogue_manager(manager: HFDialogueManager) -> void:
	dialogue_manager = manager
	if !dialogue_manager.sequence_activated.is_connected(_on_dialogue_manager_sequence_activated):
		dialogue_manager.sequence_activated.connect(_on_dialogue_manager_sequence_activated)
	if !dialogue_manager.dialogue_sequence.step_changed.is_connected(_load_dialogue_step):
		dialogue_manager.dialogue_sequence.step_changed.connect(_load_dialogue_step)


func notify_exit() -> void:
	animation_player.play(&"end_dialogue")


func _on_dialogue_manager_sequence_activated() -> void:
	animation_player.play(&"start_dialogue")


func _load_dialogue_step(dialogue_step: HFDialogueStep) -> void:
	if !is_inside_tree():
		return
	if (
		dialogue_step.speaker != null &&
		dialogue_step.speaker.speaker_data != null
	):
		var speaker_data: HFDialogueSpeakerDefaultResource =\
			dialogue_step.speaker.speaker_data as HFDialogueSpeakerDefaultResource
		speaker_name_label.text = speaker_data.speaker_name
	else:
		speaker_name_label.text = ""
	dialogue_text.visible_characters = 0
	dialogue_text.text = dialogue_step.dialogue_key
	
	if dialogue_timer.is_stopped():
		dialogue_timer.start()
	
	for child: Node in options_container.get_children():
		options_container.remove_child(child)
		child.queue_free()


func _animate_dialogue() -> void:
	dialogue_text.visible_characters += 1
	if dialogue_text.visible_ratio >= 1.0:
		_stop_dialogue_animation()


func _on_continue_button_pressed() -> void:
	if dialogue_timer.is_stopped():
		print("Continue button pressed, advancing step")
		dialogue_manager.dialogue_sequence.advance_step()
	else:
		print("Continue button pressed, skipping dialogue_animation")
		_stop_dialogue_animation()


func _stop_dialogue_animation() -> void:
	dialogue_timer.stop()
	dialogue_text.visible_characters = -1
	var options: Array[HFDialogueOption] = dialogue_manager.dialogue_sequence.current_step.options
	for option: HFDialogueOption in options:
		if option.is_enabled():
			var button_copy: Button = option_button_prototype.duplicate(0)
			options_container.add_child(button_copy)
			button_copy.text = option.dialogue_key
			button_copy.pressed.connect(option.select_option)


func _remove_ui() -> void:
	get_parent().remove_child(self)
	option_button_prototype.queue_free()
	option_button_prototype = null
	queue_free()
