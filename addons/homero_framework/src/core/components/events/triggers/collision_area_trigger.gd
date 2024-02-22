class_name HFTriggerArea3D
extends Area3D

signal event_activated()
signal event_deactivated()
signal action_pressed()
signal action_released()


@export_category("Collision Triggers")
@export var activate_on_enter: bool = true

@export_group("Collision Tags")
@export var tags_on_activated: PackedStringArray
@export var tags_on_deactivated: PackedStringArray

@export_group("Collision Types")
@export var collision_areas: bool = true
@export var collision_bodies: bool = true

@export_category("Interaction Triggers")
@export var interaction_action: String = ""

@export_group("Interaction Tags")
@export var activate_tags_on_pressed: PackedStringArray
@export var deactivate_tags_on_pressed: PackedStringArray
@export var activate_tags_on_released: PackedStringArray
@export var deactivate_tags_on_released: PackedStringArray

@export_group("Interaction Types")
@export var interaction_areas: bool = false
@export var interaction_bodies: bool = false

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
	
	if collision_type:
		if activate_on_enter:
			_activate_tags(tags_on_deactivated, false)
			_activate_tags(tags_on_activated, true)
		else:
			_activate_tags(tags_on_activated, false)
			_activate_tags(tags_on_deactivated, true)


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
	
	if collision_type:
		if !activate_on_enter:
			_activate_tags(tags_on_deactivated, false)
			_activate_tags(tags_on_activated, true)
		else:
			_activate_tags(tags_on_activated, false)
			_activate_tags(tags_on_deactivated, true)


func _eval_can_handle_input() -> bool:
	return (
		interaction_bodies && !colliding_bodies.is_empty()
	) || (
		interaction_areas && !colliding_areas.is_empty()
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		action_pressed.emit()
		_activate_tags(activate_tags_on_pressed, true)
		_activate_tags(deactivate_tags_on_pressed, false)
	elif event.is_action_released("interact"):
		action_released.emit()
		_activate_tags(activate_tags_on_released, true)
		_activate_tags(deactivate_tags_on_released, false)


func _activate_tags(tag_list: Array, value: bool) -> void:
	for tag in tag_list:
		EventsManager.toggle_event(tag, value)

