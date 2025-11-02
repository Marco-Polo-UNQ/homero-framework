class_name HFEventListener
extends Node
## Event listener node for handling event conditionals and activation effects.
##
## Listens for event changes emited from [EventManager] or its own
## [HFEventConditional] [member listener_conditionals], checks them and emits
## [signal effect_activated] or [signal effect_deactivated] accordingly.

## Emitted when all [member listener_conditionals] return true and
## [member is_active] was false.
signal effect_activated
## Emitted when all [member listener_conditionals] return false and
## [member is_active] was true.
signal effect_deactivated

## The array of [HFEventConditional] to check and listen to.
@export var listener_conditionals: Array[HFEventConditional]

## True if the listener is currently active. Should not be manually modified,
## only changed via [method event_triggered] checks.
var is_active: bool = false

# Called when the node is added to the scene tree.
func _ready() -> void:
	EventsManager.event_changed.connect(event_triggered)
	
	# We duplicate the conditionals list and use the clone because of Array
	# pointer shenanigans when altering the Array with add_conditional
	# modifying the original on succesive executions on the editor.
	listener_conditionals = listener_conditionals.duplicate()
	for conditional in listener_conditionals:
		conditional.condition_changed.connect(event_triggered.bind(&"", false, EventsManager.events_map))

## Adds a new [HFEventConditional] to the [member listener_conditionals] list.
func add_conditional(new_conditional: HFEventConditional) -> void:
	new_conditional.condition_changed.connect(event_triggered.bind(&"", false, EventsManager.events_map))
	listener_conditionals.push_back(new_conditional)

## Removes an existing [HFEventConditional] from the [member listener_conditionals] list.
func remove_conditional(conditional: HFEventConditional) -> void:
	if listener_conditionals.has(conditional):
		listener_conditionals.erase(conditional)
		if conditional.condition_changed.is_connected(event_triggered):
			conditional.condition_changed.disconnect(event_triggered)

## Called when an event is triggered. Checks all [HFEventConditional] and emits
## signals if [member is_active] is toggled.
func event_triggered(
	event_tag: StringName,
	value: bool,
	events_map: Dictionary[StringName, bool]
) -> void:
	if listener_conditionals.is_empty():
		return
	
	var all_check: bool = true
	
	for conditional in listener_conditionals:
		all_check = all_check && conditional.can_trigger_condition(
			event_tag, value, events_map
		)
	
	if all_check && !is_active:
		is_active = true
		effect_activated.emit()
		HFLog.d("Listener %s [color=green]activated[/color]" % self)
	elif !all_check && is_active:
		is_active = false
		effect_deactivated.emit()
		HFLog.d("Listener %s [color=red]deactivated[/color]" % self)
