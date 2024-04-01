@tool
class_name HFDiagEditDialogueStepNode
extends GraphNode

signal connect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal disconnect_ports_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal delete_called(step_data: HFDialogueStep)

var step_id_line_edit: LineEdit

var step_data: HFDialogueStep


func _ready() -> void:
	position_offset_changed.connect(
		func():
			step_data.graph_position = position_offset
	)


func setup(dialogue_step: HFDialogueStep) -> void:
	step_data = dialogue_step
	_cache_references()
	step_id_line_edit.text = dialogue_step.dialogue_key


func _on_step_id_line_edit_text_changed(new_text: String) -> void:
	step_data.dialogue_key = new_text


func _cache_references() -> void:
	step_id_line_edit = %StepIdLineEdit


var next_step: HFDiagEditDialogueStepNode

func handle_step_connection(
	dialogue_step_node: HFDiagEditDialogueStepNode,
	is_new: bool = false
) -> void:
	if (
		is_new &&
		step_data.next_step_id != dialogue_step_node.step_data.unique_id
	):
		step_data.next_step_id = dialogue_step_node.step_data.unique_id
		if next_step != null:
			if next_step.delete_called.is_connected(_on_next_step_deleted):
				next_step.delete_called.disconnect(_on_next_step_deleted)
	
	if step_data.next_step_id == dialogue_step_node.step_data.unique_id:
		connect_ports_requested.emit(
			name,
			0,
			dialogue_step_node.name,
			0
		)
		next_step = dialogue_step_node
		if !next_step.delete_called.is_connected(_on_next_step_deleted):
			next_step.delete_called.connect(_on_next_step_deleted)

func _on_next_step_deleted(deleted_step: HFDialogueStep) -> void:
	if step_data.next_step_id == deleted_step.unique_id:
		step_data.next_step_id = -1
		next_step = null


var speaker: HFDiagEditSpeakerNode

func handle_speaker_connection(
	speaker_node: HFDiagEditSpeakerNode,
	is_new: bool = false
) -> void:
	if is_new && step_data.speaker != speaker_node.speaker_data:
		step_data.speaker = speaker_node.speaker_data
		if speaker != null:
			if speaker.delete_called.is_connected(_on_speaker_deleted):
				speaker.delete_called.disconnect(_on_speaker_deleted)
	
	if step_data.speaker == speaker_node.speaker_data:
		connect_ports_requested.emit(
			name,
			1,
			speaker_node.name,
			0
		)
		speaker = speaker_node
		if !speaker.delete_called.is_connected(_on_speaker_deleted):
			speaker.delete_called.connect(_on_speaker_deleted)

func _on_speaker_deleted(speaker_data: HFDialogueSpeaker) -> void:
	if step_data.speaker == speaker_data:
		step_data.speaker = null
		speaker = null


func handle_option_connection(
	option_node: HFDiagEditDialogueOptionNode,
	is_new: bool = false
) -> void:
	if is_new && !step_data.options.has(option_node.option_data):
		step_data.options.push_back(option_node.option_data)
	
	if step_data.options.has(option_node.option_data):
		connect_ports_requested.emit(
			name,
			2,
			option_node.name,
			0,
			false
		)
		if !option_node.delete_called.is_connected(_on_option_deleted):
			option_node.delete_called.connect(_on_option_deleted)

func _on_option_deleted(option_data: HFDialogueOption) -> void:
	if step_data.options.has(option_data):
		step_data.options.erase(option_data)


var dialogue_event_node: HFDiagEditDialogueEventNode

func handle_event_connection(
	event_node: HFDiagEditDialogueEventNode,
	is_new: bool = false
) -> void:
	if is_new && step_data.dialogue_events != event_node.event_data:
		step_data.dialogue_events = event_node.event_data
		if dialogue_event_node != null:
			if dialogue_event_node.delete_called.is_connected(_on_dialogue_event_deleted):
				dialogue_event_node.delete_called.disconnect(_on_dialogue_event_deleted)
	
	if step_data.dialogue_events == event_node.event_data:
		connect_ports_requested.emit(
			name,
			3,
			event_node.name,
			0
		)
		dialogue_event_node = event_node
		if !dialogue_event_node.delete_called.is_connected(_on_dialogue_event_deleted):
			dialogue_event_node.delete_called.connect(_on_dialogue_event_deleted)

func _on_dialogue_event_deleted(dialogue_data: HFEventTriggerGroup) -> void:
	if step_data.dialogue_events == dialogue_data:
		step_data.dialogue_events = null
		dialogue_event_node = null


func handle_connection(
	from_port: int,
	to_node: GraphNode,
	to_port: int
) -> void:
	if to_node is HFDiagEditDialogueStepNode:
		if next_step != to_node:
			handle_step_connection(to_node, true)
	elif to_node is HFDiagEditSpeakerNode:
		if speaker != to_node:
			handle_speaker_connection(to_node, true)
	elif to_node is HFDiagEditDialogueOptionNode:
		if !step_data.options.has(to_node.option_data):
			handle_option_connection(to_node, true)
	elif to_node is HFDiagEditDialogueEventNode:
		if dialogue_event_node != to_node:
			handle_event_connection(to_node, true)


func handle_disconnection(
	from_port: int,
	to_node: GraphNode = null,
	to_port: int = -1
) -> void:
	match from_port:
		0:
			step_data.next_step_id = -1
			if next_step != null && next_step.delete_called.is_connected(_on_next_step_deleted):
				next_step.delete_called.disconnect(_on_next_step_deleted)
			next_step = null
			disconnect_ports_requested.emit(
				name,
				from_port,
				"",
				to_port
			)
		1:
			step_data.speaker = null
			if speaker != null && speaker.delete_called.is_connected(_on_speaker_deleted):
				speaker.delete_called.disconnect(_on_speaker_deleted)
			speaker = null
			disconnect_ports_requested.emit(
				name,
				from_port,
				"",
				to_port
			)
		2:
			if to_node is HFDiagEditDialogueOptionNode:
				if to_node.delete_called.is_connected(_on_option_deleted):
					to_node.delete_called.disconnect(_on_option_deleted)
				step_data.options.erase(to_node.option_data)
				disconnect_ports_requested.emit(
					name,
					from_port,
					to_node.name,
					to_port
				)
		3:
			step_data.dialogue_events = null
			if dialogue_event_node != null && dialogue_event_node.delete_called.is_connected(_on_dialogue_event_deleted):
				dialogue_event_node.delete_called.disconnect(_on_dialogue_event_deleted)
			dialogue_event_node = null
			disconnect_ports_requested.emit(
				name,
				from_port,
				"",
				to_port
			)


func handle_delete() -> void:
	delete_called.emit(step_data)
