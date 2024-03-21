class_name HFDialogueStarterStep
extends Resource

@export var step_id: StringName
@export var enable_conditions: Array[HFEventConditional]


func _init(
	p_step_id: StringName = "",
	p_enable_conditions: Array[HFEventConditional] = []
) -> void:
	step_id = p_step_id
	enable_conditions = p_enable_conditions


func is_enabled() -> bool:
	var is_enabled: bool = true
	for condition in enable_conditions:
		is_enabled = is_enabled && condition.can_trigger_condition(
			"", true, EventsManager.events_map
		)
	return is_enabled
