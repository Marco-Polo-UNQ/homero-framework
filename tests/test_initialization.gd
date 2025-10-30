extends GutTest

## This is an initialization unit test

func test_plugin_starts() -> void:
	assert_not_null(EventsManager)
