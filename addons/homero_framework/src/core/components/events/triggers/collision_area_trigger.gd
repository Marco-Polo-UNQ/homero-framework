class_name HFTriggerArea3D
extends Area3D

signal collision_activated()
signal collision_deactivated()
signal action_pressed()
signal action_released()

@export_category("Collision Triggers")
@export var collision_areas: bool = false
@export var collision_bodies: bool = false
@export var collision_events_on_enter: HFEventTriggerGroup
@export var collision_events_on_exit: HFEventTriggerGroup

@export_category("Interaction Triggers")
@export var interaction_action: String = "interact"
@export var interaction_areas: bool = false
@export var interaction_bodies: bool = false
@export var interaction_events_on_pressed: HFEventTriggerGroup
@export var interaction_events_on_released: HFEventTriggerGroup

var colliding_areas: Array[Area3D] = []
var colliding_bodies: Array[Node3D] = []


func _ready() -> void:
	set_process_unhandled_input(false)
	body_entered.connect(_on_node_entered.bind(
		interaction_bodies, colliding_bodies, collision_bodies
	))
	body_exited.connect(_on_node_exited.bind(
		interaction_bodies, colliding_bodies, collision_bodies
	))
	area_entered.connect(_on_node_entered.bind(
		interaction_areas, colliding_areas, collision_areas
	))
	area_exited.connect(_on_node_exited.bind(
		interaction_areas, colliding_areas, collision_areas
	))


func _on_node_entered(
	node: Node3D,
	interaction_type: bool,
	interaction_node_list: Array,
	collision_type: bool
) -> void:
	print_rich(name, ": [color=green]Node entered![/color]", node)
	if interaction_type && !interaction_node_list.has(node):
		interaction_node_list.push_back(node)
		set_process_unhandled_input(_eval_can_handle_input())
	
	if collision_type && collision_events_on_enter != null:
		collision_events_on_enter.trigger_events()
		collision_activated.emit()


func _on_node_exited(
	node: Node3D,
	interaction_type: bool,
	interaction_node_list: Array,
	collision_type: bool
) -> void:
	print_rich(name, " [color=red]Node exited![/color]", node)
	if interaction_type && interaction_node_list.has(node):
		interaction_node_list.erase(node)
		set_process_unhandled_input(_eval_can_handle_input())
	
	if collision_type && collision_events_on_exit != null:
		collision_events_on_exit.trigger_events()
		collision_deactivated.emit()


func _eval_can_handle_input() -> bool:
	return (
		interaction_bodies && !colliding_bodies.is_empty()
	) || (
		interaction_areas && !colliding_areas.is_empty()
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(interaction_action):
		action_pressed.emit()
		if interaction_events_on_pressed != null:
			interaction_events_on_pressed.trigger_events()
	elif event.is_action_released(interaction_action):
		action_released.emit()
		if interaction_events_on_released != null:
			interaction_events_on_released.trigger_events()

