@tool
class_name HFDiagEditStartingStepNode
extends GraphNode

const conditional_node_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/dialogue_conditional_graph_node.tscn"
)

signal add_conditional_requested(conditional: HFEventConditional)

var conditionals_dropdown: Control
var buttons_options_container: Control

var starter_step_data: HFDialogueStarterStep


func _init() -> void:
	node_selected.connect(_on_node_selected)


func _on_node_selected() -> void:
	EditorInterface.edit_resource(starter_step_data)


func setup(data: HFDialogueStarterStep) -> void:
	starter_step_data = data
	_cache_references()
	_toggle_conditionals_dropdown(false)
	
	for condition: HFEventConditional in data.enable_conditions:
		_add_conditional_node(condition)


func handle_step_connection(dialogue_step_node: GraphNode) -> void:
	if starter_step_data.step_id == dialogue_step_node.step_data.step_id:
		var graph: GraphEdit = get_parent()
		graph.connect_node(
			name,
			0,
			dialogue_step_node.name,
			0
		)


func handle_connection(
	to_node: GraphNode,
	from_port: int,
	to_port: int
) -> bool:
	return false


func _on_add_conditional_button_pressed() -> void:
	for button: Node in buttons_options_container.get_children():
		buttons_options_container.remove_child(button)
		button.queue_free()
	
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	for class_dict: Dictionary in global_class_list:
		if class_dict.base == "HFEventConditional" && class_dict.class != "HFEventConditional":
			var new_button: Button = Button.new()
			buttons_options_container.add_child(new_button)
			new_button.text = class_dict.class
			new_button.pressed.connect(_on_new_conditional.bind(load(class_dict.path)))
	
	_toggle_conditionals_dropdown(true)


func _add_conditional_node(conditional_data: HFEventConditional) -> void:
	var graph: GraphEdit = get_parent()
	var conditional_node: GraphNode = conditional_node_scene.instantiate()
	conditional_node.delete_called.connect(_on_delete_condition_called)
	graph.add_child(conditional_node)
	conditional_node.setup(conditional_data)
	
	graph.connect_node(
		conditional_node.name,
		0,
		name,
		0
	)
	graph.arrange_nodes()


func _on_new_conditional(conditional_script: Script) -> void:
	var new_condition: HFEventConditional = conditional_script.new()
	_add_conditional_node(new_condition)
	starter_step_data.enable_conditions.push_back(new_condition)
	_toggle_conditionals_dropdown(false)


func _on_delete_condition_called(conditional_node: GraphNode) -> void:
	var graph: GraphEdit = get_parent()
	graph.disconnect_node(
		conditional_node.name,
		0,
		name,
		0
	)
	starter_step_data.enable_conditions.erase(conditional_node.condition)
	graph.remove_child(conditional_node)
	conditional_node.queue_free()
	graph.arrange_nodes()


func _toggle_conditionals_dropdown(enabled: bool) -> void:
	conditionals_dropdown.visible = enabled
	set_process_input(enabled)


func _cache_references() -> void:
	conditionals_dropdown = %ConditionalsListDropdown
	buttons_options_container = %ButtonsOptionsContainer


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton &&
		event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT] &&
		event.is_pressed() &&
		!conditionals_dropdown.get_global_rect().has_point(event.global_position)
	):
		_toggle_conditionals_dropdown(false)
