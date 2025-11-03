extends GutTest

const NEW_GRAPH_NODE_POPUP_SCENE: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/dialogue/new_graph_node_popup.tscn"
)

var new_graph_node_popup: Control


func before_each() -> void:
	new_graph_node_popup = NEW_GRAPH_NODE_POPUP_SCENE.instantiate()
	add_child_autoqfree(new_graph_node_popup)
	watch_signals(new_graph_node_popup)


func test_new_graph_node_popup_exists() -> void:
	assert_not_null(new_graph_node_popup)


func test_new_graph_node_popup_ready_hides_popup() -> void:
	assert_false(new_graph_node_popup.visible)


func test_new_graph_node_popup_setup_sets_position_and_shows() -> void:
	var p: Vector2 = Vector2(123, 456)
	new_graph_node_popup.setup(p)
	assert_eq(new_graph_node_popup.position, p)
	assert_true(new_graph_node_popup.visible)


func test_new_graph_node_popup_setup_populates_conditionals_buttons() -> void:
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	var count: int = 0
	for class_dict: Dictionary in global_class_list:
		if class_dict.base == "HFEventConditional" && class_dict.class != "HFEventConditional":
			count += 1
	new_graph_node_popup.setup(Vector2.ZERO)
	var conditionals_container: Node = new_graph_node_popup.conditionals_buttons_container
	assert_eq(conditionals_container.get_child_count(), count)


func test_new_graph_node_popup_on_starting_step_button_emits_and_hides() -> void:
	new_graph_node_popup.find_child("StartingStepButton").pressed.emit()
	assert_signal_emit_count(new_graph_node_popup.new_starting_step_requested, 1)
	assert_false(new_graph_node_popup.visible)


func test_new_graph_node_popup_on_dialogue_step_button_emits_and_hides() -> void:
	new_graph_node_popup.find_child("DialogueStepButton").pressed.emit()
	assert_signal_emit_count(new_graph_node_popup.new_dialogue_step_requested, 1)
	assert_false(new_graph_node_popup.visible)


func test_new_graph_node_popup_on_dialogue_option_button_emits_and_hides() -> void:
	new_graph_node_popup.find_child("DialogueOptionButton").pressed.emit()
	assert_signal_emit_count(new_graph_node_popup.new_dialogue_option_requested, 1)
	assert_false(new_graph_node_popup.visible)


func test_new_graph_node_popup_on_dialogue_event_button_emits_and_hides() -> void:
	new_graph_node_popup.find_child("DialogueEventButton").pressed.emit()
	assert_signal_emit_count(new_graph_node_popup.new_dialogue_event_requested, 1)
	assert_false(new_graph_node_popup.visible)


func test_new_graph_node_popup_on_dialogue_speaker_button_emits_and_hides() -> void:
	new_graph_node_popup.find_child("DialogueSpeakerButton").pressed.emit()
	assert_signal_emit_count(new_graph_node_popup.new_dialogue_speaker_requested, 1)
	assert_false(new_graph_node_popup.visible)


func test_new_graph_node_popup_on_dialogue_conditional_button_emits_and_hides() -> void:
	new_graph_node_popup.setup(Vector2.ZERO)
	var conditionals_container: Node = new_graph_node_popup.conditionals_buttons_container
	var first_button: Button = conditionals_container.get_child(0) as Button
	first_button.pressed.emit()
	assert_signal_emit_count(new_graph_node_popup.new_dialogue_conditional_requested, 1)
	assert_false(new_graph_node_popup.visible)


func test_new_graph_node_popup_toggle_popup_hides_conditionals_list() -> void:
	new_graph_node_popup._toggle_popup(true)
	assert_true(new_graph_node_popup.visible)
	new_graph_node_popup._toggle_popup(false)
	assert_false(new_graph_node_popup.visible)
	if new_graph_node_popup.has_node("ConditionalsListDropdown"):
		assert_false(new_graph_node_popup.conditionals_list_dropdown.visible)


func test_new_graph_node_popup_on_dialogue_conditional_button_mouse_entered_shows_conditionals_list() -> void:
	new_graph_node_popup.setup(Vector2.ZERO)
	var dialogue_conditional_button: Control = new_graph_node_popup.dialogue_conditional_button
	dialogue_conditional_button.mouse_entered.emit()
	assert_true(new_graph_node_popup.conditionals_list_dropdown.visible)


func test_new_graph_node_popup_can_hide_conditionals_list_on_mouse_exited_on_input_event() -> void:
	new_graph_node_popup.setup(Vector2.ZERO)
	var dialogue_conditional_button: Control = new_graph_node_popup.dialogue_conditional_button
	dialogue_conditional_button.mouse_entered.emit()
	assert_true(new_graph_node_popup.conditionals_list_dropdown.visible)
	dialogue_conditional_button.mouse_exited.emit()
	var sender = GutInputSender.new(new_graph_node_popup)
	sender.mouse_motion(Vector2(10000, 10000), Vector2(10000, 10000))
	assert_false(new_graph_node_popup.conditionals_list_dropdown.visible)


func test_new_graph_node_popup_hides_popup_on_left_or_right_mouse_click_outside_rect() -> void:
	new_graph_node_popup.setup(Vector2.ZERO)
	assert_true(new_graph_node_popup.visible)
	var sender = GutInputSender.new(new_graph_node_popup)
	sender.mouse_left_button_down(
		Vector2(10000, 10000),
		Vector2(10000, 10000)
	)
	assert_false(new_graph_node_popup.visible)
	new_graph_node_popup.setup(Vector2.ZERO)
	assert_true(new_graph_node_popup.visible)
	sender.mouse_right_button_down(
		Vector2(10000, 10000),
		Vector2(10000, 10000)
	)
	assert_false(new_graph_node_popup.visible)
