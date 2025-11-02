@tool
extends Node
## Editor tool for checking the latest version of the plugin against GitHub releases.

## API route for fetching the latest release from GitHub.
const API_REQUEST_URL: String = "https://api.github.com/repos/Marco-Polo-UNQ/homero-framework/releases/latest"
## Preloaded scene for the popup warning dialog.
const popup_warning_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/version/version_checker_popup.tscn"
)

## The HTTPRequest node used for API requests.
var http_request

# Called when the node is added to the scene tree.
func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)

## Requests a version check against the latest version from GitHub.
func check_version(current_version: String) -> void:
	if http_request.request_completed.is_connected(_on_http_request_completed):
		http_request.request_completed.disconnect(_on_http_request_completed)
	http_request.request_completed.connect(_on_http_request_completed.bind(current_version))
	
	var status: int = http_request.request(API_REQUEST_URL)
	if status == OK:
		HFLog.d("Version check request sent successfully, awaiting response.")
	else:
		HFLog.e("Error fetching version data %s" % status)

# Handles the HTTP request completion and shows a popup if the version is outdated.
func _on_http_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
	current_version: String
) -> void:
	var json_parsed: JSON = JSON.new()
	var status: int = json_parsed.parse(body.get_string_from_utf8())
	if status != OK:
		HFLog.e("Error parsing response for version data %s with body %s" % [status, body])
		return

	var data: Dictionary = json_parsed.data
	if !data.has("tag_name"):
		HFLog.e("Error fetching version data, the field 'tag_name' doesn't exist!\nParsed data is %s" % data)
		return

	var latest_version: String = data["tag_name"]
	if latest_version == current_version:
		HFLog.d("Up to date!")
		return

	HFLog.e("Version is different from latest, current is '%s' latest is '%s'. If you have an outdated version, please update the plugin to receive the latest features!" % [current_version, latest_version])
	var popup: Window = popup_warning_scene.instantiate()
	popup.enter(current_version, latest_version)
	if Engine.is_editor_hint():
		EditorInterface.popup_dialog(popup)
	else:
		popup.queue_free()
