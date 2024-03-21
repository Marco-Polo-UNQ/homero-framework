class_name HFDialogueOption
extends Resource

signal option_selected(next_step_id: StringName)

@export_category("Dialogue Option Info")
@export var option_id: StringName
@export var next_step_id: StringName
@export var enable_conditions: Array[HFEventConditional]

@export_category("Dialogue Events")
@export var option_events: HFEventTriggerGroup


func _init(
	p_option_id: StringName = "",
	p_next_step_id: StringName = "",
	p_enable_conditions: Array[HFEventConditional] = []
) -> void:
	option_id = p_option_id
	next_step_id = p_next_step_id
	enable_conditions = p_enable_conditions


func is_enabled() -> bool:
	var is_enabled: bool = true
	for condition in enable_conditions:
		is_enabled = is_enabled && condition.can_trigger_condition(
			"", true, EventsManager.events_map
		)
	return is_enabled


func select_option() -> void:
	HFLog.d("Option selected %s with next step %s" % [option_id, next_step_id])
	if option_events != null:
		option_events.trigger_events()
	option_selected.emit(option_id, next_step_id)
