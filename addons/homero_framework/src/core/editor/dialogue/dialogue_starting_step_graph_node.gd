@tool
class_name HFDiagEditStartingStepNode
extends GraphNode
## Graph node for editing dialogue starting steps in the dialogue editor.

## Emitted when a request to connect ports is made.
signal connect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
## Emitted when a request to disconnect ports is made.
signal disconnect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
## Emitted when this node is deleted.
signal delete_called(starter_step_data: HFDialogueStarterStep)

## The starter step data resource represented by this node.
var starter_step_data: HFDialogueStarterStep

## Reference to the dialogue step node connected to this starting step.
var dialogue_step: HFDiagEditDialogueStepNode


## Sets up the node with the given starter step data.
func setup(data: HFDialogueStarterStep) -> void:
	starter_step_data = data

## Handles connection to a condition node.
func handle_condition_connection(
	condition_node: HFDiagEditConditionalNode,
	is_new: bool = false
) -> void:
	if is_new && !starter_step_data.enable_conditions.has(condition_node.condition_data):
		# Ugly list copy to fix inconsistent array save state
		var list_copy: Array[HFEventConditional] = starter_step_data.enable_conditions.duplicate(false)
		list_copy.push_back(condition_node.condition_data)
		starter_step_data.enable_conditions = list_copy
	
	if starter_step_data.enable_conditions.has(condition_node.condition_data):
		condition_node.handle_connect_to_element(self, 0)
		if !condition_node.delete_called.is_connected(_on_condition_removed):
			condition_node.delete_called.connect(_on_condition_removed)

## Handles disconnection from a condition node.
func handle_condition_disconnection(condition_node: HFDiagEditConditionalNode) -> void:
	if starter_step_data.enable_conditions.has(condition_node.condition_data):
		_on_condition_removed(condition_node.condition_data)
		if condition_node.delete_called.is_connected(_on_condition_removed):
			condition_node.delete_called.disconnect(_on_condition_removed)
		condition_node.handle_disconnect_to_element(self, 0)

### Handles connection to a dialogue step node.
func handle_step_connection(
	dialogue_step_node: HFDiagEditDialogueStepNode,
	is_new: bool = false
) -> void:
	if (
		is_new &&
		starter_step_data.step_id != dialogue_step_node.step_data.unique_id
	):
		starter_step_data.step_id = dialogue_step_node.step_data.unique_id
		if dialogue_step != null:
			if dialogue_step.delete_called.is_connected(_on_dialogue_step_delete_called):
				dialogue_step.delete_called.disconnect(_on_dialogue_step_delete_called)
	
	if starter_step_data.step_id == dialogue_step_node.step_data.unique_id:
		connect_ports_requested.emit(
			name,
			0,
			dialogue_step_node.name,
			0
		)
		dialogue_step = dialogue_step_node
		if !dialogue_step.delete_called.is_connected(_on_dialogue_step_delete_called):
			dialogue_step.delete_called.connect(_on_dialogue_step_delete_called)

## Handles connection from this node to another node.
func handle_connection(
	_from_port: int,
	to_node: GraphNode,
	_to_port: int
) -> void:
	if (
		to_node is HFDiagEditDialogueStepNode &&
		to_node != dialogue_step
	):
		handle_step_connection(to_node, true)

## Handles disconnection from a connected node.
func handle_disconnection(
	from_port: int,
	to_node: GraphNode = null,
	to_port: int = -1
) -> void:
	if (
		to_node == null ||
		(
			to_node is HFDiagEditDialogueStepNode &&
			to_node == dialogue_step
		)
	):
		starter_step_data.step_id = -1
		if dialogue_step != null && dialogue_step.delete_called.is_connected(_on_dialogue_step_delete_called):
			dialogue_step.delete_called.disconnect(_on_dialogue_step_delete_called)
		dialogue_step = null
		disconnect_ports_requested.emit(
			name,
			from_port,
			to_node.name if to_node != null else "",
			to_port
		)

## Handles deletion of this node.
func handle_delete() -> void:
	delete_called.emit(starter_step_data)


# Called when the node is added to the scene tree.
func _ready() -> void:
	position_offset_changed.connect(_on_position_offset_changed)


func _on_position_offset_changed() -> void:
	starter_step_data.graph_position = position_offset


func _on_condition_removed(condition_data: HFEventConditional) -> void:
	# Ugly list copy to fix inconsistent array save state
	var list_copy: Array[HFEventConditional] = starter_step_data.enable_conditions.duplicate(false)
	list_copy.erase(condition_data)
	starter_step_data.enable_conditions = list_copy


func _on_dialogue_step_delete_called(dialogue_removed: HFDialogueStep) -> void:
	if starter_step_data.step_id == dialogue_removed.unique_id:
		starter_step_data.step_id = -1
		dialogue_step = null
