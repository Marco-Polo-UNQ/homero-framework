extends GutTest

func test_screen_can_call_exit() -> void:
	var screen: HFScreen = double(HFScreen).new()
	add_child_autoqfree(screen)
	stub(screen.exit).to_call_super()
	watch_signals(screen)
	screen.exit()
	assert_signal_emitted(screen.finished_exit)
