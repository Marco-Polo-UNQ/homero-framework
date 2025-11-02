class_name HFTriggerAreaCommon
extends Object
## Utils class with common methods for [HFTriggerArea2D] and [HFTriggerArea3D]
##
## Common methods are implemented with polymorphism in mind as to avoid repeating
## as much code as possible in the TriggerArea classes given the lack of 
## multiple inheritance in the language. The methods assume the existence of
## given members for the trigger area using them, effectively forcing a
## common interface.

## Setup function connecting all relevant callbacks for body and area entered
## and exited signals
static func ready_setup(trigger_area: Node) -> void:
	trigger_area.set_process_unhandled_input(false)
	trigger_area.body_entered.connect(trigger_area._on_node_entered.bind(
		trigger_area.interaction_bodies,
		trigger_area.collision_bodies,
		trigger_area.colliding_bodies
	))
	trigger_area.body_exited.connect(trigger_area._on_node_exited.bind(
		trigger_area.interaction_bodies,
		trigger_area.collision_bodies,
		trigger_area.colliding_bodies
	))
	trigger_area.area_entered.connect(trigger_area._on_node_entered.bind(
		trigger_area.interaction_areas,
		trigger_area.collision_areas,
		trigger_area.colliding_areas
	))
	trigger_area.area_exited.connect(trigger_area._on_node_exited.bind(
		trigger_area.interaction_areas,
		trigger_area.collision_areas,
		trigger_area.colliding_areas
	))

## Generic handling function for nodes entering the trigger area, enabling or
## disabling the input handling if needed and triggering collision enter events
static func on_node_entered(
	trigger_area: Node,
	node: Node,
	interaction_type: bool,
	collision_type: bool,
	interaction_node_list: Array
) -> void:
	HFLog.d("%s: [color=green]Node entered![/color] %s" % [trigger_area.name, node])
	if interaction_type && !interaction_node_list.has(node):
		interaction_node_list.push_back(node)
		trigger_area.set_process_unhandled_input(_eval_can_handle_input(trigger_area))
	
	if collision_type && trigger_area.collision_events_on_enter != null:
		trigger_area.collision_events_on_enter.trigger_events()
		trigger_area.collision_activated.emit()


## Generic handling function for nodes exiting the trigger area, enabling or
## disabling the input handling if needed and triggering collision exit events
static func on_node_exited(
	trigger_area: Node,
	node: Node,
	interaction_type: bool,
	collision_type: bool,
	interaction_node_list: Array
) -> void:
	HFLog.d("%s: [color=green]Node exited![/color] %s" % [trigger_area.name, node])
	if interaction_type && interaction_node_list.has(node):
		interaction_node_list.erase(node)
		trigger_area.set_process_unhandled_input(_eval_can_handle_input(trigger_area))
	
	if collision_type && trigger_area.collision_events_on_exit != null:
		trigger_area.collision_events_on_exit.trigger_events()
		trigger_area.collision_deactivated.emit()


## Handles input events for interactions while inside a trigger area.
static func handle_input(trigger_area: Node, event: InputEvent) -> void:
	if event.is_action_pressed(trigger_area.interaction_action):
		trigger_area.action_pressed.emit()
		if trigger_area.interaction_events_on_pressed != null:
			trigger_area.interaction_events_on_pressed.trigger_events()
	elif event.is_action_released(trigger_area.interaction_action):
		trigger_area.action_released.emit()
		if trigger_area.interaction_events_on_released != null:
			trigger_area.interaction_events_on_released.trigger_events()


# Evaluates if input handling should be enabled based on current collisions.
static func _eval_can_handle_input(trigger_area: Node) -> bool:
	return (
		trigger_area.interaction_bodies && !trigger_area.colliding_bodies.is_empty()
	) || (
		trigger_area.interaction_areas && !trigger_area.colliding_areas.is_empty()
	)
