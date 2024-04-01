class_name HFDialogueOption
extends Resource

signal option_selected(dialogue_key: StringName, next_step_id: int)

@export_category("Dialogue Option Info")
@export var dialogue_key: StringName
@export var next_step_id: int
@export var enable_conditions: Array[HFEventConditional]

@export_category("Dialogue Events")
@export var option_events: HFEventTriggerGroup

@export_category("Editor Metadata (ignore)")
@export var graph_position: Vector2


func _init(
	p_dialogue_key: StringName = "",
	p_next_step_id: int = 0,
	p_enable_conditions: Array[HFEventConditional] = []
) -> void:
	dialogue_key = p_dialogue_key
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
	HFLog.d("Option selected %s with next step %s" % [dialogue_key, next_step_id])
	if option_events != null:
		option_events.trigger_events()
	option_selected.emit(dialogue_key, next_step_id)
