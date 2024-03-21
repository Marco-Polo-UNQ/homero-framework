class_name HFDialogueManager
extends Node

signal sequence_activated()
signal sequence_deactivated()

@export var dialogue_sequence: HFDialogueSequence
@export var dialogue_display_scene: PackedScene

var _active_display_scene: Node


func _ready() -> void:
	if dialogue_sequence != null:
		dialogue_sequence.dialogue_started.connect(_on_dialogue_started)
		dialogue_sequence.dialogue_ended.connect(_on_dialogue_ended)


func activate_dialogue() -> void:
	if dialogue_sequence.active:
		HFLog.d("Dialogue sequence already active, skipping...")
		return
	
	if dialogue_display_scene != null:
		_remove_active_display_scene()
		_active_display_scene = dialogue_display_scene.instantiate()
		add_child(_active_display_scene)
		if _active_display_scene.has_method("set_dialogue_manager"):
			_active_display_scene.set_dialogue_manager(self)
	dialogue_sequence.start_sequence()


func deactivate_dialogue() -> void:
	_remove_active_display_scene(false)
	sequence_deactivated.emit()


func _on_dialogue_started() -> void:
	sequence_activated.emit()


func _on_dialogue_ended() -> void:
	deactivate_dialogue()


func _remove_active_display_scene(instantaneous: bool = true) -> void:
	if is_instance_valid(_active_display_scene):
		if _active_display_scene.has_method("notify_exit") && !instantaneous:
			_active_display_scene.notify_exit()
		else:
			if is_ancestor_of(_active_display_scene):
				remove_child(_active_display_scene)
			_active_display_scene.queue_free()
