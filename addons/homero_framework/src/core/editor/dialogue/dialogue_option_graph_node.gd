@tool
class_name HFDiagEditDialogueOptionNode
extends GraphNode
## Graph node for editing dialogue options in the dialogue editor.

## Emitted when a request to connect ports is made.
signal connect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
## Emitted when a request to disconnect ports is made.
signal disconnect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
## Emitted when this node is deleted.
signal delete_called(option_data: HFDialogueOption)

## Reference to the LineEdit for the option id.
@onready var id_line_edit: LineEdit = %IdLineEdit

## The dialogue option data represented by this node.
var option_data: HFDialogueOption

## Reference to the next dialogue step node connected to this option.
var next_step_node: HFDiagEditDialogueStepNode

## Reference to the dialogue event node connected to this option.
var dialogue_event: HFDiagEditDialogueEventNode


## Sets up the node with the given dialogue option data.
func setup(dialogue_option: HFDialogueOption) -> void:
	option_data = dialogue_option
	_cache_references()
	id_line_edit.text = option_data.dialogue_key

## Handles connection to a dialogue step node.
func handle_step_connection(
	step_node: HFDiagEditDialogueStepNode,
	is_new: bool = false
) -> void:
	if (
		is_new &&
		option_data.next_step_id != step_node.step_data.unique_id
	):
		option_data.next_step_id = step_node.step_data.unique_id
		if next_step_node != null:
			if next_step_node.delete_called.is_connected(_on_next_step_node_deleted):
				next_step_node.delete_called.disconnect(_on_next_step_node_deleted)
	
	if option_data.next_step_id == step_node.step_data.unique_id:
		connect_ports_requested.emit(
			name,
			0,
			step_node.name,
			0
		)
		next_step_node = step_node
		if !next_step_node.delete_called.is_connected(_on_next_step_node_deleted):
			next_step_node.delete_called.connect(_on_next_step_node_deleted)

## Handles connection to a condition node.
func handle_condition_connection(
	condition_node: HFDiagEditConditionalNode,
	is_new: bool = false
) -> void:
	if is_new && !option_data.enable_conditions.has(condition_node.condition_data):
		# Ugly list copy to fix inconsistent array save state
		var list_copy: Array[HFEventConditional] = option_data.enable_conditions.duplicate(false)
		list_copy.push_back(condition_node.condition_data)
		option_data.enable_conditions = list_copy
	
	if option_data.enable_conditions.has(condition_node.condition_data):
		condition_node.handle_connect_to_element(self, 1)
		if !condition_node.delete_called.is_connected(_on_condition_removed):
			condition_node.delete_called.connect(_on_condition_removed)

## Handles disconnection from a condition node.
func handle_condition_disconnection(condition_node: HFDiagEditConditionalNode) -> void:
	if option_data.enable_conditions.has(condition_node.condition_data):
		_on_condition_removed(condition_node.condition_data)
		if condition_node.delete_called.is_connected(_on_condition_removed):
			condition_node.delete_called.disconnect(_on_condition_removed)
		condition_node.handle_disconnect_to_element(self, 1)

## Handles connection to a dialogue event node.
func handle_event_connection(
	event_node: HFDiagEditDialogueEventNode,
	is_new: bool = false
) -> void:
	if is_new && option_data.option_events != event_node.event_data:
		option_data.option_events = event_node.event_data
		if dialogue_event != null:
			if dialogue_event.delete_called.is_connected(_on_dialogue_event_deleted):
				dialogue_event.delete_called.disconnect(_on_dialogue_event_deleted)
	
	if option_data.option_events == event_node.event_data:
		connect_ports_requested.emit(
			name,
			1,
			event_node.name,
			0
		)
		dialogue_event = event_node
		if !dialogue_event.delete_called.is_connected(_on_dialogue_event_deleted):
			dialogue_event.delete_called.connect(_on_dialogue_event_deleted)

## Handles connection to a dialogue step node.
func handle_connection(
	_from_port: int,
	to_node: GraphNode,
	_to_port: int
) -> void:
	if to_node is HFDiagEditDialogueStepNode:
		if next_step_node != to_node:
			handle_step_connection(to_node, true)
	elif to_node is HFDiagEditDialogueEventNode:
		if dialogue_event != to_node:
			handle_event_connection(to_node, true)

## Handles disconnection from a connected node.
func handle_disconnection(
	from_port: int,
	_to_node: GraphNode = null,
	to_port: int = -1
) -> void:
	match from_port:
		0:
			option_data.next_step_id = -1
			if (
				next_step_node != null &&
				next_step_node.delete_called.is_connected(_on_next_step_node_deleted)
			):
				next_step_node.delete_called.disconnect(_on_next_step_node_deleted)
			next_step_node = null
			disconnect_ports_requested.emit(
				name,
				from_port,
				"",
				to_port
			)
		1:
			option_data.option_events = null
			if (
				dialogue_event != null &&
				dialogue_event.delete_called.is_connected(_on_dialogue_event_deleted)
			):
				dialogue_event.delete_called.disconnect(_on_dialogue_event_deleted)
			dialogue_event = null
			disconnect_ports_requested.emit(
				name,
				from_port,
				"",
				to_port
			)

## Handles deletion of this node.
func handle_delete() -> void:
	delete_called.emit(option_data)


# Called when the node is added to the scene tree.
func _ready() -> void:
	position_offset_changed.connect(_on_position_offset_changed)


func _cache_references() -> void:
	id_line_edit = %IdLineEdit


func _on_id_line_edit_text_changed(new_text: String) -> void:
	option_data.dialogue_key = new_text


func _on_position_offset_changed() -> void:
	option_data.graph_position = position_offset


func _on_next_step_node_deleted(deleted_step: HFDialogueStep) -> void:
	if option_data.next_step_id == deleted_step.unique_id:
		option_data.next_step_id = -1


func _on_condition_removed(condition_data: HFEventConditional) -> void:
	# Ugly list copy to fix inconsistent array save state
	var list_copy: Array[HFEventConditional] = option_data.enable_conditions.duplicate(false)
	list_copy.erase(condition_data)
	option_data.enable_conditions = list_copy


func _on_dialogue_event_deleted(event: HFEventTriggerGroup) -> void:
	if option_data.option_events == event:
		option_data.option_events = null
