extends GutTest

class TestArea2D:
	extends GutTest
	
	var tests_handler: CommonTestsHandler
	
	func before_all() -> void:
		tests_handler = CommonTestsHandler.new(
			self,
			Vector2.ZERO,
			Vector2.ONE * 1000.0,
			RectangleShape2D.new()
		)
	
	func before_each() -> void:
		tests_handler.before_each_handler(
			HFTriggerArea2D.new(),
			StaticBody2D.new(),
			Area2D.new(),
			CollisionShape2D.new(),
			CollisionShape2D.new(),
			CollisionShape2D.new()
		)
	
	#region tests
	
	func test_trigger_area_2d_exists() -> void:
		assert_true(tests_handler.handler_test_trigger_area_exists())
	
	func test_trigger_area_2d_has_collision_triggers_properties() -> void:
		assert_true(tests_handler.handler_test_trigger_area_has_collision_triggers_properties())

	func test_trigger_area_2d_has_interaction_triggers_properties() -> void:
		assert_true(tests_handler.handler_test_trigger_area_has_interaction_triggers_properties())

	func test_trigger_area_2d_process_unhandled_input_starts_set_to_false() -> void:
		assert_true(tests_handler.handler_test_trigger_area_process_unhandled_input_starts_set_to_false())

	func test_trigger_area_2d_has_signals_connected_to_callbacks() -> void:
		assert_true(tests_handler.handler_test_trigger_area_has_signals_connected_to_callbacks())

	func test_trigger_area_2d_can_detect_a_body_or_area_enter_and_trigger_collision_events_on_enter() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_detect_a_body_or_area_enter_and_trigger_collision_events_on_enter())

	func test_trigger_area_2d_doesnt_do_anything_on_body_or_area_enter_if_collision_bodies_and_collision_areas_is_false() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_enter_if_collision_bodies_and_collision_areas_is_false())

	func test_trigger_area_2d_doesnt_do_anything_on_body_or_area_entered_if_no_collision_events_on_enter_exist() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_entered_if_no_collision_events_on_enter_exist())

	func test_trigger_area_2d_can_detect_a_body_or_area_enter_and_enable_interactions_detection() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_detect_a_body_or_area_enter_and_enable_interactions_detection())

	func test_trigger_area_2d_doesnt_do_anything_on_body_or_area_enter_if_interaction_bodies_and_interaction_areas_is_false() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_enter_if_interaction_bodies_and_interaction_areas_is_false())

	func test_trigger_area_2d_can_detect_a_body_or_area_exit_and_trigger_collision_events_on_exit() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_detect_a_body_or_area_exit_and_trigger_collision_events_on_exit())

	func test_trigger_area_2d_doesnt_do_anything_on_body_or_area_exited_if_collision_bodies_and_collision_areas_is_false() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_exited_if_collision_bodies_and_collision_areas_is_false())

	func test_trigger_area_2d_doesnt_do_anything_on_body_or_area_exited_if_no_collision_events_on_exit_exist() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_exited_if_no_collision_events_on_exit_exist())

	func test_trigger_area_2d_can_detect_a_body_or_area_exit_and_disable_interactions_detection_if_none_are_inside() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_detect_a_body_or_area_exit_and_disable_interactions_detection_if_none_are_inside())

	func test_trigger_area_2d_doesnt_do_anything_on_body_or_area_exit_if_interaction_bodies_and_interaction_areas_is_false() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_exit_if_interaction_bodies_and_interaction_areas_is_false())

	func test_trigger_area_2d_can_handle_inputs_with_interaction_detections_enabled_and_trigger_events() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_handle_inputs_with_interaction_detections_enabled_and_trigger_events())

	func test_trigger_area_2d_can_handle_inputs_with_interaction_detections_enabled_but_not_trigger_events_if_it_doesnt_have_any() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_handle_inputs_with_interaction_detections_enabled_but_not_trigger_events_if_it_doesnt_have_any())

	func test_trigger_area_2d_ignores_invalid_inputs() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_ignores_invalid_inputs())

	func test_trigger_area_2d_cant_handle_inputs_if_no_element_is_inside() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_cant_handle_inputs_if_no_element_is_inside())
	
	#endregion


class TestArea3D:
	extends GutTest
	
	var tests_handler: CommonTestsHandler
	
	func before_all() -> void:
		tests_handler = CommonTestsHandler.new(
			self,
			Vector3.ZERO,
			Vector3.ONE * 1000.0,
			BoxShape3D.new()
		)
	
	func before_each() -> void:
		tests_handler.before_each_handler(
			HFTriggerArea3D.new(),
			StaticBody3D.new(),
			Area3D.new(),
			CollisionShape3D.new(),
			CollisionShape3D.new(),
			CollisionShape3D.new()
		)
	
	#region tests
	
	func test_trigger_area_3d_exists() -> void:
		assert_true(tests_handler.handler_test_trigger_area_exists())
	
	func test_trigger_area_3d_has_collision_triggers_properties() -> void:
		assert_true(tests_handler.handler_test_trigger_area_has_collision_triggers_properties())

	func test_trigger_area_3d_has_interaction_triggers_properties() -> void:
		assert_true(tests_handler.handler_test_trigger_area_has_interaction_triggers_properties())

	func test_trigger_area_3d_process_unhandled_input_starts_set_to_false() -> void:
		assert_true(tests_handler.handler_test_trigger_area_process_unhandled_input_starts_set_to_false())

	func test_trigger_area_3d_has_signals_connected_to_callbacks() -> void:
		assert_true(tests_handler.handler_test_trigger_area_has_signals_connected_to_callbacks())

	func test_trigger_area_3d_can_detect_a_body_or_area_enter_and_trigger_collision_events_on_enter() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_detect_a_body_or_area_enter_and_trigger_collision_events_on_enter())

	func test_trigger_area_3d_doesnt_do_anything_on_body_or_area_enter_if_collision_bodies_and_collision_areas_is_false() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_enter_if_collision_bodies_and_collision_areas_is_false())

	func test_trigger_area_3d_doesnt_do_anything_on_body_or_area_entered_if_no_collision_events_on_enter_exist() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_entered_if_no_collision_events_on_enter_exist())

	func test_trigger_area_3d_can_detect_a_body_or_area_enter_and_enable_interactions_detection() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_detect_a_body_or_area_enter_and_enable_interactions_detection())

	func test_trigger_area_3d_doesnt_do_anything_on_body_or_area_enter_if_interaction_bodies_and_interaction_areas_is_false() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_enter_if_interaction_bodies_and_interaction_areas_is_false())

	func test_trigger_area_3d_can_detect_a_body_or_area_exit_and_trigger_collision_events_on_exit() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_detect_a_body_or_area_exit_and_trigger_collision_events_on_exit())

	func test_trigger_area_3d_doesnt_do_anything_on_body_or_area_exited_if_collision_bodies_and_collision_areas_is_false() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_exited_if_collision_bodies_and_collision_areas_is_false())

	func test_trigger_area_3d_doesnt_do_anything_on_body_or_area_exited_if_no_collision_events_on_exit_exist() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_exited_if_no_collision_events_on_exit_exist())

	func test_trigger_area_3d_can_detect_a_body_or_area_exit_and_disable_interactions_detection_if_none_are_inside() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_detect_a_body_or_area_exit_and_disable_interactions_detection_if_none_are_inside())

	func test_trigger_area_3d_doesnt_do_anything_on_body_or_area_exit_if_interaction_bodies_and_interaction_areas_is_false() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_doesnt_do_anything_on_body_or_area_exit_if_interaction_bodies_and_interaction_areas_is_false())

	func test_trigger_area_3d_can_handle_inputs_with_interaction_detections_enabled_and_trigger_events() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_handle_inputs_with_interaction_detections_enabled_and_trigger_events())

	func test_trigger_area_3d_can_handle_inputs_with_interaction_detections_enabled_but_not_trigger_events_if_it_doesnt_have_any() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_can_handle_inputs_with_interaction_detections_enabled_but_not_trigger_events_if_it_doesnt_have_any())

	func test_trigger_area_3d_ignores_invalid_inputs() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_ignores_invalid_inputs())

	func test_trigger_area_3d_cant_handle_inputs_if_no_element_is_inside() -> void:
		assert_true(await tests_handler.handler_test_trigger_area_cant_handle_inputs_if_no_element_is_inside())
	
	#endregion


class CommonTestsHandler:
	extends RefCounted
	
	var test: GutTest
	var base_position_test
	var displacement_position_test
	var collision_shape_shape: Resource
	
	var trigger_area: Node

	var test_other_body: Node # We won't move this body in the tests
	var test_other_area: Node
	
	var trigger_area_collision_shape: Node
	var other_body_collision_shape: Node
	var other_area_collision_shape: Node

	var collision_events_on_enter_stub: HFEventTriggerGroup
	var collision_events_on_exit_stub: HFEventTriggerGroup
	var interaction_events_on_pressed_stub: HFEventTriggerGroup
	var interaction_events_on_released_stub: HFEventTriggerGroup

	#region setup
	
	func _init(
		p_test: GutTest,
		p_base_position_test,
		p_displacement_position_test,
		p_collision_shape_shape: Resource
	) -> void:
		test = p_test
		base_position_test = p_base_position_test
		displacement_position_test = p_displacement_position_test
		collision_shape_shape = p_collision_shape_shape
	
	func before_each_handler(
		p_trigger_area: Node,
		p_test_other_body: Node,
		p_test_other_area: Node,
		p_trigger_area_collision_shape: Node,
		p_other_body_collision_shape: Node,
		p_other_area_collision_shape: Node
	) -> void:
		collision_events_on_enter_stub = test.double(HFEventTriggerGroup).new(
			PackedStringArray([]),
			PackedStringArray([]),
			Vector2.ZERO
		)
		collision_events_on_exit_stub = test.double(HFEventTriggerGroup).new(
			PackedStringArray([]),
			PackedStringArray([]),
			Vector2.ZERO
		)
		interaction_events_on_pressed_stub = test.double(HFEventTriggerGroup).new(
			PackedStringArray([]),
			PackedStringArray([]),
			Vector2.ZERO
		)
		interaction_events_on_released_stub = test.double(HFEventTriggerGroup).new(
			PackedStringArray([]),
			PackedStringArray([]),
			Vector2.ZERO
		)
		
		trigger_area_collision_shape = p_trigger_area_collision_shape
		other_body_collision_shape = p_other_body_collision_shape
		other_area_collision_shape = p_other_area_collision_shape
		
		# We add it later on each test case in order to configure the starting
		# values of collision detection that its going to handle and connect to
		trigger_area = p_trigger_area
		
		trigger_area.collision_events_on_enter = collision_events_on_enter_stub
		trigger_area.collision_events_on_exit = collision_events_on_exit_stub
		trigger_area.interaction_events_on_pressed = interaction_events_on_pressed_stub
		trigger_area.interaction_events_on_released = interaction_events_on_released_stub
		
		test_other_body = p_test_other_body
		_configure_collision_node(test_other_body, other_body_collision_shape)
		
		test_other_area = p_test_other_area
		_configure_collision_node(test_other_area, other_area_collision_shape)


	func _configure_collision_node(
		node: Node,
		collision_shape: Node,
		starting_position = base_position_test
	) -> void:
		test.add_child_autoqfree(node)
		node.global_position = starting_position
		collision_shape.shape = collision_shape_shape
		node.add_child(collision_shape)

	#endregion

	#region initialization tests

	func handler_test_trigger_area_exists() -> bool:
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.assert_not_null(trigger_area)
		return true


	func handler_test_trigger_area_has_collision_triggers_properties() -> bool:
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.assert_false(trigger_area.collision_areas)
		test.assert_false(trigger_area.collision_bodies)
		test.assert_eq(
			trigger_area.collision_events_on_enter,
			collision_events_on_enter_stub
		)
		test.assert_eq(
			trigger_area.collision_events_on_exit,
			collision_events_on_exit_stub
		)
		return true


	func handler_test_trigger_area_has_interaction_triggers_properties() -> bool:
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.assert_eq(
			trigger_area.interaction_action,
			&"interact"
		)
		test.assert_false(trigger_area.interaction_areas)
		test.assert_false(trigger_area.interaction_bodies)
		test.assert_eq(
			trigger_area.interaction_events_on_pressed,
			interaction_events_on_pressed_stub
		)
		test.assert_eq(
			trigger_area.interaction_events_on_released,
			interaction_events_on_released_stub
		)
		return true


	func handler_test_trigger_area_process_unhandled_input_starts_set_to_false() -> bool:
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.assert_false(trigger_area.is_processing_unhandled_input())
		return true


	func handler_test_trigger_area_has_signals_connected_to_callbacks() -> bool:
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.assert_true(trigger_area.body_entered.is_connected(trigger_area._on_node_entered))
		test.assert_true(trigger_area.body_exited.is_connected(trigger_area._on_node_exited))
		test.assert_true(trigger_area.area_entered.is_connected(trigger_area._on_node_entered))
		test.assert_true(trigger_area.area_exited.is_connected(trigger_area._on_node_exited))
		return true

	#endregion

	#region tests body and area entered collision events

	func handler_test_trigger_area_can_detect_a_body_or_area_enter_and_trigger_collision_events_on_enter() -> bool:
		trigger_area.collision_bodies = true
		trigger_area.collision_areas = true
		_configure_collision_node(trigger_area, trigger_area_collision_shape, displacement_position_test)
		test.watch_signals(trigger_area)
		test.assert_signal_not_emitted(trigger_area.body_entered)
		test.assert_signal_not_emitted(trigger_area.area_entered)
		test.assert_signal_not_emitted(trigger_area.collision_activated)
		test_other_body.global_position = trigger_area.global_position
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emit_count(trigger_area.body_entered, 1)
		test.assert_signal_not_emitted(trigger_area.area_entered)
		test.assert_signal_emit_count(trigger_area.collision_activated, 1)
		test.assert_called_count(collision_events_on_enter_stub.trigger_events, 1)
		test_other_area.global_position = trigger_area.global_position
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emit_count(trigger_area.body_entered, 1)
		test.assert_signal_emit_count(trigger_area.area_entered, 1)
		test.assert_signal_emit_count(trigger_area.collision_activated, 2)
		test.assert_called_count(collision_events_on_enter_stub.trigger_events, 2)
		return true


	func handler_test_trigger_area_doesnt_do_anything_on_body_or_area_enter_if_collision_bodies_and_collision_areas_is_false() -> bool:
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emitted(trigger_area.body_entered)
		test.assert_signal_emitted(trigger_area.area_entered)
		test.assert_signal_not_emitted(trigger_area.collision_activated)
		return true


	func handler_test_trigger_area_doesnt_do_anything_on_body_or_area_entered_if_no_collision_events_on_enter_exist() -> bool:
		trigger_area.collision_bodies = true
		trigger_area.collision_areas = true
		trigger_area.collision_events_on_enter = null
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emitted(trigger_area.body_entered)
		test.assert_signal_emitted(trigger_area.area_entered)
		test.assert_signal_not_emitted(trigger_area.collision_activated)
		return true

	#endregion

	#region tests body and area entered interaction detection

	func handler_test_trigger_area_can_detect_a_body_or_area_enter_and_enable_interactions_detection() -> bool:
		trigger_area.interaction_bodies = true
		trigger_area.interaction_areas = true
		_configure_collision_node(trigger_area, trigger_area_collision_shape, displacement_position_test)
		test.watch_signals(trigger_area)
		test.assert_signal_not_emitted(trigger_area.body_entered)
		test.assert_signal_not_emitted(trigger_area.area_entered)
		test.assert_signal_not_emitted(trigger_area.collision_activated)
		test.assert_true(trigger_area.colliding_bodies.is_empty())
		test.assert_false(trigger_area.is_processing_unhandled_input())
		test_other_body.global_position = trigger_area.global_position
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emit_count(trigger_area.body_entered, 1)
		test.assert_signal_not_emitted(trigger_area.area_entered)
		test.assert_eq(trigger_area.colliding_bodies.size(), 1)
		test.assert_true(trigger_area.colliding_bodies.has(test_other_body))
		test.assert_true(trigger_area.colliding_areas.is_empty())
		test.assert_true(trigger_area.is_processing_unhandled_input())
		test_other_area.global_position = trigger_area.global_position
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emit_count(trigger_area.body_entered, 1)
		test.assert_signal_emit_count(trigger_area.area_entered, 1)
		test.assert_eq(trigger_area.colliding_bodies.size(), 1)
		test.assert_true(trigger_area.colliding_bodies.has(test_other_body))
		test.assert_eq(trigger_area.colliding_areas.size(), 1)
		test.assert_true(trigger_area.colliding_areas.has(test_other_area))
		test.assert_true(trigger_area.is_processing_unhandled_input())
		return true


	func handler_test_trigger_area_doesnt_do_anything_on_body_or_area_enter_if_interaction_bodies_and_interaction_areas_is_false() -> bool:
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emitted(trigger_area.body_entered)
		test.assert_signal_emitted(trigger_area.area_entered)
		test.assert_true(trigger_area.colliding_bodies.is_empty())
		test.assert_true(trigger_area.colliding_areas.is_empty())
		test.assert_false(trigger_area.is_processing_unhandled_input())
		return true

	#endregion

	#region tests body and area exited collision events

	func handler_test_trigger_area_can_detect_a_body_or_area_exit_and_trigger_collision_events_on_exit() -> bool:
		trigger_area.collision_bodies = true
		trigger_area.collision_areas = true
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		trigger_area.global_position = displacement_position_test
		test_other_area.global_position = displacement_position_test
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emit_count(trigger_area.body_exited, 1)
		test.assert_signal_not_emitted(trigger_area.area_exited)
		test.assert_signal_emit_count(trigger_area.collision_deactivated, 1)
		test.assert_called_count(collision_events_on_exit_stub.trigger_events, 1)
		test_other_area.global_position = base_position_test
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emit_count(trigger_area.body_exited, 1)
		test.assert_signal_emit_count(trigger_area.area_exited, 1)
		test.assert_signal_emit_count(trigger_area.collision_deactivated, 2)
		test.assert_called_count(collision_events_on_exit_stub.trigger_events, 2)
		return true


	func handler_test_trigger_area_doesnt_do_anything_on_body_or_area_exited_if_collision_bodies_and_collision_areas_is_false() -> bool:
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		trigger_area.global_position = displacement_position_test
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emit_count(trigger_area.body_exited, 1)
		test.assert_signal_emit_count(trigger_area.area_exited, 1)
		test.assert_signal_not_emitted(trigger_area.collision_deactivated)
		return true


	func handler_test_trigger_area_doesnt_do_anything_on_body_or_area_exited_if_no_collision_events_on_exit_exist() -> bool:
		trigger_area.collision_bodies = true
		trigger_area.collision_areas = true
		trigger_area.collision_events_on_exit = null
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		trigger_area.global_position = displacement_position_test
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emit_count(trigger_area.body_exited, 1)
		test.assert_signal_emit_count(trigger_area.area_exited, 1)
		test.assert_signal_not_emitted(trigger_area.collision_deactivated)
		return true

	#endregion

	#region tests body and area exited interaction detection

	func handler_test_trigger_area_can_detect_a_body_or_area_exit_and_disable_interactions_detection_if_none_are_inside() -> bool:
		trigger_area.interaction_bodies = true
		trigger_area.interaction_areas = true
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_true(trigger_area.colliding_bodies.has(test_other_body))
		test.assert_true(trigger_area.colliding_areas.has(test_other_area))
		test.assert_true(trigger_area.is_processing_unhandled_input())
		trigger_area.global_position = displacement_position_test
		test_other_area.global_position = displacement_position_test
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_false(trigger_area.colliding_bodies.has(test_other_body))
		test.assert_true(trigger_area.colliding_areas.has(test_other_area))
		test.assert_true(trigger_area.is_processing_unhandled_input())
		trigger_area.global_position = base_position_test
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_true(trigger_area.colliding_bodies.has(test_other_body))
		test.assert_false(trigger_area.colliding_areas.has(test_other_area))
		test.assert_true(trigger_area.is_processing_unhandled_input())
		test_other_area.global_position = base_position_test
		trigger_area.global_position = displacement_position_test
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_false(trigger_area.colliding_bodies.has(test_other_body))
		test.assert_false(trigger_area.colliding_areas.has(test_other_area))
		test.assert_false(trigger_area.is_processing_unhandled_input())
		test.assert_signal_emit_count(trigger_area.body_exited, 2)
		test.assert_signal_emit_count(trigger_area.area_exited, 1)
		return true


	func handler_test_trigger_area_doesnt_do_anything_on_body_or_area_exit_if_interaction_bodies_and_interaction_areas_is_false() -> bool:
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		trigger_area.global_position = displacement_position_test
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_signal_emit_count(trigger_area.body_exited, 1)
		test.assert_signal_emit_count(trigger_area.area_exited, 1)
		test.assert_true(trigger_area.colliding_bodies.is_empty())
		test.assert_true(trigger_area.colliding_areas.is_empty())
		test.assert_false(trigger_area.is_processing_unhandled_input())
		return true

	#endregion

	#region tests input handling

	func handler_test_trigger_area_can_handle_inputs_with_interaction_detections_enabled_and_trigger_events() -> bool:
		trigger_area.interaction_bodies = true
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_true(trigger_area.is_processing_unhandled_input())
		var sender: GutInputSender = GutInputSender.new(trigger_area)
		sender.action_down(&"interact")
		sender.action_up(&"interact")
		test.assert_signal_emit_count(trigger_area.action_pressed, 1)
		test.assert_signal_emit_count(trigger_area.action_released, 1)
		test.assert_called_count(interaction_events_on_pressed_stub.trigger_events, 1)
		test.assert_called_count(interaction_events_on_released_stub.trigger_events, 1)
		return true


	func handler_test_trigger_area_can_handle_inputs_with_interaction_detections_enabled_but_not_trigger_events_if_it_doesnt_have_any() -> bool:
		trigger_area.interaction_bodies = true
		trigger_area.interaction_events_on_pressed = null
		trigger_area.interaction_events_on_released = null
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_true(trigger_area.is_processing_unhandled_input())
		var sender: GutInputSender = GutInputSender.new(trigger_area)
		sender.action_down(&"interact")
		sender.action_up(&"interact")
		test.assert_signal_emit_count(trigger_area.action_pressed, 1)
		test.assert_signal_emit_count(trigger_area.action_released, 1)
		test.assert_not_called(interaction_events_on_pressed_stub.trigger_events)
		test.assert_not_called(interaction_events_on_released_stub.trigger_events)
		return true


	func handler_test_trigger_area_ignores_invalid_inputs() -> bool:
		trigger_area.interaction_bodies = true
		_configure_collision_node(trigger_area, trigger_area_collision_shape)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		test.assert_true(trigger_area.is_processing_unhandled_input())
		var sender: GutInputSender = GutInputSender.new(trigger_area)
		sender.action_down(&"not_valid")
		sender.action_up(&"not_valid")
		test.assert_signal_not_emitted(trigger_area.action_pressed)
		test.assert_signal_not_emitted(trigger_area.action_released)
		return true


	func handler_test_trigger_area_cant_handle_inputs_if_no_element_is_inside() -> bool:
		trigger_area.interaction_bodies = true
		trigger_area.interaction_areas = true
		_configure_collision_node(trigger_area, trigger_area_collision_shape, displacement_position_test)
		test.watch_signals(trigger_area)
		await test.gut.get_tree().physics_frame
		await test.gut.get_tree().physics_frame
		var sender: GutInputSender = GutInputSender.new(trigger_area)
		sender.action_down(&"interact")
		sender.action_up(&"interact")
		test.assert_signal_not_emitted(trigger_area.action_pressed)
		test.assert_signal_not_emitted(trigger_area.action_released)
		return true

	#endregion
