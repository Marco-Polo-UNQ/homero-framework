class_name HFEventListener
extends Node

signal effect_activated
signal effect_deactivated

@export var listener_conditionals: Array[HFEventConditional]

var is_active: bool = false


func _ready() -> void:
	EventsManager.event_changed.connect(event_triggered)
	listener_conditionals = listener_conditionals.duplicate()
	for conditional in listener_conditionals:
		conditional.condition_changed.connect(
			func ():
				event_triggered("", true, EventsManager.events_map)
		)


func add_conditional(new_condition: HFEventConditional) -> void:
	new_condition.condition_changed.connect(
		func ():
			event_triggered("", true, EventsManager.events_map)
	)
	listener_conditionals.push_back(new_condition)


func event_triggered(
	event_tag: String,
	value: bool,
	events_map: Dictionary
) -> void:
	var all_check: bool = true
	
	for conditional in listener_conditionals:
		all_check = all_check && conditional.can_trigger_condition(
			event_tag, value, events_map
		)
	
	if all_check && !is_active:
		is_active = true
		effect_activated.emit()
		print_rich("Listener %s [color=green]activated[/color]" % self)
	elif !all_check && is_active:
		is_active = false
		effect_deactivated.emit()
		print_rich("Listener %s [color=red]deactivated[/color]" % self)
