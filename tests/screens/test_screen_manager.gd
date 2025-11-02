extends GutTest

var screen_manager: HFScreenManager

var starting_screen_stub: HFScreenLoader
var another_screen_stub: HFScreenLoader


func before_each() -> void:
	starting_screen_stub = double(HFScreenLoader).new()
	@warning_ignore("int_as_enum_without_cast") # We ignore the enum warnings because we do not care at this point what the enum has
	starting_screen_stub.screen_id = 0
	add_child_autoqfree(starting_screen_stub)

	another_screen_stub = double(HFScreenLoader).new()
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match") # We ignore the enum warnings because we do not care at this point what the enum has
	another_screen_stub.screen_id = 1
	add_child_autoqfree(another_screen_stub)

	screen_manager = HFScreenManager.new()
	screen_manager.starting_screen = starting_screen_stub
	screen_manager.screens = [starting_screen_stub, another_screen_stub]
	watch_signals(screen_manager)
	add_child_autoqfree(screen_manager)
	
	# We await so it has time to process deferred initializations
	await gut.get_tree().physics_frame


func test_screen_manager_has_a_starting_screen() -> void:
	assert_eq(
		screen_manager.starting_screen,
		starting_screen_stub
	)


func test_screen_manager_has_screens() -> void:
	assert_eq_deep(
		screen_manager.screens,
		[starting_screen_stub, another_screen_stub]
	)


func test_screen_manager_starts_with_starting_screen() -> void:
	assert_eq(
		screen_manager._current_screen,
		starting_screen_stub
	)
	assert_true(
		starting_screen_stub.change_screen.is_connected(
			screen_manager._change_screen
		)
	)
	assert_called_count(
		starting_screen_stub.enter,
		1
	)
	assert_signal_emit_count(
		screen_manager.screen_changed,
		1
	)


func test_screen_manager_changes_screen() -> void:
	starting_screen_stub.change_screen.emit(1, "test_value")
	await gut.get_tree().physics_frame
	assert_eq(
		screen_manager._current_screen,
		another_screen_stub
	)
	assert_true(
		another_screen_stub.change_screen.is_connected(
			screen_manager._change_screen
		)
	)
	assert_false(
		starting_screen_stub.change_screen.is_connected(
			screen_manager._change_screen
		)
	)
	assert_called_count(
		starting_screen_stub.exit,
		1
	)
	assert_called_count(
		another_screen_stub.enter,
		1
	)
	assert_called(
		another_screen_stub,
		"enter",
		["test_value"]
	)


func test_screen_manager_handles_invalid_screen_change() -> void:
	starting_screen_stub.change_screen.emit(999)
	await gut.get_tree().physics_frame
	assert_eq(
		screen_manager._current_screen,
		starting_screen_stub
	)
	assert_push_error(
		"Screen with id 999 does not exist!"
	)
