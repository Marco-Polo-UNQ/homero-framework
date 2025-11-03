extends GutTest

const VERSION_CHECKER_SCENE_PATH: String = "res://addons/homero_framework/src/core/editor/version/version_checker.tscn"

var version_checker: Node

var http_request_mock


class MockHTTPRequest:
	extends Node
	
	signal request_completed
	
	func request(path: String) -> Error:
		return 0


func before_all() -> void:
	set_double_strategy(DOUBLE_STRATEGY.INCLUDE_NATIVE)
	register_inner_classes(get_script())


func before_each() -> void:
	version_checker = load(VERSION_CHECKER_SCENE_PATH).instantiate()
	add_child_autoqfree(version_checker)
	
	# Mock the HTTPRequest node to avoid real HTTP requests during tests
	var old_http_request: HTTPRequest = version_checker.http_request
	version_checker.remove_child(old_http_request)
	old_http_request.queue_free()
	
	http_request_mock = double(MockHTTPRequest).new()
	version_checker.http_request = http_request_mock
	version_checker.add_child(http_request_mock)


func test_version_checker_node_exists() -> void:
	assert_not_null(version_checker)
	assert_true(version_checker is Node)


func test_version_checker_has_http_request() -> void:
	assert_eq(
		version_checker.http_request,
		http_request_mock
	)
	assert_true(
		version_checker.is_ancestor_of(http_request_mock)
	)
	assert_eq(
		version_checker.get_child_count(),
		1
	)


func test_version_checker_can_check_version_with_positive_request_response() -> void:
	stub(
		http_request_mock.request.bind(
			version_checker.API_REQUEST_URL
		)
	).to_return(OK)
	assert_false(
		http_request_mock.request_completed.is_connected(
			version_checker._on_http_request_completed
		)
	)
	version_checker.check_version("1.0.0")
	assert_true(
		http_request_mock.request_completed.is_connected(
			version_checker._on_http_request_completed
		)
	)
	assert_called(
		http_request_mock,
		"request",
		[version_checker.API_REQUEST_URL]
	)
	assert_push_error_count(0)


func test_version_checker_handles_http_request_with_negative_request_response() -> void:
	stub(
		http_request_mock.request.bind(
			version_checker.API_REQUEST_URL
		)
	).to_return(ERR_CANT_CONNECT)
	assert_false(
		http_request_mock.request_completed.is_connected(
			version_checker._on_http_request_completed
		)
	)
	version_checker.check_version("1.0.0")
	assert_true(
		http_request_mock.request_completed.is_connected(
			version_checker._on_http_request_completed
		)
	)
	assert_called(
		http_request_mock,
		"request",
		[version_checker.API_REQUEST_URL]
	)
	assert_push_error("Error fetching version data %s" % ERR_CANT_CONNECT)


func test_version_checker_on_http_request_completed_with_valid_data() -> void:
	stub(
		http_request_mock.request.bind(
			version_checker.API_REQUEST_URL
		)
	).to_return(OK)
	version_checker.check_version("1.0.0")
	
	var mock_response_body: String = '{"tag_name": "1.0.0"}'
	var mock_body_bytes: PackedByteArray = PackedByteArray()
	for c in mock_response_body.to_utf8_buffer():
		mock_body_bytes.append(c)
	
	http_request_mock.request_completed.emit(
		OK,
		200,
		PackedStringArray(),
		mock_body_bytes
	)
	assert_push_error_count(0)


func test_version_checker_on_http_request_completed_with_outdated_version() -> void:
	stub(
		http_request_mock.request.bind(
			version_checker.API_REQUEST_URL
		)
	).to_return(OK)
	version_checker.check_version("1.0.0")
	
	var mock_response_body: String = '{"tag_name": "1.1.0"}'
	var mock_body_bytes: PackedByteArray = PackedByteArray()
	for c in mock_response_body.to_utf8_buffer():
		mock_body_bytes.append(c)
	
	http_request_mock.request_completed.emit(
		OK,
		200,
		PackedStringArray(),
		mock_body_bytes
	)
	assert_push_error("Version is different from latest, current is '1.0.0' latest is '1.1.0'. If you have an outdated version, please update the plugin to receive the latest features!")
	# Here you would check for expected behavior, such as logging or popup creation
	# Since we cannot capture logs or UI that runs in the editor in this test, we assume
	# the function would open a popup in the actual editor environment.
	# This limits the total coverage of this test.


func test_version_checker_on_http_request_completed_with_invalid_json() -> void:
	stub(
		http_request_mock.request.bind(
			version_checker.API_REQUEST_URL
		)
	).to_return(OK)
	version_checker.check_version("1.0.0")
	
	var mock_response_body: String = '{"invalid_json": "hi"}'
	var mock_body_bytes: PackedByteArray = PackedByteArray()
	for c in mock_response_body.to_utf8_buffer():
		mock_body_bytes.append(c)
	
	http_request_mock.request_completed.emit(
		OK,
		200,
		PackedStringArray(),
		mock_body_bytes
	)
	assert_push_error(
		"Error fetching version data, the field 'tag_name' doesn't exist!\nParsed data is %s" % {"invalid_json": "hi"}
	)


func test_version_checker_on_http_request_completed_with_parse_error() -> void:
	stub(
		http_request_mock.request.bind(
			version_checker.API_REQUEST_URL
		)
	).to_return(OK)
	version_checker.check_version("1.0.0")
	
	var mock_response_body: String = ""
	var mock_body_bytes: PackedByteArray = PackedByteArray()
	for c in mock_response_body.to_utf8_buffer():
		mock_body_bytes.append(c)
	
	http_request_mock.request_completed.emit(
		OK,
		200,
		PackedStringArray(),
		mock_body_bytes
	)
	assert_push_error(
		"Error parsing response for version data %s with body %s" % [ERR_PARSE_ERROR, mock_response_body]
	)


func test_version_checker_can_check_version_multiple_times() -> void:
	stub(
		http_request_mock.request.bind(
			version_checker.API_REQUEST_URL
		)
	).to_return(OK)
	
	version_checker.check_version("1.0.0")
	assert_called(
		http_request_mock,
		"request",
		[version_checker.API_REQUEST_URL]
	)
	
	version_checker.check_version("1.0.1")
	assert_called(
		http_request_mock,
		"request",
		[version_checker.API_REQUEST_URL]
	)
	
	assert_push_error_count(0)
