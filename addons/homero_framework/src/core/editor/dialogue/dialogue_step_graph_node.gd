@tool
class_name HFDiagEditDialogueStepNode
extends GraphNode

var step_id_line_edit: LineEdit

var step_data: HFDialogueStep


func _init() -> void:
	node_selected.connect(_on_node_selected)


func _on_node_selected() -> void:
	EditorInterface.edit_resource(step_data)


func setup(dialogue_step: HFDialogueStep) -> void:
	step_data = dialogue_step
	_cache_references()
	step_id_line_edit.text = dialogue_step.step_id


func handle_step_connection(dialogue_step_node: GraphNode) -> void:
	if step_data.next_step_id == dialogue_step_node.step_data.step_id:
		var graph: GraphEdit = get_parent()
		graph.connect_node(
			name,
			0,
			dialogue_step_node.name,
			0
		)


func handle_speaker_connection(speaker_node: GraphNode) -> void:
	if speaker_node.speaker_data == step_data.speaker:
		var graph: GraphEdit = get_parent()
		graph.connect_node(
			name,
			1,
			speaker_node.name,
			0
		)


func handle_connection(
	to_node: GraphNode,
	from_port: int,
	to_port: int
) -> bool:
	var can_connect: bool = true
	if to_node is HFDiagEditDialogueStepNode:
		var diag_node: HFDiagEditDialogueStepNode = (to_node as HFDiagEditDialogueStepNode)
		if diag_node.step_data.step_id.is_empty():
			can_connect = false
		else:
			step_data.next_step_id = diag_node.step_data.step_id
	elif to_node is HFDiagEditSpeakerNode:
		step_data.speaker = (to_node as HFDiagEditSpeakerNode).speaker_data
	
	return can_connect


func _on_step_id_line_edit_text_changed(new_text: String) -> void:
	step_data.step_id = new_text


func _cache_references() -> void:
	step_id_line_edit = %StepIdLineEdit
