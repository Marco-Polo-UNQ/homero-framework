class_name HFDialogueManager
extends Node
## Dialogue manager for handling dialogue sequences and display scenes.
##
## Manages activation and deactivation of dialogue sequences, connects
## display scenes, and emits signals when sequences are activated or deactivated.
## Intended to be used as a node in the scene tree.

## Emitted when a dialogue sequence begins.
signal sequence_activated()
## Emitted when a dialogue sequence ends.
signal sequence_deactivated()

## The [HFDialogueSequence] resource with the dialogue data.
@export var dialogue_sequence: HFDialogueSequence
## The scene to use for displaying dialogue as a UI interface. It will be added
## as a child node when calling [method activate_dialogue] and can have a method
## `set_dialogue_manager(dialogue_manager: HFDialogueManager)` to link back.
## If it has a method `notify_exit()`, it will be called before removal when
## the dialogue ends.
@export var dialogue_display_scene: PackedScene

# Internal reference to the instantiated dialogue display node.
var _dialogue_display_instance: Node

# Called when the node is added to the scene tree.
func _ready() -> void:
	if dialogue_sequence != null:
		dialogue_sequence.dialogue_started.connect(_on_dialogue_started)
		dialogue_sequence.dialogue_ended.connect(_on_dialogue_ended)

## Activates the dialogue sequence and display scene. Fails with a
## warning if already active.
func activate_dialogue() -> void:
	if dialogue_sequence.active:
		HFLog.w("Dialogue sequence already active, skipping...")
		return
	
	if dialogue_display_scene != null:
		_remove_dialogue_display_instance()
		_dialogue_display_instance = dialogue_display_scene.instantiate()
		add_child(_dialogue_display_instance)
		if _dialogue_display_instance.has_method("set_dialogue_manager"):
			_dialogue_display_instance.set_dialogue_manager(self)
	dialogue_sequence.start_sequence()

# Handles the [signal HFDialogueSequence.dialogue_started] signal from the sequence
# and emits [signal sequence_activated].
func _on_dialogue_started() -> void:
	sequence_activated.emit()

# Deactivates the dialogue sequence and removes the dialogue display, emmiting
# the signal [signal sequence_deactivated].
func _on_dialogue_ended() -> void:
	_remove_dialogue_display_instance(false)
	sequence_deactivated.emit()

# Removes the active display scene from the tree and frees it.
# [param instantaneous] If false, calls notify_exit() before removal if available.
func _remove_dialogue_display_instance(instantaneous: bool = true) -> void:
	if is_instance_valid(_dialogue_display_instance):
		if _dialogue_display_instance.has_method(&"notify_exit") && !instantaneous:
			_dialogue_display_instance.notify_exit()
		else:
			if get_children().has(_dialogue_display_instance):
				remove_child(_dialogue_display_instance)
			_dialogue_display_instance.queue_free()
