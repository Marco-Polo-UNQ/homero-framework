extends GutTest

const VERSION_CHECKER_POPUP_PATH: String = \
	"res://addons/homero_framework/src/core/editor/version/version_checker_popup.tscn"


func test_version_checker_popup_display() -> void:
	var version_checker_popup: AcceptDialog = load(VERSION_CHECKER_POPUP_PATH).instantiate()
	add_child_autoqfree(version_checker_popup)
	
	var test_output_message := "Current Version: %s\nLatest Version: %s"
	version_checker_popup.output_message = test_output_message
	
	var current_version := "1.0.0"
	var latest_version := "1.2.0"
	
	version_checker_popup.enter(current_version, latest_version)
	
	var expected_text := test_output_message % [current_version, latest_version]
	assert_eq(
		version_checker_popup.find_child("MessageLabel", true).text,
		expected_text
	)
