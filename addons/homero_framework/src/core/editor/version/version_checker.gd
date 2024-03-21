@tool
extends Node

## Editor tool that automatically checks the latest version of the plugin
## against the latest and notifies the user if there are any differences.

const api_request_route: String = "https://api.github.com/repos/Marco-Polo-UNQ/homero-framework/releases/latest"
const popup_warning_scene: PackedScene = preload(
	"res://addons/homero_framework/src/core/editor/version/version_checker_popup.tscn"
)

var http_request: HTTPRequest


func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)


func check_version(current_version: String) -> void:
	if http_request.request_completed.is_connected(_on_http_request_completed):
		http_request.request_completed.disconnect(_on_http_request_completed)
	
	http_request.request_completed.connect(_on_http_request_completed.bind(current_version))
	var status: int = http_request.request(api_request_route)
	if status != OK:
		HFLog.e("Error fetching version data %s" % status)


func _on_http_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
	current_version: String
	) -> void:
	var json_parsed: JSON = JSON.new()
	var status: int = json_parsed.parse(body.get_string_from_utf8())
	if status == OK:
		var data: Dictionary = json_parsed.data
		if data.has("tag_name"):
			var latest_version: String = data["tag_name"]
			if latest_version != current_version:
				HFLog.e("Version is different from latest, current is '%s' latest is '%s'. If you have an outdated version, please update the plugin to receive the latest features!" % [current_version, latest_version])
				var popup: Window = popup_warning_scene.instantiate()
				popup.enter(current_version, latest_version)
				EditorInterface.popup_dialog(popup)
			else:
				HFLog.d("Up to date!")
		else:
			HFLog.e("Error fetching version data, the field 'name' doesn't exist!\nParsed data is %s" % data)
	else:
		HFLog.e("Error parsing response for version data %s with body %s" % [status, body])
