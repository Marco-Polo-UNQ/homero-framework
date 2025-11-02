class_name HFTriggerArea3D
extends Area3D
## 3D trigger area for handling collision and interaction events.
##
## Emits signals and triggers event groups when bodies or areas enter/exit,
## or when actions are pressed/released.

## Emitted when a collision is activated.
signal collision_activated()
## Emitted when a collision is deactivated.
signal collision_deactivated()
## Emitted when the interaction action is pressed.
signal action_pressed()
## Emitted when the interaction action is released.
signal action_released()

@export_category("Collision Triggers")
## If true, triggers on collision with areas.
@export var collision_areas: bool = false
## If true, triggers on collision with bodies.
@export var collision_bodies: bool = false
## Events triggered on collision enter.
@export var collision_events_on_enter: HFEventTriggerGroup
## Events triggered on collision exit.
@export var collision_events_on_exit: HFEventTriggerGroup

@export_category("Interaction Triggers")
## The input action name for interaction.
@export var interaction_action: StringName = &"interact"
## If true, triggers on interaction with areas.
@export var interaction_areas: bool = false
## If true, triggers on interaction with bodies.
@export var interaction_bodies: bool = false
## Events triggered when the interaction action is pressed.
@export var interaction_events_on_pressed: HFEventTriggerGroup
## Events triggered when the interaction action is released.
@export var interaction_events_on_released: HFEventTriggerGroup

## List of currently colliding areas.
var colliding_areas: Array[Area3D] = []
## List of currently colliding bodies.
var colliding_bodies: Array[Node3D] = []

## Called when the node is added to the scene tree.
func _ready() -> void:
	HFTriggerAreaCommon.ready_setup(self)

## Handles node entry for collision and interaction.
func _on_node_entered(
	node: Node3D,
	interaction_type: bool,
	collision_type: bool,
	interaction_node_list: Array
) -> void:
	HFTriggerAreaCommon.on_node_entered(
		self,
		node,
		interaction_type,
		collision_type,
		interaction_node_list
	)

## Handles node exit for collision and interaction.
func _on_node_exited(
	node: Node3D,
	interaction_type: bool,
	collision_type: bool,
	interaction_node_list: Array
) -> void:
	HFTriggerAreaCommon.on_node_exited(
		self,
		node,
		interaction_type,
		collision_type,
		interaction_node_list
	)

## Handles unhandled input for interaction actions.
func _unhandled_input(event: InputEvent) -> void:
	HFTriggerAreaCommon.handle_input(self, event)
